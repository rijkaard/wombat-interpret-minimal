inherits globals;

trigger use {
	int effect = random(0x01, 0x04);
	string effect_str = effect;
	if (!hasObjVar(user, "usedDespiseLvlOneAnkh")) {
		setObjVar(user, "usedDespiseLvlOneAnkh", effect);
		attachScript(user, "des1_ankh_user");
		doLocAnimation(getLocation(user), 0x373A, 0x01, 0x10, 0x00, 0x00);
		if ((effect == 0x01) || (effect == 0x04)) {
			setCurHP(user, getMaxHP(user));
			barkTo(user, user, "A sense of warmth fills your body!");
		}
		if ((effect == 0x02) || (effect == 0x04)) {
			setCurMana(user, getMaxMana(user));
			barkTo(user, user, "A feeling of power surges through your veins!");
		}
		if ((effect == 0x03) || (effect == 0x04)) {
			setCurFatigue(user, getMaxFatigue(user));
			barkTo(user, user, "You feel as though you've slept for days!");
		}
	}
	return(0x00);
}
