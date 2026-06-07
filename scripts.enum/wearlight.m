inherits spelskil;

member int saved_light_val;

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
	if (use_charge()) {
		saved_light_val = getLightVal(equippedon);
		setLight(equippedon, 0x0F, 0x01);
	} else {
		setLight(equippedon, saved_light_val, 0x01);
		detachScript(this, "wearlight");
	}
	return(0x01);
}

trigger unequip {
	setLight(unequippedfrom, saved_light_val, 0x01);
	return(0x01);
}

trigger time("min:*0") {
	if (isEquipped(this)) {
		if (!use_charge()) {
			setLight(containedBy(this), saved_light_val, 0x01);
			detachScript(this, "wearlight");
		}
	}
	return(0x01);
}
