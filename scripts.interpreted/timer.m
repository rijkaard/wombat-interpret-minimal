inherits globals;

trigger message("activate") {
	if (hasObjVar(this, "time1")) {
		int time1 = getobjvar_int(this, "time1");
		if (!hasObjVar(this, "running")) {
			int running_state = 0x00;
			setObjVar(this, "running", running_state);
			if (hasObjVar(this, "count")) {
				int count = getobjvar_int(this, "count");
				setObjVar(this, "tempCount", count);
			}
			callback(this, time1, 0x2F);
			return(0x00);
		}
	}
	return(0x00);
}

trigger message("deactivate") {
	if (hasObjVar(this, "running")) {
		removeObjVar(this, "running");
	}
	return(0x00);
}

trigger callback(0x2F) {
	int time1;
	list args;
	if (hasObjVar(this, "running")) {
		int phase = getobjvar_int(this, "running");
		if (phase == 0x00) {
			processTriggerCmds(this, "a");
			if (hasObjVar(this, "time2")) {
				int time2 = getobjvar_int(this, "time2");
				phase = 0x01;
				setObjVar(this, "running", phase);
				callback(this, time2, 0x2F);
			} else {
				time1 = getobjvar_int(this, "time1");
				callback(this, time1, 0x2F);
			}
		} else {
			processTriggerCmds(this, "d");
			time1 = getobjvar_int(this, "time1");
			phase = 0x00;
			setObjVar(this, "running", phase);
			callback(this, time1, 0x2F);
		}
	}
	if (hasObjVar(this, "tempCount")) {
		int tempCount = getobjvar_int(this, "tempCount");
		if (tempCount > 0x01) {
			tempCount--;
			setObjVar(this, "tempCount", tempCount);
		} else {
			removeObjVar(this, "tempCount");
			message(this, "deactivate", args);
		}
	}
	return(0x00);
}

trigger enterrange(0x07) {
	if (isPlayer(target)) {
		if (!hasObjVar(this, "noAuto") && !hasObjVar(this, "running")) {
			list args;
			message(this, "activate", args);
		}
	}
	return(0x01);
}

trigger leaverange(0x07) {
	if (!hasObjVar(this, "noAuto") && hasObjVar(this, "running")) {
		if (isPlayer(target)) {
			list nearby_players;
			getPlayersInRange(nearby_players, getLocation(this), 0x06);
			if (numInList(nearby_players) == 0x00) {
				list args;
				message(this, "deactivate", args);
			}
		}
	}
	return(0x01);
}

trigger creation {
	if (!hasObjVar(this, "noAuto") && !hasObjVar(this, "running")) {
		list nearby_players;
		getPlayersInRange(nearby_players, getLocation(this), 0x06);
		if (numInList(nearby_players) > 0x00) {
			list args;
			message(this, "activate", args);
		}
	}
	return(0x00);
}
