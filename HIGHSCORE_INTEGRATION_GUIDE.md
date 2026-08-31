# Player Names, Improved Scoring, and High Scores

This guide is written specifically for the current **Aegis Rising** GameMaker project. It describes the changes to make in the GameMaker IDE; it does not apply those changes to the project.

## 1. What the project currently does

The relevant flow is small and direct:

- `oMainMenu` has two choices, **Start** and **Quit**, drawn in its normal Draw event.
- `oPlayer` owns a `points` variable and draws it in Draw GUI.
- Each `oDeath` obstacle has a `passed` flag. Its Step event adds one point once its origin moves behind the player.
- `oPlayer` creates `oDeathMenu` when it hits an `oSolid`.
- `oDeathMenu` already uses Draw GUI, shows the current points, and offers **Respawn** and **Main Menu**.
- There is no player-name state, saved data, or high-score list.

The implementation below keeps this overall structure. It adds one script as the central leaderboard API, keeps run-specific score data on `oPlayer`, and lets the two menu objects handle their own input and Draw GUI presentation.

### Resulting flow

1. The player selects **Start Run** in the main menu.
2. A name-entry modal opens. Enter confirms a 1–12 character name; Escape cancels.
3. During a run, the score increases from distance travelled and cleared obstacles.
4. On death, `oDeathMenu` snapshots and submits the score once.
5. The game-over screen displays the top ten and highlights the new entry when it qualifies.
6. The main menu has a **High Scores** choice that opens the same saved table.

This is an **offline/local leaderboard**. GameMaker writes its JSON file in the platform's sandboxed save area, not beside the source files. A shared online leaderboard would additionally require a trusted server/API and server-side score validation.

## 2. Scoring rules used in this guide

Replace the current one-point-per-obstacle system with two components:

| Component | Rule | Purpose |
| --- | --- | --- |
| Distance | 1 point per 10 pixels travelled | Rewards survival and steady progress |
| Obstacle clear | 100 points per fully cleared `oDeath` | Rewards successful evasions |

The final score is always:

```text
score = distance_score + obstacle_bonus
```

The constants are deliberately easy to tune later. At the current horizontal speed of 6 pixels per step and 60 game steps per second, distance contributes about 36 points per second.

## 3. Create the leaderboard script

In the Asset Browser, create a script named `scr_leaderboard`. Put all of the following in it.

```gml
/// scr_leaderboard.gml

/// Initialise globals once and load the local save file.
function leaderboard_init() {
    if (variable_global_exists("leaderboard_ready")) {
        if (global.leaderboard_ready) {
            return;
        }
    }

    global.leaderboard_ready       = true;
    global.leaderboard_max_entries = 10;
    global.leaderboard_file        = "aegis_highscores.json";
    global.leaderboard             = [];
    global.player_name             = "PLAYER";

    leaderboard_load();
}

/// Allow only characters already included in fScore's ASCII font range.
/// Returns an empty string when no valid characters remain.
function leaderboard_clean_name(_value) {
    var _source = string_upper(string(_value));
    var _clean  = "";

    for (var _i = 1; _i <= string_length(_source); _i++) {
        var _char = string_char_at(_source, _i);
        var _code = ord(_char);

        var _is_letter = (_code >= ord("A") && _code <= ord("Z"));
        var _is_digit  = (_code >= ord("0") && _code <= ord("9"));
        var _is_extra  = (_char == " " || _char == "-" || _char == "_");

        if (_is_letter || _is_digit || _is_extra) {
            _clean += _char;
        }
    }

    _clean = string_trim(_clean);
    return string_copy(_clean, 1, 12);
}

/// Read and validate the JSON file. Invalid/corrupt data falls back safely.
function leaderboard_load() {
    if (!file_exists(global.leaderboard_file)) {
        return;
    }

    var _file = file_text_open_read(global.leaderboard_file);
    if (_file == -1) {
        return;
    }

    var _json = "";
    while (!file_text_eof(_file)) {
        _json += file_text_read_string(_file);
        file_text_readln(_file);
    }
    file_text_close(_file);

    if (_json == "") {
        return;
    }

    try {
        var _data = json_parse(_json);

        if (!is_struct(_data)) {
            return;
        }

        if (struct_exists(_data, "player_name") && is_string(_data.player_name)) {
            var _saved_name = leaderboard_clean_name(_data.player_name);
            if (_saved_name != "") {
                global.player_name = _saved_name;
            }
        }

        if (!struct_exists(_data, "entries")) {
            return;
        }
        if (!is_array(_data.entries)) {
            return;
        }

        var _loaded = [];

        for (var _i = 0; _i < array_length(_data.entries); _i++) {
            var _entry = _data.entries[_i];

            if (!is_struct(_entry)) {
                continue;
            }
            if (!struct_exists(_entry, "name")) {
                continue;
            }
            if (!is_string(_entry.name)) {
                continue;
            }
            if (!struct_exists(_entry, "score")) {
                continue;
            }
            if (!is_numeric(_entry.score)) {
                continue;
            }

            var _name = leaderboard_clean_name(_entry.name);
            if (_name == "") {
                _name = "PLAYER";
            }

            _loaded[array_length(_loaded)] = {
                name  : _name,
                score : max(0, floor(_entry.score))
            };
        }

        // Stable insertion sort: highest first, with older ties kept first.
        for (var _i = 1; _i < array_length(_loaded); _i++) {
            var _moving = _loaded[_i];
            var _j      = _i - 1;

            while (_j >= 0) {
                if (_moving.score <= _loaded[_j].score) {
                    break;
                }

                _loaded[_j + 1] = _loaded[_j];
                _j--;
            }

            _loaded[_j + 1] = _moving;
        }

        if (array_length(_loaded) > global.leaderboard_max_entries) {
            array_resize(_loaded, global.leaderboard_max_entries);
        }

        global.leaderboard = _loaded;
    }
    catch (_error) {
        show_debug_message("High-score file could not be read: " + string(_error));
        global.leaderboard = [];
    }
}

/// Save the last player name and top-ten entries as JSON.
function leaderboard_save() {
    var _payload = {
        version     : 1,
        player_name : global.player_name,
        entries     : global.leaderboard
    };

    var _file = file_text_open_write(global.leaderboard_file);
    if (_file == -1) {
        show_debug_message("High-score file could not be opened for writing.");
        return false;
    }

    file_text_write_string(_file, json_stringify(_payload));
    file_text_close(_file);
    return true;
}

/// Store the name before entering the runner room.
function leaderboard_set_player_name(_value) {
    leaderboard_init();

    var _clean = leaderboard_clean_name(_value);
    if (_clean == "") {
        return false;
    }

    global.player_name = _clean;
    leaderboard_save();
    return true;
}

/// Insert one completed run in descending order and save it.
/// Returns its one-based rank, or 0 when it falls outside the top ten.
function leaderboard_submit(_name, _score) {
    leaderboard_init();

    var _clean_name = leaderboard_clean_name(_name);
    if (_clean_name == "") {
        _clean_name = "PLAYER";
    }

    var _clean_score = max(0, floor(_score));
    var _count       = array_length(global.leaderboard);
    var _insert_at   = _count;

    // A new tied score is placed after older entries with that score.
    for (var _i = 0; _i < _count; _i++) {
        if (_clean_score > global.leaderboard[_i].score) {
            _insert_at = _i;
            break;
        }
    }

    // Extend, shift, then insert. This also gives an exact rank for duplicates.
    global.leaderboard[_count] = {
        name  : _clean_name,
        score : _clean_score
    };

    for (var _i = _count; _i > _insert_at; _i--) {
        global.leaderboard[_i] = global.leaderboard[_i - 1];
    }

    global.leaderboard[_insert_at] = {
        name  : _clean_name,
        score : _clean_score
    };

    var _rank = _insert_at + 1;

    if (array_length(global.leaderboard) > global.leaderboard_max_entries) {
        array_resize(global.leaderboard, global.leaderboard_max_entries);
    }

    global.player_name = _clean_name;
    leaderboard_save();

    if (_rank > global.leaderboard_max_entries) {
        return 0;
    }
    return _rank;
}

/// Shared Draw GUI helper used by both menu objects.
function leaderboard_draw_panel(_x, _y, _width, _row_height, _highlight_rank) {
    leaderboard_init();

    var _gold         = make_color_rgb(224, 184, 74);
    var _panel_height = 70 + _row_height * (global.leaderboard_max_entries + 1);

    draw_set_font(fScore);
    draw_set_alpha(0.92);
    draw_set_color(make_color_rgb(10, 12, 18));
    draw_roundrect_ext(_x, _y, _x + _width, _y + _panel_height, 12, 12, false);

    draw_set_alpha(1);
    draw_set_color(_gold);
    draw_roundrect_ext(_x, _y, _x + _width, _y + _panel_height, 12, 12, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_gold);
    draw_text_transformed(_x + _width * 0.5, _y + 26, "HALL OF THE AEGIS", 1.35, 1.35, 0);

    var _header_y = _y + 56;
    draw_set_color(make_color_rgb(125, 130, 142));
    draw_line(_x + 18, _header_y - 7, _x + _width - 18, _header_y - 7);

    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_text(_x + 22, _header_y + _row_height * 0.5, "RANK");
    draw_text(_x + 92, _header_y + _row_height * 0.5, "RUNNER");

    draw_set_halign(fa_right);
    draw_text(_x + _width - 22, _header_y + _row_height * 0.5, "SCORE");

    for (var _i = 0; _i < global.leaderboard_max_entries; _i++) {
        var _rank       = _i + 1;
        var _row_top    = _header_y + _row_height + _i * _row_height;
        var _row_bottom = _row_top + _row_height;
        var _row_y      = (_row_top + _row_bottom) * 0.5;

        if ((_i mod 2) == 1) {
            draw_set_alpha(0.16);
            draw_set_color(c_white);
            draw_rectangle(_x + 12, _row_top, _x + _width - 12, _row_bottom, false);
        }

        if (_rank == _highlight_rank) {
            draw_set_alpha(0.28);
            draw_set_color(_gold);
            draw_rectangle(_x + 12, _row_top, _x + _width - 12, _row_bottom, false);
        }

        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_color(_rank == _highlight_rank ? _gold : c_white);
        draw_text(_x + 25, _row_y, string(_rank) + ".");

        if (_i < array_length(global.leaderboard)) {
            var _entry = global.leaderboard[_i];
            draw_text(_x + 92, _row_y, _entry.name);

            draw_set_halign(fa_right);
            draw_text(_x + _width - 25, _row_y, string(_entry.score));
        }
        else {
            draw_set_color(make_color_rgb(105, 108, 118));
            draw_text(_x + 92, _row_y, "---");

            draw_set_halign(fa_right);
            draw_text(_x + _width - 25, _row_y, "---");
        }
    }

    // Never leak draw state into another object's Draw/Draw GUI event.
    draw_set_font(-1);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
```

Why use an array of structs instead of the legacy built-in `highscore_*` functions: the project needs a name and a score for each row, JSON persistence, explicit top-ten control, and the ability to highlight the newly inserted row.

## 4. Add player-name input and High Scores to the main menu

### 4.1 Replace `oMainMenu` Create

```gml
leaderboard_init();

menu_selected   = 0;
menu_item_count = 3;

// 0 = normal menu, 1 = name entry, 2 = high-score overlay
menu_mode       = 0;
name_max_length = 12;
input_error     = "";

audio_play_sound(aMainMenu, 10, true);
```

The explicit menu mode is important: while typing a name, letters such as W and S must not move the menu selection.

### 4.2 Replace `oMainMenu` Step

```gml
if (menu_mode == 0) {
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        menu_selected = (menu_selected - 1 + menu_item_count) mod menu_item_count;
        audio_play_sound(aMainMenuOption, 10, false);
    }

    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        menu_selected = (menu_selected + 1) mod menu_item_count;
        audio_play_sound(aMainMenuOption, 10, false);
    }

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        switch (menu_selected) {
            case 0: // Start Run -> ask for the player's name first
                menu_mode   = 1;
                input_error = "";

                // Prefill the last accepted name. Use "" here instead if every
                // run should begin with an empty field.
                keyboard_string = global.player_name;
                break;

            case 1: // High Scores
                menu_mode = 2;
                break;

            case 2: // Quit
                game_end();
                break;
        }
    }
}
else if (menu_mode == 1) {
    // keyboard_string handles printable keys and Backspace automatically.
    if (string_length(keyboard_string) > name_max_length) {
        keyboard_string = string_copy(keyboard_string, 1, name_max_length);
    }

    if (keyboard_check_pressed(vk_escape)) {
        keyboard_string = "";
        input_error     = "";
        menu_mode       = 0;
    }
    else if (keyboard_check_pressed(vk_enter)) {
        var _clean_name = leaderboard_clean_name(keyboard_string);

        if (_clean_name == "") {
            input_error = "ENTER AT LEAST ONE LETTER OR NUMBER";
        }
        else {
            leaderboard_set_player_name(_clean_name);
            keyboard_string = "";
            audio_stop_sound(aMainMenu);
            room_goto(rRunner);
        }
    }
}
else if (menu_mode == 2) {
    if (keyboard_check_pressed(vk_escape)
    ||  keyboard_check_pressed(vk_enter)
    ||  keyboard_check_pressed(vk_space)) {
        menu_mode = 0;
    }
}
```

### 4.3 Move the main-menu UI to Draw GUI

`oMainMenu` currently uses a regular **Draw** event. Delete that event (or remove its code), add **Draw > Draw GUI**, and use the following code. Leaving both events active would draw the menu twice.

```gml
var _gw     = display_get_gui_width();
var _gh     = display_get_gui_height();
var _cx     = _gw * 0.5;
var _gold   = make_color_rgb(224, 184, 74);
var _labels = ["START RUN", "HIGH SCORES", "QUIT"];

draw_set_font(fScore);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(50, 40, "AEGIS RISING", 3, 3, 0);

// Normal menu buttons remain visible underneath either modal.
var _button_w   = 360;
var _button_h   = 62;
var _button_gap = 18;
var _button_x1  = _cx - _button_w * 0.5;
var _button_y1  = _gh * 0.54;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var _i = 0; _i < menu_item_count; _i++) {
    var _top      = _button_y1 + _i * (_button_h + _button_gap);
    var _bottom   = _top + _button_h;
    var _selected = (_i == menu_selected && menu_mode == 0);

    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_roundrect_ext(_button_x1, _top, _button_x1 + _button_w, _bottom, 10, 10, false);

    draw_set_alpha(1);
    draw_set_color(_selected ? _gold : c_white);
    draw_roundrect_ext(_button_x1, _top, _button_x1 + _button_w, _bottom, 10, 10, true);

    var _label = _selected ? "> " + _labels[_i] + " <" : _labels[_i];
    draw_text_transformed(_cx, (_top + _bottom) * 0.5, _label, 1.3, 1.3, 0);
}

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(190, 190, 195));
draw_text(_gw - 30, _gh - 22, "CURRENT RUNNER: " + global.player_name);

if (menu_mode == 1) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);

    var _panel_w = min(560, _gw - 60);
    var _panel_h = 240;
    var _x1      = _cx - _panel_w * 0.5;
    var _y1      = _gh * 0.5 - _panel_h * 0.5;

    draw_set_alpha(0.96);
    draw_set_color(make_color_rgb(10, 12, 18));
    draw_roundrect_ext(_x1, _y1, _x1 + _panel_w, _y1 + _panel_h, 12, 12, false);
    draw_set_alpha(1);
    draw_set_color(_gold);
    draw_roundrect_ext(_x1, _y1, _x1 + _panel_w, _y1 + _panel_h, 12, 12, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_gold);
    draw_text_transformed(_cx, _y1 + 38, "NAME YOUR RUNNER", 1.4, 1.4, 0);

    draw_set_color(c_black);
    draw_roundrect_ext(_x1 + 45, _y1 + 78, _x1 + _panel_w - 45, _y1 + 128, 7, 7, false);
    draw_set_color(c_white);
    draw_roundrect_ext(_x1 + 45, _y1 + 78, _x1 + _panel_w - 45, _y1 + 128, 7, 7, true);

    var _cursor = ((current_time div 500) mod 2 == 0) ? "|" : "";
    draw_text(_cx, _y1 + 103, keyboard_string + _cursor);

    draw_set_color(input_error == "" ? make_color_rgb(180, 182, 190) : c_red);
    draw_text(_cx, _y1 + 157, input_error == ""
        ? "1-12 CHARACTERS: A-Z, 0-9, SPACE, - OR _"
        : input_error);

    draw_set_color(c_white);
    draw_text(_cx, _y1 + 199, "ENTER: BEGIN RUN    ESC: CANCEL");
}
else if (menu_mode == 2) {
    draw_set_alpha(0.74);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);

    var _row_h   = min(30, (_gh - 230) / (global.leaderboard_max_entries + 1));
    var _table_w = min(700, _gw - 60);
    var _table_h = 70 + _row_h * (global.leaderboard_max_entries + 1);
    var _table_y = max(24, (_gh - _table_h) * 0.5 - 18);

    leaderboard_draw_panel(_cx - _table_w * 0.5, _table_y, _table_w, _row_h, 0);

    draw_set_font(fScore);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_cx, min(_gh - 24, _table_y + _table_h + 28), "ENTER / SPACE / ESC: BACK");
}

draw_set_font(-1);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

No room edit is needed: `rMainMenu` already contains an `oMainMenu` instance.

## 5. Upgrade the run score

### 5.1 Replace `oPlayer` Create

```gml
leaderboard_init();

hsp        = 6;
vsp        = 0;
grv        = 0.8;
jump_force = -14;
on_ground  = true;
is_dead    = false;

mask_index = sprite_index;
xstart     = x;

// Run identity and scoring.
player_name       = global.player_name;
score             = 0;
distance_score    = 0;
obstacle_bonus    = 0;
obstacles_cleared = 0;

// Tuning values.
pixels_per_distance_point = 10;
points_per_obstacle       = 100;

running_sound_id = -1;
audio_play_sound(aForestAmbiance, 3, true);
```

This removes the old `points` variable. After this step, every old `oPlayer.points` reference must be replaced as described below.

### 5.2 Replace `oDeath` Step

Keep its Create event as `passed = false;`, then replace its Step event with:

```gml
if (!passed
&&  instance_exists(oPlayer)
&&  !oPlayer.is_dead
&&  bbox_right < oPlayer.bbox_left) {
    passed = true;

    // oPlayer remains the single source of truth for the live run score.
    oPlayer.obstacles_cleared += 1;
    oPlayer.obstacle_bonus    += oPlayer.points_per_obstacle;
    oPlayer.score              = oPlayer.distance_score + oPlayer.obstacle_bonus;
}
```

Using `bbox_right < oPlayer.bbox_left` is more accurate than the current `x < oPlayer.x`: the whole obstacle must be behind the player, regardless of sprite origin or scale. The `passed` flag still prevents duplicate awards.

### 5.3 Update `oPlayer` Step

The complete replacement below preserves the current movement and collision behavior. The new scoring section is immediately after forward movement.

```gml
if (!is_dead) {
    // 1. Jump input.
    if (input_jump_pressed() && on_ground) {
        vsp = jump_force;
        on_ground = false;
        audio_play_sound(aPlayerJump, 5, false);
    }

    // 2. Gravity.
    if (!on_ground) {
        vsp += grv;
    }

    // 3. Constant forward movement.
    x += hsp;

    // 4. Distance score. Obstacle bonuses are awarded by oDeath.
    distance_score = floor(max(0, x - xstart) / pixels_per_distance_point);
    score          = distance_score + obstacle_bonus;

    // 5. Horizontal collisions: death on an oSolid.
    if (place_meeting(x, y, oSolid)) {
        is_dead = true;
        vsp     = 0;
        hsp     = 0;

        if (running_sound_id != -1) {
            audio_stop_sound(running_sound_id);
            running_sound_id = -1;
        }

        audio_stop_sound(aForestAmbiance);
        audio_play_sound(sSpikeSound, 5, false);

        // oDeathMenu owns death music and submits the score once in Create.
        instance_create_layer(0, 0, "Instances", oDeathMenu);

        // Do not continue into movement/animation code and restart run audio
        // during this same Step event.
        exit;
    }

    // 6. Vertical movement.
    y += vsp;

    // 7. Vertical collisions with the generated ground.
    if (place_meeting(x, y, oGC)) {
        if (vsp > 0) {
            while (!place_meeting(x, y - 1, oGC)) {
                y -= 1;
            }
            vsp       = 0;
            on_ground = true;
        }
        else if (vsp < 0) {
            while (!place_meeting(x, y + 1, oGC)) {
                y += 1;
            }
            vsp = 0;
        }
    }
    else {
        on_ground = false;
    }

    // 8. Animation and running sound.
    if (!on_ground) {
        sprite_index = (vsp > 0) ? sFall : sJump;

        if (running_sound_id != -1 && audio_is_playing(running_sound_id)) {
            audio_stop_sound(running_sound_id);
            running_sound_id = -1;
        }
    }
    else {
        sprite_index = sRun;

        if (running_sound_id == -1 || !audio_is_playing(running_sound_id)) {
            running_sound_id = audio_play_sound(aPlayerRunning, 5, true);
        }
    }
}
```

The existing code starts death music both in `oPlayer` and in `oDeathMenu`, which can create two overlapping instances of the same sound. The replacement intentionally leaves death-music ownership in `oDeathMenu` only.

### 5.4 Replace `oPlayer` Draw GUI

```gml
if (!instance_exists(oDeathMenu)) {
    draw_set_font(fScore);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var _title   = player_name + "  |  SCORE " + string(score);
    var _details = "DIST " + string(distance_score)
                 + "   CLEARS " + string(obstacles_cleared)
                 + " x " + string(points_per_obstacle);
    var _padding = 12;
    var _width   = max(string_width(_title), string_width(_details));
    var _height  = string_height(_title) + string_height(_details) + 8;

    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_roundrect_ext(
        20 - _padding,
        20 - _padding,
        20 + _width + _padding,
        20 + _height + _padding,
        8, 8, false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(20, 20, _title);

    draw_set_color(make_color_rgb(180, 182, 190));
    draw_text(20, 20 + string_height(_title) + 6, _details);
}

draw_set_font(-1);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

## 6. Submit and display high scores after game over

### 6.1 Replace `oDeathMenu` Create

```gml
leaderboard_init();

selected_option  = 0;
final_name       = global.player_name;
final_score      = 0;
leaderboard_rank = 0;

// Snapshot the run. These values remain valid even if the player changes later.
if (instance_exists(oPlayer)) {
    final_name  = oPlayer.player_name;
    final_score = oPlayer.score;
}

// Create runs only once per death-menu instance, so this submits exactly once.
leaderboard_rank = leaderboard_submit(final_name, final_score);

audio_stop_sound(aPlayerRunning);
audio_stop_sound(aForestAmbiance);
audio_play_sound(aPlayerDeathMusic, 5, false);
```

Do not submit from Draw GUI or Step. Those events run repeatedly and would create duplicate rows.

### 6.2 Replace `oDeathMenu` Step

```gml
if (keyboard_check_pressed(vk_up)
||  keyboard_check_pressed(vk_down)
||  keyboard_check_pressed(ord("W"))
||  keyboard_check_pressed(ord("S"))) {
    selected_option = 1 - selected_option;
    audio_play_sound(aMainMenuOption, 10, false);
}

if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    audio_stop_sound(aPlayerRunning);
    audio_stop_sound(aForestAmbiance);
    audio_stop_sound(aPlayerDeathMusic);

    if (selected_option == 0) {
        room_restart();
    }
    else {
        room_goto(rMainMenu);
    }
}
```

Stopping `aPlayerDeathMusic` before changing rooms prevents it from overlapping the restarted forest ambience or main-menu music.

### 6.3 Replace `oDeathMenu` Draw GUI

```gml
var _gw   = display_get_gui_width();
var _gh   = display_get_gui_height();
var _cx   = _gw * 0.5;
var _gold = make_color_rgb(224, 184, 74);

draw_set_alpha(0.76);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);

draw_set_font(fScore);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(1);
draw_set_color(c_red);
draw_text_transformed(_cx, 42, "RUN ENDED", 2.2, 2.2, 0);

draw_set_color(c_white);
draw_text_transformed(
    _cx,
    96,
    final_name + "  -  " + string(final_score) + " POINTS",
    1.25, 1.25, 0
);

if (leaderboard_rank > 0) {
    draw_set_color(_gold);
    draw_text(_cx, 124, "NEW HIGH SCORE - RANK #" + string(leaderboard_rank));
}
else {
    draw_set_color(make_color_rgb(170, 172, 180));
    draw_text(_cx, 124, "THE HALL REMAINS UNCHANGED");
}

// Leave space for the two bottom buttons at any normal GUI height.
var _button_top = _gh - 82;
var _table_y    = 145;
var _row_h      = min(
    30,
    (_button_top - 15 - _table_y - 70)
        / (global.leaderboard_max_entries + 1)
);
var _table_w = min(680, _gw - 50);

leaderboard_draw_panel(
    _cx - _table_w * 0.5,
    _table_y,
    _table_w,
    _row_h,
    leaderboard_rank
);

draw_set_font(fScore);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _button_w = min(230, (_gw - 70) * 0.5);
var _gap      = 18;
var _left_x1  = _cx - _gap * 0.5 - _button_w;
var _right_x1 = _cx + _gap * 0.5;
var _bottom   = _gh - 24;

// Respawn button.
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_roundrect_ext(_left_x1, _button_top, _left_x1 + _button_w, _bottom, 9, 9, false);
draw_set_alpha(1);
draw_set_color(selected_option == 0 ? _gold : c_white);
draw_roundrect_ext(_left_x1, _button_top, _left_x1 + _button_w, _bottom, 9, 9, true);
draw_text((_left_x1 * 2 + _button_w) * 0.5, (_button_top + _bottom) * 0.5,
    selected_option == 0 ? "> RESPAWN <" : "RESPAWN");

// Main-menu button.
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_roundrect_ext(_right_x1, _button_top, _right_x1 + _button_w, _bottom, 9, 9, false);
draw_set_alpha(1);
draw_set_color(selected_option == 1 ? _gold : c_white);
draw_roundrect_ext(_right_x1, _button_top, _right_x1 + _button_w, _bottom, 9, 9, true);
draw_text((_right_x1 * 2 + _button_w) * 0.5, (_button_top + _bottom) * 0.5,
    selected_option == 1 ? "> MAIN MENU <" : "MAIN MENU");

draw_set_font(-1);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

`rRunner` already has an instance layer named `Instances`, so the existing `instance_create_layer(..., "Instances", oDeathMenu)` remains valid. No `oDeathMenu` room instance is needed because the player creates it at death.

## 7. Resource and event checklist

After implementing the guide, the relevant Asset Browser/event setup should be:

```text
Scripts
└── scr_leaderboard

oMainMenu
├── Create
├── Step
└── Draw GUI       (replace/remove the old normal Draw event)

oPlayer
├── Create
├── Step
└── Draw GUI

oDeath
├── Create          (passed = false)
└── Step

oDeathMenu
├── Create
├── Step
└── Draw GUI
```

Also verify these existing project details have not been renamed:

- The runner room is `rRunner`.
- The main-menu room is `rMainMenu`.
- The runner instance layer is `Instances`.
- `oDeath` remains a child of `oSolid`, because the player's death collision checks `oSolid`.
- `fScore` remains available. Its current glyph range covers ASCII 32–127, which matches the name filter.

## 8. Test in this order

1. **Clean launch:** delete no files manually; run the game with no prior JSON file. The menu should show an empty table without errors.
2. **Name validation:** select Start, erase the field, and press Enter. The modal should reject the empty name.
3. **Name filtering:** enter a name such as `Aegis-01`; it should be stored uppercase and displayed in the HUD.
4. **Cancel behavior:** open name entry and press Escape. The game must return to menu navigation without starting.
5. **Distance score:** start a run without clearing an obstacle and confirm the score rises as the player moves.
6. **Obstacle bonus:** clear one obstacle. `CLEARS` should increase by one and the score should gain exactly 100 bonus points.
7. **No duplicate obstacle award:** continue running after a clear. That same obstacle must not add another bonus.
8. **Game over submission:** die once. The death screen should show exactly one row for that run and highlight it.
9. **Respawn submission:** respawn, obtain another score, and die. There should now be exactly two submitted runs.
10. **Sorting and ties:** create scores above, below, and equal to existing scores. The list must remain descending; a newer tie should appear after older equal scores.
11. **Top-ten trimming:** create more than ten runs. Only the best ten should remain.
12. **Main-menu access:** return to `rMainMenu`, select High Scores, and confirm it matches the death-screen list.
13. **Persistence:** close and relaunch the game. The table and last accepted player name should reload.
14. **Audio transitions:** confirm there is one death track and that it stops on Respawn and Main Menu.
15. **Resolution check:** test both windowed and full-screen/output resolutions used by the project. Draw GUI elements should remain centered and independent of the scrolling runner camera.

## 9. Tuning and extension points

- Change `pixels_per_distance_point` in `oPlayer` Create to alter survival-score speed. A larger number awards points more slowly.
- Change `points_per_obstacle` in `oPlayer` Create to alter the clear bonus.
- Change `global.leaderboard_max_entries` in `leaderboard_init()` to change table size. The table drawing and trimming logic use this value automatically.
- To support non-ASCII names, expand `fScore`'s glyph ranges first, then relax `leaderboard_clean_name()` accordingly.
- The JSON is intentionally human-readable data, not cheat protection. For a competitive online board, calculate or validate scores on a server rather than trusting a client-written file.

## 10. GameMaker API references

- [Keyboard string input](https://manual.gamemaker.io/beta/en/GameMaker_Language/GML_Reference/Game_Input/Keyboard_Input/keyboard_string.htm)
- [JSON guide (`json_parse` and `json_stringify`)](https://manual.gamemaker.io/beta/en/Additional_Information/Guide_To_Using_JSON.htm)
- [Text-file reading](https://manual.gamemaker.io/lts/en/GameMaker_Language/GML_Reference/File_Handling/Text_Files/file_text_open_read.htm)
