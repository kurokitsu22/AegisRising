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

// 0 is the absolute left edge of the room, so the camera never shows the left void
camera_x = clamp(camera_x, 0, room_width - cam_width);
camera_y = clamp(camera_y, 0, room_height - cam_height);


// ==============================
// APPLY CAMERA
// ==============================

camera_set_view_pos(camera, camera_x, camera_y);