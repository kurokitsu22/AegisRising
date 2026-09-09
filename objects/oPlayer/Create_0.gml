hsp = 6;
vsp = 0;
grv = 0.8;
jump_force = -14;
on_ground = true;
is_dead = false;
global.paused = false; // room (re)start always unpauses
mask_index = sprite_index;
xstart = x;
points  = 0;
running_sound_id = -1;
audio_play_sound(aForestAmbiance, 3, true);

// Load highscore once — persists across respawns AND relaunching the game
if (!variable_global_exists("highscore")) {
    ini_open("save.ini");
    global.highscore = ini_read_real("Data", "HighScore", 0);
    ini_close();
}