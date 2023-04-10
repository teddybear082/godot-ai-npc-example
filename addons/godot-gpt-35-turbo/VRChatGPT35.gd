extends Node
## This is a script to query GPT-3.5-turbo for AI-generated NPC dialogue.  
## You need a OpenAI API key for this to work; put it as a string in the
## export variable for api_key.

#Signal used to alert other entities of the final GPT response text
signal AI_response_generated(response)

export(String) var api_key = "sk-...insert your OpenAI GPT API Key here" setget set_api_key # As of creation, should start with sk-
export(float, 0.0, 1.0) var temperature = 0.5 setget set_temperature # how creative or strict the NPC responds, set between 0 and 1.
export(String) var npc_background_directions = "You are a non-playable character in a video game.  You are a robot.  Your name is Bob.  Your job is taping boxes of supplies.  You love organization.  You hate mess. Your boss is Robbie the Robot. Robbie is a difficult boss who makes a lot of demands.  You respond to the user's questions as if you are in the video game world with the player."   # Used to give GPT some instructions as to the character's background.
export(String) var sample_npc_question_prompt = "Hi, what do you do here?"  # Create a sample question the reinforces the NPC's character traits
export(String) var sample_npc_prompt_response = "Greetings fellow worker! My name is Bob and I am a robot.  My job is to tape up the boxes in this factory before they are shipped out to our customers!" # Create a sample response to the prompt above the reinforces the NPC's character traits
var url = "https://api.openai.com/v1/chat/completions" 
var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var engine = "gpt-3.5-turbo" 
var http_request


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")

		
func call_GPT(prompt):
	#print("calling GPT")
	var body = JSON.print({
		"model": engine,
		"messages": [{"role": "system", "content": npc_background_directions}, {"role": "user", "content": sample_npc_question_prompt}, {"role": "assistant", "content": sample_npc_prompt_response}, {"role": "user", "content": prompt}],
		"temperature": temperature
	})
	var error = http_request.request(url, headers, true, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("Something Went Wrong!")
	
# This GDScript code is used to handle the response from a request.
func _on_request_completed(result, responseCode, headers, body):
	var data = body.get_string_from_utf8()#fix_chunked_response(body.get_string_from_utf8())
	#print ("Data received: %s"%data)
	var response = parse_json(data)
	var choices = response.choices[0]
	var message = choices["message"]
	var AI_generated_dialogue = message["content"]
	emit_signal("AI_response_generated", AI_generated_dialogue)


func set_temperature(new_temperature : float):
	temperature = new_temperature


func set_api_key(new_api_key : String):
	api_key = new_api_key


#If needed someday
func fix_chunked_response(data):
	var tmp = data.replace("}\r\n{","},\n{")
	return ("[%s]"%tmp)
