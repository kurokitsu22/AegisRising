function input_jump_pressed() {
    return keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W")) or mouse_check_button_pressed(mb_left) or keyboard_check_pressed(vk_space);
}

function input_jump_held() {
    return keyboard_check(vk_up) or keyboard_check(ord("W")) or mouse_check(mb_left) or keyboard_check(vk_space);
}

function input_left() {
    return keyboard_check(vk_left) or keyboard_check(ord("A"));
}

function input_right() {
    return keyboard_check(vk_right) or keyboard_check(ord("D"));
}