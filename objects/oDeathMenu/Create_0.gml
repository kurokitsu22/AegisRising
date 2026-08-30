selected_option = 0;

// Stops ONLY the running and ambiance sounds
audio_stop_sound(aPlayerRunning);
audio_stop_sound(aForestAmbiance);

// Plays the death music
audio_play_sound(aPlayerDeathMusic, 5, false);