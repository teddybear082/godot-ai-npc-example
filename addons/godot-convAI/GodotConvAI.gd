extends Node
## This is a script to query convAI for AI-generated NPC dialogue.  
## You need a convAI API key for this to work; put it as a string in the
## export variable for api_key and in the ready script for Godot-AI-NPC Controller
## (if using the demo scene).

# Signal used to alert other entities of the final convAI response text
signal AI_response_generated(response)

# Signal used to alert other entities that voice sample was played
signal convAI_voice_sample_played

export(String) var api_key = "insert your api key" setget set_api_key # Your API key from convai.com
export(String) var convai_session_id = "-1" setget set_session_id
export(String) var convai_character_id = "insert your convai character code"
export(bool) var voice_response = false
export(int) var voice_sample_rate = 22050
export(float,-10.0, 10.0) var voice_pitch_scale = 1.0
export(bool) var use_standalone_text_to_speech = false setget set_use_standalone_tts

# Array of standard convai voices as of creation of this script (April 2023): https://docs.convai.com/api-docs/reference/core-api-reference/standalone-voice-api/text-to-speech-api
var convai_standalone_tts_voices : Array = [
	"WUKMale 1",
	"WUKMale 2",
	"WUKFemale 1",
	"WUKFemale 2",
	"WUKFemale 3",
	"WAMale 1",
	"WAMale 2",
	"WAFemale 1",
	"WAFemale 2",
	"WIMale 1",
	"WIMale 2",
	"WIFemale 1",
	"WIFemale 2",
	"WUMale 1",
	"WUMale 2",
	"WUMale 3",
	"WUMale 4",
	"WUMale 5",
	"WUFemale 1",
	"WUFemale 2",
	"WUFemale 3",
	"WUFemale 4",
	"WUFemale 5"
]

# Specific selection for standalone voice - this can be used without the array, but the array may be useful for randomizing results or otherwise choosing appropriate selection in code
export(String, "WUKMale 1",
	"WUKMale 2",
	"WUKFemale 1",
	"WUKFemale 2",
	"WUKFemale 3",
	"WAMale 1",
	"WAMale 2",
	"WAFemale 1",
	"WAFemale 2",
	"WIMale 1",
	"WIMale 2",
	"WIFemale 1",
	"WIFemale 2",
	"WUMale 1",
	"WUMale 2",
	"WUMale 3",
	"WUMale 4",
	"WUMale 5",
	"WUFemale 1",
	"WUFemale 2",
	"WUFemale 3",
	"WUFemale 4",
	"WUFemale 5") var convai_standalone_tts_voice_selection = "WUMale 1" setget set_convai_standalone_tts_voice
#var convai_standalone_tts_voice_selection = "WUMale 1"
var url = "https://api.convai.com/character/getResponse" 
var tts_url = "https://api.convai.com/tts/"
var headers
var tts_headers
var http_request : HTTPRequest
var http_client : HTTPClient
var convai_speech_player : AudioStreamPlayer
var convai_stream : AudioStreamSample
var convai_tts_stream : AudioStreamMP3
var TTS_http_request : HTTPRequest


func _ready():
	# Set up normal http request node for calls to call_convAI function
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	
	# Add http client to perform transition from dictionary to form-data needed for convAI API
	http_client = HTTPClient.new()
	
	set_api_key(api_key)
	set_session_id(convai_session_id)
	set_character_id(convai_character_id)
	set_voice_response_mode(voice_response)
	
	# Set up second http request and response signal for call_convAI_TTS function
	TTS_http_request = HTTPRequest.new()
	add_child(TTS_http_request)
	if use_standalone_text_to_speech == true:
		TTS_http_request.set_download_file("user://convaiaudio.mp3")
		convai_tts_stream = AudioStreamMP3.new()
	TTS_http_request.connect("request_completed", self, "_on_TTS_request_completed")
	
	# Set up headers for use for normal convAI AI-generated speech responses and standalone text-to-speech
	headers = PoolStringArray(["CONVAI-API-KEY: " + api_key, "Content-Type: application/x-www-form-urlencoded"])
	tts_headers = PoolStringArray(["CONVAI-API-KEY: " + api_key, "Content-Type: application/json"])
	
	# Create audio player node for speech playback
	convai_speech_player = AudioStreamPlayer.new()
	convai_speech_player.pitch_scale = voice_pitch_scale
	add_child(convai_speech_player)
	convai_stream = AudioStreamSample.new()	
		
		
func call_convAI(prompt):
	var voice_response_string : String
	
	if voice_response == true:
		voice_response_string = "True"
	else:
		voice_response_string = "False"
			
	#print("calling convAI with prompt:" + prompt)
	var body = {
		"userText": prompt,
		"charID": convai_character_id,
		"sessionID": convai_session_id,
		"voiceResponse": voice_response_string
	}
	
	var form_data = http_client.query_string_from_dict(body)
	#print(form_data)
	
	# Now call convAI
	var error = http_request.request(url, headers, true, HTTPClient.METHOD_POST, form_data)
	
	if error != OK:
		push_error("Something Went Wrong!")
		print(error)
	
	
# This GDScript code is used to handle the response from a request.
func _on_request_completed(result, responseCode, headers, body):
	# Should recieve 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error, response code:" + str(responseCode))
		print(result)
		print(headers)
		print(body)
		return
		
	var data = body.get_string_from_utf8()#fix_chunked_response(body.get_string_from_utf8())
	#print ("Data received: %s"%data)
	var response = parse_json(data)
	var AI_generated_dialogue = response["text"]
	set_session_id(response["sessionID"])
	# Let other nodes know that AI generated dialogue is ready from convAI	
	emit_signal("AI_response_generated", AI_generated_dialogue)
	
	# If voice response is true, get audio from response from convAI and make it a .wav audio stream
	if voice_response == true:
		var AI_generated_audio = response["audio"]
		#print(AI_generated_audio)
		var encoded_audio = Marshalls.base64_to_raw(AI_generated_audio)
		convai_stream.data = encoded_audio
		convai_stream.loop_mode = AudioStreamSample.LOOP_DISABLED
		convai_stream.format = AudioStreamSample.FORMAT_16_BITS
		convai_stream.mix_rate = voice_sample_rate
		convai_speech_player.set_stream(convai_stream)
		convai_speech_player.play()
		emit_signal("convAI_voice_sample_played")


# Function to call convAI's standalone text-to-speech API (not using convAI to generate AI response text)
func call_convAI_TTS(text):
	
	var body = JSON.print({
		"transcript": text,
		"voice": convai_standalone_tts_voice_selection,
		"filename": "convaiaudio",
		"encoding": "mp3"
	})
	
	# Now call convAI TTS
	var error = TTS_http_request.request(tts_url, tts_headers, true, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("Something Went Wrong!")


# Receiver function for when using call to convAI in standalone text to speech mode (not using Convai for AI generated response content)
func _on_TTS_request_completed(result, responseCode, headers, body):
	# Should recieve 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error, response code:" + str(responseCode))
		print(result)
		print(headers)
		print(body)
		return
		
	#var audio_file_from_convai = body
	
	var file = File.new()
	var err = file.open("user://convaiaudio.mp3", File.READ)
	var bytes = file.get_buffer(file.get_len())
	convai_tts_stream.data = bytes 
	convai_speech_player.set_stream(convai_tts_stream)
	convai_speech_player.play()
	
	emit_signal("convAI_voice_sample_played")
	
# Setter function for character
func set_character_id(new_character_id : String):
	convai_character_id = new_character_id
	
	
# Setter function for session
func set_session_id(new_session_id : String):
	convai_session_id = new_session_id


# Setter function for API Key
func set_api_key(new_api_key : String):
	api_key = new_api_key
	headers = PoolStringArray(["CONVAI-API-KEY: " + api_key, "Content-Type: application/x-www-form-urlencoded"])
	tts_headers = PoolStringArray(["CONVAI-API-KEY: " + api_key, "Content-Type: application/json"])

# Reset session ID so conversation is not remembered
func reset_session():
	convai_session_id = "-1"
	
	
# Determine if AI-generated response content also includes and uses voice file
func set_voice_response_mode(mode : bool):
	voice_response = mode
	

# Set if using convAI solely for standalone text to speech
func set_use_standalone_tts(mode : bool):
	use_standalone_text_to_speech = mode
	if mode == true and TTS_http_request:
		TTS_http_request.set_download_file("user://convaiaudio.mp3")
	elif mode == false and TTS_http_request:
		TTS_http_request.set_download_file("")
	
	# Create tts stream if it has not already been created
	if mode == true and convai_tts_stream == null:
		convai_tts_stream = AudioStreamMP3.new()			


# Allow setting of convai standalone tts voice
func set_convai_standalone_tts_voice(selection : String):
	if !convai_standalone_tts_voices.has(selection):
		print("error, standalone voice selection string does not exist in Convai options")
		return
	convai_standalone_tts_voice_selection = selection
		
					
#If needed someday
func fix_chunked_response(data):
	var tmp = data.replace("}\r\n{","},\n{")
	return ("[%s]"%tmp)
