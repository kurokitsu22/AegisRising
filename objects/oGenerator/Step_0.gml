// Keep spawning ahead of the player
while (spawn_x < oPlayer.x + 1500) {
    // Spawn SAFE collision floor (invisible)
    var floor_width = 64;
    for (var i = 0; i < 5; i++) {
        instance_create_layer(spawn_x, floor_y, "Instances", oGC); // Invisible collision
        // Visual grass!
        var visual_floor = instance_create_layer(spawn_x, floor_y, "Instances", oS21);
        visual_floor.image_yscale = 1;
        spawn_x += floor_width;
    }

    // Decide obstacle type: ground OR flying, never both at once
    var roll = random(1);

    if (roll < 0.3) {
        // GROUND obstacle — sits right on the floor, must jump over
        var block = instance_create_layer(spawn_x, floor_y - 58, "Instances", oDeath);
        block.image_xscale = 0.5;
        block.image_yscale = 0.5;
    }
    else if (roll < 0.45) {
        // FLYING obstacle — fixed height, must NOT jump into it
        var fly_y = floor_y - 120; // tune this: higher number = higher up
        var flyer = instance_create_layer(spawn_x, fly_y, "Instances", oDeath);
        flyer.image_xscale = 0.5;
        flyer.image_yscale = 0.5;
    }
    // else: no obstacle this pass, just floor

    // Stretch the room width so the camera can keep scrolling right infinitely
    if (spawn_x > room_width) {
        room_width = spawn_x + 2000;
    }
}