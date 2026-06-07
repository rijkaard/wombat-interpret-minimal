inherits identify;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int magic_val;
	int result = getResource(magic_val, this, "magic", 0x03, 0x02);
	int charges = magic_val / 0x01;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	targetObj(user, this);
	return(0x00);
}

trigger oortargetobj {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	if (!validate_spell_use(this, user, usedon, 0x00)) {
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		systemMessage(user, "You can't see that object well enough to identify it.");
		return(0x00);
	}
	string item_name = identify_item(user, usedon);
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x0F, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
