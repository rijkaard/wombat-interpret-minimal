inherits spelskil;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	int magic_amount;
	int result = getResource(magic_amount, this, "magic", 0x03, 0x02);
	int charges = magic_amount / 0x03;
	setObjVar(this, "charges", charges);
	return(0x01);
}

function int use_charge() {
	int charges = getObjVar(this, "charges");
	returnResourcesToBank(this, 0x03, "magic");
	if (charges <= 0x00) {
		removeObjVar(this, "charges");
	} else {
		setObjVar(this, "charges", charges - 0x01);
	}
	return(charges);
}

trigger equip {
	if (use_charge()) {
		addSkillLevel(equippedon, 0x05, 0x64);
	} else {
		detachScript(this, "wearprtct");
	}
	return(0x01);
}

trigger unequip {
	loseSkillLevel(unequippedfrom, 0x05, 0x64);
	return(0x01);
}

trigger time("min:*0") {
	if (isEquipped(this)) {
		if (!use_charge()) {
			loseSkillLevel(containedBy(this), 0x05, 0x64);
			detachScript(this, "wearprtct");
		}
	}
	return(0x01);
}
