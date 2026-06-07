inherits lightngbase;

trigger creation {
	setObjVar(this, "magicItemDamage", 0x04);
	shortcallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	int raw_magic;
	int result = getResource(raw_magic, this, "magic", 0x03, 0x02);
	int charges = raw_magic / 0x0F;
	setObjVar(this, "charges", charges);
	return(0x01);
}

trigger ishitting {
	int charges = getObjVar(this, "charges");
	if (charges <= 0x00) {
		return(0x01);
	}
	obj wielder = getTopmostContainer(this);
	if (charges > 0x00) {
		if (hasScript(victim, "reflctor")) {
			doMobAnimation(victim, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
			cast_lightning(victim, wielder, 0x01);
			detachScript(victim, "reflctor");
		} else {
			cast_lightning(wielder, victim, 0x00);
		}
		charges = charges - 0x01;
		setObjVar(this, "charges", charges);
		returnResourcesToBank(this, 0x0F, "magic");
	} else {
		systemMessage(wielder, "This magic item is out of charges.");
	}
	return(0x01);
}
