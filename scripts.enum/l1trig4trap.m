trigger message("trapCheck") {
	list players;
	int damage;
	if (!hasObjVar(this, "disarmed")) {
		getPlayersInRange(players, getLocation(this), 0x03);
		for (int i = 0x00; i < numInList(players); i++) {
			damage = dice(0x03, 0x05);
			setCurHP(players[i], getCurHP(players[i]) - damage);
		}
	}
	return(0x00);
}

trigger message("PPdisarm") {
	int disarm_val;
	if (!hasObjVar(this, "disarmed")) {
		setObjVar(this, "disarmed", disarm_val);
	}
	return(0x00);
}

trigger message("PPreload") {
	if (hasObjVar(this, "disarmed")) {
		removeObjVar(this, "disarmed");
	}
	return(0x00);
}
