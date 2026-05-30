inherits globals;

trigger message("teleobj") {
	loc where = args[0x00];
	int height = getHeight(this);
	int movement_type = 0x01;
	if (isMobile(this)) {
		movement_type = getMovementType(this);
	}
	obj probe = createNoResObjectAt(0x01, getLocation(this));
	attachScript(probe, "telecheck");
	list f_args;
	appendToList(f_args, this);
	appendToList(f_args, where);
	appendToList(f_args, height);
	appendToList(f_args, movement_type);
	message(probe, "telecheck", f_args);
	return(0x01);
}

trigger message("telereply") {
	int ok = args[0x00];
	loc where = args[0x01];
	if (isPlayer(this)) {
		if (isDead(this)) {
			ok = 0x00;
		}
	}
	if (ok) {
		ok = teleport(this, where);
	}
	if (!ok) {
		if (isPlayer(this)) {
			systemMessage(this, "Something is blocking the location.");
		}
		detachScript(this, "teleobj");
	}
	return(0x01);
}

trigger callback(0x86) {
	detachScript(this, "teleobj");
	return(0x01);
}
