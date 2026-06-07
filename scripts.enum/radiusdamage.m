inherits sndfx;

function Q6AA();

trigger creation {
	callback(this, 0x14, 0x95);
	return(0x01);
}

trigger callback(0x95) {
	list mobs;
	getMobsInRange(mobs, getLocation(this), 0x0A);
	int x = numInList(mobs);
	while (x != 0x00) {
		x--;
		obj obj_reveal = mobs[x];
		if (isPlayer(obj_reveal)) {
			Q6AA(obj_reveal);
		}
		;
		;
	}
	;
	callback(this, 0x14, 0x95);
	return(0x00);
}
