draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(-1);

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var cx = gw / 2;
var cy = gh / 2;

// Dim the background (stand-in for blur)
draw_set_alpha(0.65);
draw_set_color(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

// "YOU DIED"
draw_set_color(c_red);
draw_text_transformed(cx, cy - 120, "YOU DIED", 3, 3, 0);

// Respawn button
draw_set_color(selected_option == 0 ? c_yellow : c_white);
draw_roundrect(cx - 120, cy - 20, cx + 120, cy + 20, false);
draw_set_color(c_black);
draw_text(cx, cy, "RESPAWN");

// Main Menu button
draw_set_color(selected_option == 1 ? c_yellow : c_white);
draw_roundrect(cx - 120, cy + 30, cx + 120, cy + 70, false);
draw_set_color(c_black);
draw_text(cx, cy + 50, "MAIN MENU");

draw_set_color(c_white);