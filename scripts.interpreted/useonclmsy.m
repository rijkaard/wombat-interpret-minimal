inherits clumsy;

trigger creation {
	setObjVar(this, "magicItemModifier", 0x04);
	shortcallback(this, 0x01, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	int amount;
	int result = getResource(amount, this, "magic", 0x03, 0x02);
	int charges = amount / 0x03;
	setObjVar(this, "charges", charges);
	return(0x00);
}

trigger use {
	target_hostile_obj(user, this);
	return(0x00);
}

trigger targetobj {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
		return(0x00);
	}
	if (!validate_spell_use(this, user, usedon, 0x00)) {
		return(0x00);
	}
	if (hasScript(usedon, "reflctor")) {
		doMobAnimation(usedon, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
		apply_clumsy_effect(usedon, user, 0x01);
		detachScript(usedon, "reflctor");
	} else {
		apply_clumsy_effect(user, usedon, 0x00);
	}
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x03, "magic");
	if (charges <= 0x00) {
		systemMessage(user, "This magic item is out of charges.");
	}
	return(0x00);
}
