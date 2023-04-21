# godot-ai-npc-example

Example of using an AI NPC in Godot VR, using Godot OpenXR (Godot 3.5.1), Wit.ai, GPT-3.5-turbo, ElevenLabs, convAI, and Godot-tts addon
 
![VirtualDesktop Android-20230410-171603](https://user-images.githubusercontent.com/87204721/231021547-a5511c4b-5cf7-4704-b6ff-fb905435389c.jpg)


## Use ##

This uses Godot 3.5, download the project and open it in Godot 3.5.x editor. Make sure your VR headset mic is on and run the project. Click on the NPC with your trigger to start recording your mic, click again to stop and generate AI dialogue and Text to Speech.  Or, get close to the NPC and press the B/Y button to start/stop your microphone.  There will be visual indicators (Label3Ds) that tell you when you are pointing at an NPC or in the NPC's talking proximity.

This is made for VR, but the GPT, wit.ai, ElevenLabs, and convAI scripts found in the addons folder should hopefully be useful for everyone to adapt to their particular use case, while this demo shows how various functionalities might be connected together.

You will need to use your own wit.ai token, openAI GPT API key, ElevenLabs API key and convAI API key, depending on what functions you use / test.

You can learn more about wit.ai here: https://wit.ai/

You can learn more about GPT here: https://platform.openai.com/docs/models/gpt-3-5

You can learn more about ElevenLabs here: https://beta.elevenlabs.io/

You can learn more about convAI here:https://convai.com/pipeline/convai-character

The Godot-AI-NPC-Controller node is where you select which combination of AI-generator and text to speech you want to use. Then enter your API keys/tokens/character codes in the relevant nodes for wit.ai, gpt, eleven labs and/or convAI.


## Config File ##

This project also now provides an example of generating a user config file, called ai_npc_api_keys.cfg, to allow users to input their own api keys and options, and if you select the option in the Godot-AI-NPC-Controller to use config file, config file values will control over project settings.  This allows, for example, you to generate an AI NPC project or mod but without distributing your own API keys ("BYOK" - "Bring Your Own Key").  Since many API keys cost money, have usage or query limits, this can be another viable option to distributing your work until a project is commercially viable.

The config file will be found in the location of user data for the project / game.  For instance, the path for me (Windows 11) is: 

C:\Users\\[my user name]\AppData\Roaming\Godot\app_userdata\godot-ai-npc-example\ai_npc_api_keys.cfg

An example of the config file that is generated is:

![godot-ai-npc-config-file-shot](https://user-images.githubusercontent.com/87204721/233620822-6d545f68-cd9f-42ba-b734-1ab12f0eed7f.png)

The variables are as follows:

**[api_keys]**

wit_ai_token - the string that is your wit ai token (this is free)

gpt_3_5_turbo_api_key - this is your OpenAI GPT-3.5-turbo API key (you have to pay for this, but it is extremely cheap; throughout the development of this project I have only spent about 10 U.S. cents)

convai_api_key - your api key from convAI - this is free with 200 requests per day, which is fabulous!!

convai_character_id - this is the code for the convAI AI character you want to load. You can write your own back story, choose your voice, give it knowledge.  It's really cool.

convai_session_id - this starts at -1 unless you assign an existing session ID to continue a conversation between sessions.

eleven_labs_api_key - your api key from eleven labs.  There is a free version, great! However it is limited to 10,000 characters.

eleven_labs_character_code - your code from eleven labs for the voice you generated and want to use.

**[gpt_options]**

gpt_npc_directions - this is an example system background for GPT-3.5-turbo.  Basically in as a few words as possible tell it about the game world and the NPC's place in it.

gpt_sample_question - this is the text of a sample question which helps reinforce the background in gpt_npc_directions

gpt_sample_npc_response - this is the text of a sample response to the question above that also reinforces the background in gpt_npc_directions

gpt_temperature - see GPT documentation for an explanation, basically how strict or creative NPC can be.

**[ai_npc_options]**

ai_npc_controller_tts_choice - This is which provider to use for text to speech. The options are either 0, 1, or 2 (just integers not strings). 0 is Godot (which uses an addon found here: https://github.com/lightsoutgames/godot-tts ) that leverages the operating system's native text to speech, 1 is Eleven Labs, 2 is Convai text to speech.  If you're also using Convai for AI response generation, it will use the voice associated with your Convai Character. If you're not using Convai for AI response generation, then it will use the convai text to speech voice below.

ai_npc_controller_ai_brain_choice - This is the provider to use for AI generated text responses.  The options are either 0 or 1 (just integers, not strings).  0 is ConvAI, 1 is GPT-3.5-turbo.

**[convai_options]**

convai_standalone_tts_voice - This is a string response, defaulted at "WUMale 1".  The proper string values and explanations can be found at:  https://docs.convai.com/api-docs/reference/core-api-reference/standalone-voice-api/text-to-speech-api  (only mp3 voices are currently supported in this project)

