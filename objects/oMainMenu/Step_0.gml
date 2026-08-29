// Move up
if (keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W"))) {
    menu_selected -= 1;
}

// Move down
if (keyboard_check_pressed(vk_down) or keyboard_check_pressed(ord("S"))) {
    menu_selected += 1;
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
        room_goto(rRunner);
    }
    
    if (menu_selected == 1) {
        game_end();
    }
}