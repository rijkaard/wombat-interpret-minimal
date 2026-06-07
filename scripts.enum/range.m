trigger enterrange(0x03) {
	int actret = 0x01;
	if (isPlayer(target)) {
		if (hasObjVar(this, "actret")) {
			actret = getobjvar_int(this, "actret");
		}
		if (hasObjVar(this, "acttext")) {
			string acttext = getobjvar_str(this, "acttext");
			bark(this, acttext);
		}
		processTriggerCmds(this, "a");
	}
	return(actret);
}

trigger leaverange(0x03) {
	int deactret = 0x01;
	if (isPlayer(target)) {
		if (hasObjVar(this, "deactret")) {
			deactret = getobjvar_int(this, "deactret");
		}
		if (hasObjVar(this, "deacttext")) {
			string deacttext = getobjvar_str(this, "deacttext");
			bark(this, deacttext);
		}
		processTriggerCmds(this, "d");
	}
	return(deactret);
}

function void init_range_triggers(obj this) {
	int result;
	if (hasObjVar(this, "act")) {
		int act = getobjvar_int(this, "act");
		result = changeRange(this, 0x00, 0x03, act);
	}
	if (hasObjVar(this, "deact")) {
		int deact = getobjvar_int(this, "deact");
		result = changeRange(this, 0x01, 0x03, deact);
	}
	return;
}

trigger creation {
	init_range_triggers(this);
	return(0x00);
}

trigger objectloaded {
	init_range_triggers(this);
	return(0x00);
}
