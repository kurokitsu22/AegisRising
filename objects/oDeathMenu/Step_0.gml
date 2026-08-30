if (keyboard_check_pressed(vk_up) or keyboard_check_pressed(vk_down)) {
    selected_option = 1 - selected_option; // toggles between 0 and 1
    audio_play_sound(aMainMenuOption, 10, false);
}

if (keyboard_check_pressed(vk_enter)) {
    
    // Stops ONLY the running and ambiance sounds before leaving
    audio_stop_sound(aPlayerRunning);
    audio_stop_sound(aForestAmbiance);
    
    if (selected_option == 0) {
        room_restart();
    } else {
        room_goto(rMainMenu);
    }
}