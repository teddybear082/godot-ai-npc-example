extends Node

## This node manages the interactions between the wit.ai node, the gpt-3.5 turbo node and the text to speech addon.

# Variable to choose interaction button for speaking to NPC when using "proximity" mode
export (XRTools.Buttons) var activate_mic_button : int = XRTools.Buttons.VR_BUTTON_BY

# Variable for text to display while mic active and recording
export(String) var mic_recording_text = "Mic recording..."

# Variable for text to display while waiting for response
export(String) var waiting_text = "Waiting for response..."

# Enum for text to speech choice
enum text_to_speech_type {
	GODOT,
	ELEVENLABS
}

# Export for text to speech choice
export(text_to_speech_type) var text_to_speech_choice


# Nodes used for wi, gpt, and text to speech
onready var wit_ai_node = get_node("VRVoiceControl-WitAI")
onready var gpt_node = get_node("GodotGPT35Turbo")
onready var interact_label3D = get_node("InteractLabel3D")
onready var mic_active_label3D = get_node("MicActiveLabel3D")
onready var text_to_speech = get_node("Text-to-Speech")
onready var convai_node = get_node("GodotConvAI")
onready var eleven_labs_tts_node = get_node("ElevenLabsTTS")

# Variable used to determine if player can use proximity interaction
var close_enough_to_talk : bool = false

# Variable used to determine if already talking
var mic_active : bool = false



func _ready():
	# Activate wit ai voice commands
	wit_ai_node.activate_voice_commands(true)
	
	# Set speaking rate of text to speech for text to speech addon
	text_to_speech._set_rate(1.5)

	# Connect wit ai speech to text received signal to handler function
	wit_ai_node.connect("wit_ai_speech_to_text_received", self, "_on_wit_ai_processed")
	
	# Connect AI response generated signal from GPT to handler function
	gpt_node.connect("AI_response_generated", self, "_on_gpt_3_5_turbo_processed")
	
	# Connect AI response generated signal from ConvAI to handler function
	convai_node.connect("AI_response_generated", self, "_on_convai_processed")
	
	# Set wit.ai API key
#	wit_ai_node.set_token("insert your token here")
	
	# Set GPT API key
#	gpt_node.set_api_key("insert your key here")
	
	# Set ConvAI API key
	#convai_node.set_api_key("insert your key here")
	
	# Set ElevenLabs API key
	#eleven_labs_tts_node.set_api_key("insert your key here")
	
	
# Handler for player VR button presses to determine if player is trying to activate or stop mic while in proximity of NPC
func _on_player_controller_button_pressed(button):
	if button != activate_mic_button:
		return
		
	if button == activate_mic_button and close_enough_to_talk and !mic_active:
		wit_ai_node.start_voice_command()
		mic_active = true
		mic_active_label3D.text = mic_recording_text
		mic_active_label3D.visible = true
		return
		
	if button == activate_mic_button and close_enough_to_talk and mic_active:
		mic_active_label3D.text = waiting_text
		wit_ai_node.end_voice_command()
		mic_active = false
		return
	
	
# Called to activate ability to start talking to NPC when in NPC's area, and display message to user notifying proximity activation is available
func _on_npc_dialogue_enabled_area_entered(body):
	close_enough_to_talk = true
	interact_label3D.visible = true
	
	
# Called to disable ability to start talking to NPC when not in NPC's area unless pointing at NPC and hide message regarding promixity use
func _on_npc_dialogue_enabled_area_exited(body):
	close_enough_to_talk = false
	interact_label3D.visible = false


# Called when player points at NPC's body and presses the button assigned for interactions in the function pointer node (default: VR Trigger)	
# The VR Function Pointer node in XR Tools passes the location of the click which is why there is a parameter for "location" here although not used.
func _on_npc_area_interaction_area_clicked(location):
	# If mic is already active, then end voice command and display waiting notification to user while wit.ai and GPT process response
	if mic_active:
		wit_ai_node.end_voice_command()
		mic_active = false
		mic_active_label3D.text = waiting_text
	# Otherwise, start voice command and display mic recording notification to user	
	else:
		wit_ai_node.start_voice_command()
		mic_active = true
		mic_active_label3D.text = mic_recording_text
		mic_active_label3D.visible = true


# Function called when wit.ai finishes processing speech to text, use the text it produces to call GPT	
func _on_wit_ai_processed(dialogue : String):
	gpt_node.call_GPT(dialogue)
	#convai_node.call_convAI(dialogue)


# Function called when GPT 3.5 turbo finishes processes AI dialogue response, use text_to_speech addon node to play the audio response	
# If you are using a different text to speech solution, the command to call it could be used instead of text_to_speech.speak(dialogue) here.
func _on_gpt_3_5_turbo_processed(dialogue : String):
	mic_active_label3D.visible = false
	if text_to_speech_choice == text_to_speech_type.GODOT:
		text_to_speech.speak(dialogue)
	else:
		eleven_labs_tts_node.call_ElevenLabs(dialogue)

# Function called when convAI finishes processes AI dialogue response, use text_to_speech addon node to play the audio response	
func _on_convai_processed(dialogue : String):
	mic_active_label3D.visible = false
	if text_to_speech_choice == text_to_speech_type.GODOT:
		text_to_speech.speak(dialogue)
	else:
		eleven_labs_tts_node.call_ElevenLabs(dialogue)
