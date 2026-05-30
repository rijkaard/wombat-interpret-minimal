inherits manadranbase;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	int amount;
	int ret = getResource(amount, this, "magic", 0x03, 0x02);
	int charges = amount / 0x0F;
	setObjVar(this, "charges", charges);
	return(0x01);
}

trigger ishitting {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		return(0x01);
	}
	obj wielder = getTopmostContainer(this);
	if (hasScript(victim, "reflctor")) {
		doMobAnimation(victim, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
		apply_mana_drain(victim, wielder, 0x01);
		detachScript(victim, "reflctor");
	} else {
		apply_mana_drain(wielder, victim, 0x00);
	}
	charges = charges - 0x01;
	setObjVar(this, "charges", charges);
	returnResourcesToBank(this, 0x0F, "magic");
	if (charges <= 0x00) {
		systemMessage(wielder, "This magic item is out of charges.");
	}
	return(0x01);
}
