inherits globals;

trigger enterrange(0x03) {
	string msg = "Beware Ye Who Enter These Halls!";
	list f_args = msg;
	if (!hasObjVar(this, "working")) {
		if (!hasObjVar(target, "CovetousListenToStatueSpeak")) {
			setObjVar(this, "working", 0x01);
			callback(this, 0x19, 0x24);
			bark(this, msg);
			messageToRange(getLocation(this), 0x05, "barknow", f_args);
			setObjVar(target, "CovetousListenToStatueSpeak", 0x01);
		}
	}
	return(0x01);
}

trigger callback(0x24) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	return(0x00);
}

trigger speech("resetme") {
	if (hasObjVar(speaker, "CovetousListenToStatueSpeak")) {
		removeObjVar(speaker, "CovetousListenToStatueSpeak");
	}
	return(0x00);
}
