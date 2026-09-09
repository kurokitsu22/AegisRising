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
        draw_set_alpha(0.8);
        
        draw_roundrect_ext(
            20 - _padding,
            20 - _padding,
            20 + _tw + _padding,
            20 + _th + _padding,
            8, 8, false
        );
        
        // 3. Draw the Text
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(20, 20, _text);

        // 4. Highscore box, right below the score box
        var _hs_text = "Highscore: " + string(global.highscore);
        var _hs_y = 20 + _th + 20; // sits below the score box with a gap
        var _hs_tw = string_width(_hs_text);
        var _hs_th = string_height(_hs_text);

        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_roundrect_ext(
            20 - _padding,
            _hs_y - _padding,
            20 + _hs_tw + _padding,
            _hs_y + _hs_th + _padding,
            8, 8, false
        );

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(20, _hs_y, _hs_text);
    }
}