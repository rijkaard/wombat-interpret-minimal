inherits globals;

trigger enterrange(0x03) {
	string peace_msg = "An overwhelming sense of peace fills you.");
	barkTo(this, target, peace_msg);
	return(0x01);
}

trigger use {
	int roll = random(0x01, 0x04);
	string roll_str = roll;
	if (!hasObjVar(user, "usedDespiseLvlOneAnkh")) {
		setObjVar(user, "usedDespiseLvlOneAnkh", roll);
		attachScript(user, "des1_ankh_user");
		doLocAnimation(getLocation(user), 0x373A, 0x01, 0x10, 0x00, 0x00);
		if ((roll == 0x01) || (roll == 0x04)) {
			setCurHP(user, getMaxHP(user));
			barkTo(user, user, "A sense of warmth fills your body!");
		}
		if ((roll == 0x02) || (roll == 0x04)) {
			setCurMana(user, getMaxMana(user));
			barkTo(user, user, "A feeling of power surges through your veins!");
		}
		if ((roll == 0x03) || (roll == 0x04)) {
			setCurFatigue(user, getMaxFatigue(user));
			barkTo(user, user, "You feel as though you've slept for days!");
		}
	}
	return(0x00);
}
