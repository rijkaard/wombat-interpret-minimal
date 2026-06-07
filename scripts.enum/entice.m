inherits sk_table;

trigger creation {

member int state = 0x00;

member int badSound;

member int goodSound;
	return(0x00);
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "entice");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	if (hasObjVar(this, "lastInstrument")) {
		obj instrument = getObjVar(this, "lastInstrument");
		if (hasObj(this, instrument)) {
			goodSound = getObjVar(instrument, "goodSound");
			badSound = getObjVar(instrument, "badSound");
			systemMessage(this, "Whom do you wish to entice?");
			state = 0x02;
			targetObj(this, this);
			return(0x00);
		}
	}
	systemMessage(this, "What instrument shall you play?");
	state = 0x01;
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int max_range;
	switch(state) {
	case 0x01
		max_range = 0x02;
		break;
	case 0x02
		max_range = 0x10;
		break;
	default
		max_range = 0x00;
		break;
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > max_range) {
		systemMessage(user, "You cannot do that at such a distance!");
		return(0x00);
	}
	if (!canSeeObj(this, usedon)) {
		systemMessage(user, "You can't see that.");
		return(0x00);
	}
	if (state == 0x01) {
		if (!hasObjVar(usedon, "isInstrument")) {
			systemMessage(user, "That is not a musical instrument.");
			state = 0x00;
			return(0x00);
		}
		state = 0x02;
		setObjVar(user, "lastInstrument", usedon);
		badSound = getObjVar(usedon, "badSound");
		goodSound = getObjVar(usedon, "goodSound");
		systemMessage(user, "Whom do you wish to entice?");
		targetObj(user, this);
		return(0x00);
	}
	if (!isNPC(usedon) && (!isPlayer(usedon))) {
		barkTo(usedon, user, "You cannot entice that!");
		return(0x00);
	}
	if (usedon == user) {
		barkTo(usedon, user, "You cannot entice yourself!");
		return(0x00);
	}
	if (!testSkill(user, SKILL_ENTICEMENT)) {
		sfx(getLocation(user), badSound, 0x3C);
		barkTo(usedon, usedon, "You hear lovely music, and for a moment are drawn towards it.");
		barkTo(usedon, user, "Your music fails to attract them.");
		return(0x00);
	}
	sfx(getLocation(user), badSound, 0x3C);
	if (isPlayer(usedon)) {
		barkTo(usedon, usedon, "You hear lovely music, and are drawn towards it...");
	}
	if (isHuman(usedon)) {
		bark(usedon, "What am I hearing?");
	}
	barkTo(user, user, "You play your hypnotic music, luring them near.");
	if (isGuard(usedon)) {
		barkTo(usedon, user, "They look too dedicated to their job to be lured away.");
		return(0x00);
	}
	if (hasScript(usedon, "vendor")) {
		barkTo(usedon, user, "They look too dedicated to their job to be lured away.");
		return(0x00);
	}
	if (isPlayer(usedon)) {
		barkTo(usedon, user, "You might have better luck with sweet words.");
		return(0x00);
	}
	setObjVar(usedon, "enticer", user);
	setObjVar(usedon, "enticed", usedon);
	attachScript(usedon, "enticepathfind");
	walkTo(usedon, getLocation(user), 0x01);
	if (isShopkeeper(usedon)) {
		bark(usedon, "Oh, but I cannot wander too far from my shop!");
		shortCallback(usedon, 0x01, 0x0C);
	}
	return(0x00);
}
