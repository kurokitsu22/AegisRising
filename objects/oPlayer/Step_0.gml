if (!is_dead) {
    // 1. Handle Input
    if (input_jump_pressed() && on_ground) {
        vsp = jump_force;
        on_ground = false;
    }
    
    // 2. Apply Gravity
    if (!on_ground) {
        vsp += grv;
    }
    
    // 3. Horizontal Movement (Auto-run)
    x += hsp;
    
    // 4. Horizontal Collisions (Death if hitting a wall)
    if (place_meeting(x, y, oSolid)) {
        is_dead = true;
        vsp = 0;
        hsp = 0;
        instance_destroy();
        room_restart(); 
    }
    
    // 5. Vertical Movement
    y += vsp;
    
    // 6. Vertical Collisions (Landing on the floor/obstacles)
    if (place_meeting(x, y, oSolid)) {
        if (vsp > 0) { // Falling down
            while(!place_meeting(x, y-1, oSolid)) {
                y -= 1;
            }
            vsp = 0;
            on_ground = true;
        } else if (vsp < 0) { // Jumping up and hitting head
            while(!place_meeting(x, y+1, oSolid)) {
                y += 1;
            }
            vsp = 0;
            is_dead = true;
            instance_destroy();
            room_restart();
        }
    } else {
        on_ground = false;
    }
    
    // 7. Animation
    if (!on_ground) {
        if (vsp > 0) {
            sprite_index = sFall; 
        } else {
            sprite_index = sJump;
        }
    } else {
        sprite_index = sRun;
    }
}