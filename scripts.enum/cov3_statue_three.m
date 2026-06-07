inherits globals;

trigger enterrange(0x03) {
	string bark_msg = "Go no farther, lest ye face thy death!";
	list f_args = bark_msg;
	if (!hasObjVar(this, "working")) {
		if (!hasObjVar(target, "CovetousListenToStatueSpeakTwo")) {
			setObjVar(this, "working", 0x01);
			callback(this, 0x19, 0x24);
			bark(this, bark_msg);
			messageToRange(getLocation(this), 0x05, "barknow", f_args);
			setObjVar(target, "CovetousListenToStatueSpeakTwo", 0x01);
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
	if (hasObjVar(speaker, "CovetousListenToStatueSpeakTwo")) {
		removeObjVar(speaker, "CovetousListenToStatueSpeakTwo");
	}
	return(0x00);
}
