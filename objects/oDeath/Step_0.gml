if (!passed && instance_exists(oPlayer) && x < oPlayer.x) {
    oPlayer.points += 1;
    passed = true;
}