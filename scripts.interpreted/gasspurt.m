inherits sndfx;

trigger 0x03E8 enterrange(0x03) {
	if (isPlayer(target)) {
		obj player = target;
		loc player_loc = getLocation(player);

member loc spawn_loc = getLocation(this);

member obj gas_effect = requestCreateObjectAt(0x11A6, spawn_loc);
		sfx(spawn_loc, 0x0108, 0x0107);
	}
	return(0x01);
}

trigger 0xFA enterrange(0x01) {
	if (isPlayer(target)) {
		setPoisoned(target, 0x01);
		attachScript(target, "poisoned");
	}
	return(0x01)}

trigger 0x03E8 enterrange(0x01) {
	if (isPlayer(target)) {
		int damage = random(0x01, 0x0A);
		loc spawn_loc = getLocation(this);
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
		loc player_loc = getLocation(target);
		obj player = target;
		doDamage(player, player, 0x1E);
		sfx(player_loc, 0x014C, 0x014C);
		setPoisoned(player, 0x01);
		attachScript(player, "poisoned");
	}
	return(0x00)}

trigger 0x03E8 leaverange(0x03) {
	deleteObject(gas_effect);
	return(0x01);
}
