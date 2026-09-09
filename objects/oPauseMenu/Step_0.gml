frames++;

// ESC also resumes — but NOT on the frame the menu was opened
if (frames > 1 && keyboard_check_pressed(vk_escape)) {
    global.paused = false;
    instance_destroy();
    exit;
}

if (keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W"))) {
    selected_option -= 1;
    audio_play_sound(aMainMenuOption, 10, false);
}
if (keyboard_check_pressed(vk_down) or keyboard_check_pressed(ord("S"))) {
    selected_option += 1;
    audio_play_sound(aMainMenuOption, 10, false);
}
if (selected_option < 0) { selected_option = 2; }
if (selected_option > 2) { selected_option = 0; }

if (keyboard_check_pressed(vk_enter)) {
    if (selected_option == 0) {
        // CONTINUE — unpause, keep the run going
        global.paused = false;
        instance_destroy();
    }
    else if (selected_option == 1) {
        // RESPAWN — save the run's highscore first, restart resets points
        save_highscore_if_beaten();
        global.paused = false;
        room_restart();
    }
    else {
        // MAIN MENU — save, stop the player's looping sounds, leave
        save_highscore_if_beaten();
        if (instance_exists(oPlayer)) {
            if (oPlayer.running_sound_id != -1) {
                audio_stop_sound(oPlayer.running_sound_id);
            }
        }
        audio_stop_sound(aForestAmbiance);
        global.paused = false;
        room_goto(rMainMenu);
    }
}