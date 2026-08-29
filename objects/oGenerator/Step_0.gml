// Keep spawning ahead of the player
while (spawn_x < oPlayer.x + 1500) {
    
    // Spawn Floor
    var floor_width = 64;
    for (var i = 0; i < 5; i++) {
        instance_create_layer(spawn_x, floor_y, "Instances", oFloor);
        spawn_x += floor_width;
    }
    
    // Randomly spawn an obstacle
    if (random(1) < 0.4) { // 40% chance to spawn a block
        var block = instance_create_layer(spawn_x, floor_y - 64, "Instances", oObstacle); 
        
        // Randomize block height for variety
        if (random(1) < 0.3) {
            block.y -= 64; 
            block.image_yscale = 2; 
        }
    }
}