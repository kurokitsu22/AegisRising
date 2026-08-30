// Move up
if (keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W"))) {
    menu_selected -= 1;
    audio_play_sound(aMainMenuOption, 10, false);
}
// Move down
if (keyboard_check_pressed(vk_down) or keyboard_check_pressed(ord("S"))) {
    menu_selected += 1;
    audio_play_sound(aMainMenuOption, 10, false);
}
// Keep selection between 0 and 1
if (menu_selected < 0) {
    menu_selected = 1;
}
if (menu_selected > 1) {
    menu_selected = 0;
}
// Select
if (keyboard_check_pressed(vk_enter) or keyboard_check_pressed(vk_space)) {
    
    if (menu_selected == 0) {
        audio_stop_sound(aMainMenu);
        room_goto(rRunner);
    }
    
    if (menu_selected == 1) {
        game_end();
    }
}