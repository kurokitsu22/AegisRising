// ==============================
// FOLLOW PLAYER
// ==============================

var target_x = oPlayer.x - cam_width / 2;
var target_y = oPlayer.y - cam_height / 2;

// ==============================
// SMOOTH CAMERA MOVEMENT
// ==============================

camera_x = lerp(camera_x, target_x, 0.10);
camera_y = lerp(camera_y, target_y, 0.10);

// ==============================
// KEEP CAMERA INSIDE ROOM
// ==============================

camera_x = clamp(camera_x, 0, room_width - cam_width);
camera_y = clamp(camera_y, 0, room_height - cam_height);

// ==============================
// PARALLAX BACKGROUNDS (Move layers at different speeds)
// ==============================
// This moves the layers infinitely based on the camera position!
layer_x("Moon", camera_x * 0.1);
layer_x("Mountain2", camera_x * 0.3);
layer_x("Mountain1", camera_x * 0.5);
layer_x("Clouds1", camera_x * 0.7);
layer_x("Cloud2", camera_x * 0.8);
layer_x("Tree3", camera_x * 0.9);
layer_x("Tree2", camera_x * 0.95);
layer_x("Tree1", camera_x); // Closest trees move at camera speed

// ==============================
// APPLY CAMERA
// ==============================

camera_set_view_pos(camera, camera_x, camera_y);