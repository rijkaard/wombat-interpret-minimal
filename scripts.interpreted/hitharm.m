inherits harmbase;

trigger creation {
	setObjVar(this, "magicItemDamage", 0x06);
	shortcallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	int magic_amount;
	int result = getResource(magic_amount, this, "magic", 0x03, 0x02);
	int charges = magic_amount / 0x06;
	setObjVar(this, "charges", charges);
	return(0x01);
}

trigger ishitting {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		return(0x01);
	}
	obj owner = getTopmostContainer(this);
	if (hasScript(victim, "reflctor")) {
		doMobAnimation(victim, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
		apply_harm(victim, owner, 0x01);
		detachScript(victim, "reflctor");
	} else {
		apply_harm(owner, victim, 0x00);
	}
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x06, "magic");
	if (charges <= 0x00) {
		systemMessage(owner, "This magic item is out of charges.");
	}
	return(0x01);
}
