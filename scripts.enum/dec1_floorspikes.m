inherits globals;

trigger creation {
	setType(this, 0x11A1);
	return(0x00);
}

trigger enterrange(0x00) {
	list targets;
	if (!hasObjVar(this, "disarmed")) {
		loseHP(target, dice(0x14, 0x05));
	}
	return(0x01);
}

trigger message("fs_disarm") {
	int val;
	if (!hasObjVar(this, "disarmed")) {
		setType(this, 0x11A0);
		setObjVar(this, "disarmed", val);
	}
	return(0x00);
}

trigger message("fs_reload") {
	int flag;
	if (hasObjVar(this, "disarmed")) {
		setType(this, 0x11A1);
		removeObjVar(this, "disarmed");
	}
	return(0x00);
}
