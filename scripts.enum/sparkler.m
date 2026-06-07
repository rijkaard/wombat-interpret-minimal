inherits globals;

member int state;

member int fuel;

member loc dest;

trigger creation {
	state = 0x00;
	fuel = 0x64;
	return(0x00);
}

function void launch_firework() {
	loc launch_loc = getLocation(this);
	changeLoc(launch_loc, 0x00, 0x00, 0x0A);
	dest = launch_loc;
	changeLoc(dest, random(0x00 - 0x02, 0x02), random(0x00 - 0x02, 0x02), 0x20);
	doMissile_Loc2Loc(launch_loc, dest, 0x36E4, 0x05, 0x00, 0x00);
	shortCallback(this, 0x03, 0x2F);
	state = 0x01;
	return();
}

trigger use {
	if (state == 0x00) {
		systemMessage(user, "You launch a firework!");
		state = 0x01;
		launch_firework();
		return(0x00);
	}
	systemMessage(user, "Wait until the one in the air has exploded first.");
	return(0x00);
}

trigger callback(0x2F) {
	state = 0x00;
	int anim_id = 0x373A + (0x10 * random(0x00, 0x03));
	doLocAnimation(dest, anim_id, 0x0A, 0x10, 0x00, 0x00);
	fuel--;
	string desc = fuel;
	desc = "a fireworks wand with " + desc + " charges.";
	setObjVar(this, "lookAtText", desc);
	if (fuel < 0x00) {
		deleteObject(this);
		return(0x00);
	}
	return(0x00);
}
