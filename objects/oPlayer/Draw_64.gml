// Only draw the score IF the Death Menu does NOT exist
if (!instance_exists(oDeathMenu)) {
    
    // Make sure the player exists before trying to read their points
    if (instance_exists(oPlayer)) {
        
        // 1. Setup Text
        draw_set_font(fScore); // Use your new bigger font!
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        var _text = "Score: " + string(oPlayer.points);
        var _padding = 10; // Gap between the text and the edge of the box
        
        // Get the size of the text
        var _tw = string_width(_text);
        var _th = string_height(_text);
        
        // 2. Draw the curved black background
        draw_set_color(c_black);
        draw_set_alpha(0.8); // 1 is fully solid, 0 is invisible. 0.8 looks nice.
        
        // draw_roundrect_ext(x1, y1, x2, y2, xradius, yradius, outline)
        draw_roundrect_ext(
            20 - _padding,                // x1 (left)
            20 - _padding,                // y1 (top)
            20 + _tw + _padding,          // x2 (right)
            20 + _th + _padding,          // y2 (bottom)
            8,                            // xradius (curve size)
            8,                            // yradius (curve size)
            false                         // false = filled in, true = outline only
        );
        
        // 3. Draw the Text
        draw_set_alpha(1); // Reset alpha back to normal
        draw_set_color(c_white);
        draw_text(20, 20, _text);
    }
}