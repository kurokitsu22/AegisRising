// Keep spawning ahead of the player
while (spawn_x < oPlayer.x + 1500) {

    // Spawn SAFE collision floor (invisible)
    var floor_width = 64;
    for (var i = 0; i < 5; i++) {
        instance_create_layer(spawn_x, floor_y, "Instances", oGC); // Invisible collision
        instance_create_layer(spawn_x, floor_y, "Instances", oS21); // Visual grass!
        spawn_x += floor_width;
    }

    // Randomly spawn an obstacle
    if (random(1) < 0.4) {
        var block = instance_create_layer(spawn_x, floor_y - 64, "Instances", oObstacle);

        if (random(1) < 0.3) {
            block.y -= 64;
            block.image_yscale = 2;
        }
    }
    
    // Stretch the room width so the camera can keep scrolling right infinitely
    if (spawn_x > room_width) {
        room_width = spawn_x + 2000; 
    }
}