inherits globals;

function void register_camper(obj player) {
	if (!hasObjVar(player, "campFireId")) {
		setObjVar(player, "campFireId", this);
		setObjVar(player, "timeInCamp", 0x00);
		attachScript(player, "removecamping");
		callback(player, 0x01F4, 0x5F);
	}
	return();
}

function void unregister_camper(obj player) {
	if (!hasObjVar(player, "campFireId")) {
		return();
	}
	obj campFireId = getObjVar(player, "campFireId");
	if (campFireId == this) {
		removeObjVar(player, "campFireId");
		removeObjVar(player, "timeInCamp");
		detachScript(player, "removecamping");
	}
	return();
}

trigger creation {
	list players;
	getPlayersInRange(players, getLocation(this), 0x07);
	for (int i = 0x00; i < numInList(players); i++) {
		register_camper(players[i]);
	}
	callBack(this, 0x02, 0x8E);
	return(0x01);
}

trigger objectloaded {
	list players;
	getPlayersInRange(players, getLocation(this), 0x07);
	for (int i = 0x00; i < numInList(players); i++) {
		register_camper(players[i]);
	}
	callBack(this, 0x02, 0x8E);
	return(0x01);
}

trigger enterrange(0x07) {
	if (isPlayer(target)) {
		register_camper(target);
	}
	return(0x01);
}

trigger leaverange(0x07) {
	if (isPlayer(target)) {
		unregister_camper(target);
	}
	return(0x01);
}

trigger callback(0x8E) {
	list players;
	int count;
	int i;
	loc camp = getLocation(this);
	int timer = 0x01;
	if (hasObjVar(this, "campfire_burning")) {
		timer = getObjVar(this, "campfire_burning");
	}
	timer = timer + 0x01;
	setObjVar(this, "campfire_burning", timer);
	callBack(this, 0x02, 0x8E);
	int campfire = getObjType(this);
	int burning = 0x0DE3;
	int smoldering = 0x0DE9;
	int ash = 0x0DEA;
	if ((timer > 0x1E) && (campfire == burning)) {
		setType(this, smoldering);
		return(0x00);
	}
	if ((timer > 0x2D) && (campfire == smoldering)) {
		setType(this, ash);
		getPlayersInRange(players, camp, 0x07);
		for (i = 0x00; i < numInList(players); i++) {
			unregister_camper(players[i]);
		}
		return(0x00);
	}
	if ((timer > 0x32) && (campfire == ash)) {
		deleteObject(this);
		return(0x00);
	}
	getPlayersInRange(players, camp, 0x07);
	for (i = 0x00; i < numInList(players); i++) {
		if (hasObjVar(players[i], "campFireId")) {
			obj campFireId = getObjVar(players[i], "campFireId");
			if (campFireId == this) {
				if (hasObjVar(players[i], "timeInCamp")) {
					int timeInCamp = getObjVar(players[i], "timeInCamp");
					if (timeInCamp == 0x00) {
						systemMessage(players[i], "You feel it would take a few moments to secure your camp.");
					}
					if (timeInCamp == 0x0F) {
						systemMessage(players[i], "The camp is now secure.");
					}
					timeInCamp++;
					setObjVar(players[i], "timeInCamp", timeInCamp);
				}
			}
		}
	}
	return(0x00);
}
