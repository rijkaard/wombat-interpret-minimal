inherits spelskil;

trigger creation {
	shortcallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	int amount;
	int result = getResource(amount, this, "magic", 0x03, 0x02);
	int charges = amount / 0x03;
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
	if (equippedon == NULL()) {
		return(0x01);
	}
	if (use_charge()) {
		attachScript(equippedon, "reflctor");
	} else {
		detachScript(this, "wearrflct");
	}
	return(0x01);
}

trigger unequip {
	detachScript(unequippedfrom, "reflctor");
	return(0x01);
}

trigger time("min:**") {
	if (isEquipped(this)) {
		obj wearer = containedBy(this);
		if (wearer == NULL()) {
			return(0x01);
		}
		if (!use_charge()) {
			detachScript(wearer, "reflctor");
			detachScript(this, "wearrflct");
		} else {
			attachScript(wearer, "reflctor");
		}
	}
	return(0x01);
}
