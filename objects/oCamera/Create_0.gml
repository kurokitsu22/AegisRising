camera = view_camera[0];

// ==============================
// CAMERA SIZE / ZOOM
// ==============================

cam_width = 1086;
cam_height = 614;

camera_set_view_size(camera, cam_width, cam_height);

// Start at the player's position
camera_x = oPlayer.x - cam_width / 2;
camera_y = oPlayer.y - cam_height / 2;

// Keep camera inside room
camera_x = clamp(camera_x, 0, room_width - cam_width);
camera_y = clamp(camera_y, 0, room_height - cam_height);

camera_set_view_pos(camera, camera_x, camera_y);