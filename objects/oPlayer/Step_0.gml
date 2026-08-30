if (!is_dead) {
    // 1. Handle Input (jump only — auto-runner, no manual left/right)
    if (input_jump_pressed() && on_ground) {
        vsp = jump_force;
        on_ground = false;
		audio_play_sound(aPlayerJump, 5, false);
    }
    // 2. Apply Gravity
    if (!on_ground) {
        vsp += grv;
    }
    // 3. Constant forward movement
    x += hsp;
    // 4. Horizontal Collisions (Death if hitting a wall/obstacle)
    if (place_meeting(x, y, oSolid)) {
        is_dead = true;
        vsp = 0;
        hsp = 0;
        if (running_sound_id != -1) {
            audio_stop_sound(running_sound_id);
            running_sound_id = -1;
        }
        audio_stop_sound(aForestAmbiance);
        audio_play_sound(sSpikeSound, 5, false);
        audio_play_sound(aPlayerDeathMusic, 5, false);
        instance_create_layer(0, 0, "Instances", oDeathMenu);
    }
    // 5. Vertical Movement
    y += vsp;
    // 6. Vertical Collisions (Landing on the floor)
    if (place_meeting(x, y, oGC)) {
        if (vsp > 0) { // Falling down
            while (!place_meeting(x, y - 1, oGC)) {
                y -= 1;
            }
            vsp = 0;
            on_ground = true;
        }
        else if (vsp < 0) { // Jumping up
            while (!place_meeting(x, y + 1, oGC)) {
                y += 1;
            }
            vsp = 0;
        }
    }
    else {
        on_ground = false;
    }
    // 7. Animation + Running Sound
    if (!on_ground) {
        if (vsp > 0) {
            sprite_index = sFall;
        } else {
            sprite_index = sJump;
        }
        if (running_sound_id != -1 && audio_is_playing(running_sound_id)) {
            audio_stop_sound(running_sound_id);
            running_sound_id = -1;
        }
    } else {
        sprite_index = sRun;
        if (running_sound_id == -1 || !audio_is_playing(running_sound_id)) {
            running_sound_id = audio_play_sound(aPlayerRunning, 5, true);
        }
    }
}