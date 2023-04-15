extends Node
## This is a script to query convAI for AI-generated NPC dialogue.  
## You need a convAI API key for this to work; put it as a string in the
## export variable for api_key and in the ready script for Godot-AI-NPC Controller
## (if using the demo scene).

#Signal used to alert other entities of the final GPT response text
signal AI_response_generated(response)


export(String) var api_key = "insert your api key" setget set_api_key # Your API key from convai.com
export(String) var convai_session_id = "-1" setget set_session_id
export(String) var convai_character_id = "insert your convai character code"
export(bool) var voice_response = false
var url = "https://api.convai.com/character/getResponse" 
var headers = ["CONVAI-API-KEY: " + api_key, "Content-Type: application/json"]
var http_request : HTTPRequest


func _ready():
	# set up normal http request node for calls to call_GPT function
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	
	set_api_key(api_key)
	set_session_id(convai_session_id)
		
func call_convAI(prompt):
	var voice_response_string : String
	
	if voice_response == true:
		voice_response_string = "True"
	else:
		voice_response_string = "False"
			
	print("calling convAI")
	var body = JSON.print({
		"userText": prompt,
		"charID": convai_character_id,
		"sessionID": convai_session_id,
		"voiceResponse": voice_response_string
	})
	
	print(body)
	# Now call convAI
	var error = http_request.request(url, headers, true, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("Something Went Wrong!")
		print(error)
	
# This GDScript code is used to handle the response from a request.
func _on_request_completed(result, responseCode, headers, body):
	# Should recieve 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error, response code:" + str(responseCode))
		print(headers)
		print(body)
		return
		
	var data = body.get_string_from_utf8()#fix_chunked_response(body.get_string_from_utf8())
	print ("Data received: %s"%data)
	var response = parse_json(data)
	var AI_generated_dialogue = response["text"]
	set_session_id(response["sessionID"])
	# Let other nodes know that AI generated dialogue is ready from GPT	
	emit_signal("AI_response_generated", AI_generated_dialogue)
	
	
# Setter function for character
func set_character_id(new_character_id : String):
	convai_character_id = new_character_id
	
	
# Setter function for session
func set_session_id(new_session_id : String):
	convai_session_id = new_session_id


# Setter function for API Key
func set_api_key(new_api_key : String):
	api_key = new_api_key
	headers = PoolStringArray(["CONVAI-API-KEY: " + api_key, "Content-Type: application/json"])


#If needed someday
func fix_chunked_response(data):
	var tmp = data.replace("}\r\n{","},\n{")
	return ("[%s]"%tmp)
