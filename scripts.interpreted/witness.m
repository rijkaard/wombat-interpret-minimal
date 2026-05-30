inherits globals;

function void cleanup() {
	removeObjVar(this, "lastCriminal");
	removeObjVar(this, "lastVictim");
	removeObjVar(this, "crimeSeverity");
	removeObjVar(this, "crimeLocation");
	detachScript(this, "witness");
	return();
}

function void try_call_guards() {
	loc crime_loc = getObjVar(this, "crimeLocation");
	obj criminal = getObjVar(this, "lastCriminal");
	if (getDistanceInTiles(getLocation(this), crime_loc) > 0x19) {
		if (isValid(criminal)) {
			if (getDistanceInTiles(getLocation(this), getLocation(criminal)) > 0x19) {
				return();
			}
		}
	}
	if (isValid(criminal)) {
		obj victim = getObjVar(this, "lastVictim");
		int severity = getObjVar(this, "crimeSeverity");
		callGuards(criminal, victim, severity);
	}
	cleanup();
	return();
}

trigger creation {
	callback(this, 0x1E, 0x58);
	return(0x00);
}

trigger speech("*guard*") {
	try_call_guards();
	return(0x00);
}

trigger callback(0x58) {
	cleanup();
	return(0x01);
}
