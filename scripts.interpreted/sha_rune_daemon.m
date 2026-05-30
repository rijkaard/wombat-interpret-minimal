inherits globals;

trigger speech("godStart") {
	callback(this, 0x02, 0x24);
	return(0x00);
}

trigger creation {
	callback(this, 0x02, 0x24);
	setType(this, 0x01);
	return(0x00);
}

trigger objectloaded {
	callback(this, 0x02, 0x24);
	return(0x00);
}

trigger callback(0x24) {
	list f_args;
	messageToRange(getLocation(this), 0x03, "switchType", f_args);
	callback(this, 0x02, 0x24);
	return(0x00);
}
