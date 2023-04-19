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
