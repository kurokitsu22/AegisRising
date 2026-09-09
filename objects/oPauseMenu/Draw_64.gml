draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(-1); // swap to fScore if you want it bigger

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var cx = gw / 2;
var cy = gh / 2;

// Dim the background (stand-in for blur)
draw_set_alpha(0.65);
draw_set_color(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

// "PAUSED"
draw_set_color(c_yellow);
draw_text_transformed(cx, cy - 150, "PAUSED", 3, 3, 0);

// Continue button
draw_set_color(selected_option == 0 ? c_yellow : c_white);
draw_roundrect(cx - 120, cy - 40, cx + 120, cy, false);
draw_set_color(c_black);
draw_text(cx, cy - 20, "CONTINUE");

// Respawn button
draw_set_color(selected_option == 1 ? c_yellow : c_white);
draw_roundrect(cx - 120, cy + 10, cx + 120, cy + 50, false);
draw_set_color(c_black);
draw_text(cx, cy + 30, "RESPAWN");

// Main Menu button
draw_set_color(selected_option == 2 ? c_yellow : c_white);
draw_roundrect(cx - 120, cy + 60, cx + 120, cy + 100, false);
draw_set_color(c_black);
draw_text(cx, cy + 80, "MAIN MENU");

draw_set_color(c_white);