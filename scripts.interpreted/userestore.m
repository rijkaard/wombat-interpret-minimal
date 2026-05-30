inherits globals;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int amount;
	int result = getResource(amount, this, "magic", 0x03, 0x02);
	int charges = amount / 0x0A;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	int restore_amt = random(0x01, 0x32);
	int cur_fatigue = getCurFatigue(user);
	int max_fatigue = getMaxFatigue(user);
	if (max_fatigue < (restore_amt + cur_fatigue)) {
		setCurFatigue(user, max_fatigue);
	} else {
		setCurFatigue(user, restore_amt + cur_fatigue);
	}
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x0A, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
