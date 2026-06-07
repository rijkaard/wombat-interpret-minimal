inherits sndfx;

trigger 0x03E8 enterrange(0x03) {
	if (isPlayer(target)) {
		obj player = target;
		loc player_loc = getLocation(player);

member loc spurt_loc = getLocation(this);

member obj fire_obj = requestCreateObjectAt(0x3709, spurt_loc);
		sfx(spurt_loc, 0x011D, 0x011D);
	}
	return(0x01);
}

trigger 0x03E8 enterrange(0x01) {
	if (isPlayer(target)) {
		int damage = random(0x01, 0x0A);
		loc spurt_loc = getLocation(this);
		obj player = target;
		loc player_loc = getLocation(player);
		doDamage(player, player, damage);
		sfx(player_loc, 0x014C, 0x014C);
		animateMobile(player, 0x14, 0x01, 0x01, 0x00, 0x00);
	}
	return(0x01)}

trigger 0x03E8 enterrange(0x00) {
	if (isPlayer(target)) {
		int damage = random(0x01, 0x1E);
		obj player = target;
		loc player_loc = getLocation(player);
		doDamage(player, player, damage);
		sfx(player_loc, 0x014C, 0x014C);
	}
	return(0x00)}

trigger 0x03E8 leaverange(0x03) {
	deleteObject(fire_obj);
	return(0x01);
}
