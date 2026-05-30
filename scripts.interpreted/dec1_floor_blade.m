inherits globals;

trigger message("saws_on") {
	if (!hasObjVar(this, "armed")) {
		setType(this, 0x11B2);
		setObjVar(this, "armed", 0x01);
		callback(this, 0x01, 0x24);
	}
	return(0x00);
}

trigger enterrange(0x01) {
	if (hasObjVar(this, "armed")) {
		loseHP(target, dice(0x0A, 0x14));
	}
	return(0x01);
}

trigger callback(0x24) {
	list players;
	getPlayersInRange(players, getLocation(this), 0x01);
	if (!numInList(players) == 0x00) {
		for (int i = 0x00; i < numInList(players); i++) {
			if (hasObjVar(this, "armed")) {
				loseHP(players[i], dice(0x0A, 0x14));
			}
		}
		callback(this, 0x01, 0x24);
		return(0x00);
	}
	clearList(players);
	getPlayersInRange(players, getLocation(this), 0x1E);
	if (numInList(players) == 0x00) {
		setType(this, 0x11B1);
		if (hasObjVar(this, "armed")) {
			removeObjVar(this, "armed");
		}
	} else {
		callback(this, 0x01, 0x24);
	}
	return(0x00);
}
