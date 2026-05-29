# Voice Interaction Module

The voice module implements a low-latency conversational loop for the robot game master.

## Hardware

- ESP32-S3-N16R8 microcontroller
- INMP441 I2S digital microphone
- MAX98357 digital amplifier
- 3W speaker

## Processing Pipeline

1. **Voice Activity Detection (VAD)** detects speech onset and endpoint.
2. **Streaming ASR** converts microphone audio into partial and final transcripts.
3. **LLM Agent** uses the game script, player identities, known clues, and dialogue guidelines to decide the next utterance or tool action.
4. **Streaming TTS** synthesizes characterful speech and begins playback before the whole response finishes.

The study implementation used the open-source Xiaozhi agent framework as the dialogue manager. For consistency, the agent was preloaded with the full script of *Judgment Quartet*, character backgrounds, and conversational guidelines. A barge-in mechanism allowed participants to interrupt the robot mid-utterance.

## Reproduction Notes

- Keep all prompt/context files outside public commits if they contain licensed game text.
- Use environment variables or provider consoles for ASR/TTS/LLM keys.
- Log only non-identifying events during user studies.
- Keep latency low enough that robot turn-taking feels conversational.
