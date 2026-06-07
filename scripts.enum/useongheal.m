inherits grtheal;

trigger creation {
	setObjVar(this, "magicItemBonus", 0x00);
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int magic_amount;
	int result = getResource(magic_amount, this, "magic", 0x03, 0x02);
	int charges = magic_amount / 0x0F;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	target_friendly_obj(user, this);
	return(0x00)}

trigger targetobj {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	if (!validate_spell_use(this, user, usedon, 0x00)) {
		return(0x00);
	}
	apply_greater_heal(user, usedon);
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x0F, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
