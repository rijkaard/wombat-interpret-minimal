inherits teleport;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int magic_amount;
	int result = getResource(magic_amount, this, "magic", 0x03, 0x02);
	int charges = magic_amount / 0x09;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	targetLoc(user, this);
	return(0x00);
}

trigger targetloc {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	cast_teleport(user, place);
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x09, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
