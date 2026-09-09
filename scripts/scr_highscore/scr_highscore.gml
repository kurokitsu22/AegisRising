function save_highscore_if_beaten() {
    if (instance_exists(oPlayer)) {
        if (oPlayer.points > global.highscore) {
            global.highscore = oPlayer.points;
            ini_open("save.ini");
            ini_write_real("Data", "HighScore", global.highscore);
            ini_close();
        }
    }
}