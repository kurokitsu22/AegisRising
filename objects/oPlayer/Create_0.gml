hsp = 6;          // Horizontal speed (auto-run)
vsp = 0;          // Vertical speed
grv = 0.8;        // Gravity strength
jump_force = -14; // Jump strength
on_ground = true;
is_dead = false;

mask_index = sprite_index; 

xstart = x;

points = 0;

running_sound_id = -1;
audio_play_sound(aForestAmbiance, 3, true);

