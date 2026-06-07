inherits cunning;

trigger creation {
	setObjVar(this, "magicItemModifier", 0x04);
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int amount;
	int result = getResource(amount, this, "magic", 0x03, 0x02);
	int charges = amount / 0x06;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	apply_cunning_effect(user, user, 0x00);
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x06, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
