// ==============================
// MENU DRAW
// ==============================

draw_set_halign(fa_center);
draw_set_valign(fa_middle);


// ==============================
// TITLE - TOP LEFT
// ==============================

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_white);

draw_text_transformed(
    50, 40,
    "AEGIS RISING",
    3, 3, 0
);


// ==============================
// RESET ALIGNMENT FOR MENU
// ==============================

draw_set_halign(fa_center);
draw_set_valign(fa_middle);


// ==============================
// START BUTTON
// ==============================

// Dark background
draw_set_alpha(0.8);
draw_set_color(c_black);

draw_roundrect(
    500, 465,
    858, 535,
    false
);


// Border
draw_set_alpha(1);

if (menu_selected == 0) {
    draw_set_color(c_yellow);
}
else {
    draw_set_color(c_white);
}

draw_roundrect(
    500, 465,
    858, 535,
    true
);


// Start text
if (menu_selected == 0) {
    draw_set_color(c_yellow);

    draw_text_transformed(
        679, 500,
        "> START <",
        1.5, 1.5, 0
    );
}
else {
    draw_set_color(c_white);

    draw_text_transformed(
        679, 500,
        "START",
        1.5, 1.5, 0
    );
}


// ==============================
// QUIT BUTTON
// ==============================

// Dark background
draw_set_alpha(0.8);
draw_set_color(c_black);

draw_roundrect(
    500, 555,
    858, 625,
    false
);


// Border
draw_set_alpha(1);

if (menu_selected == 1) {
    draw_set_color(c_yellow);
}
else {
    draw_set_color(c_white);
}

draw_roundrect(
    500, 555,
    858, 625,
    true
);


// Quit text
if (menu_selected == 1) {
    draw_set_color(c_yellow);

    draw_text_transformed(
        679, 590,
        "> QUIT <",
        1.5, 1.5, 0
    );
}
else {
    draw_set_color(c_white);

    draw_text_transformed(
        679, 590,
        "QUIT",
        1.5, 1.5, 0
    );
}


// ==============================
// RESET DRAW SETTINGS
// ==============================

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);