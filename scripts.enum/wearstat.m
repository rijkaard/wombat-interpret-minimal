inherits spelskil;

member int str_mod;

member int dex_mod;

member int int_mod;

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

function void on_charges_expired(obj it) {
	debugMessage("Error!  womfunc meant as pure virtual called!");
	return();
}

function int use_charge() {
	int charges = 0x00;
	if (hasObjVar(this, "charges")) {
		charges = getObjVar(this, "charges");
	}
	if (charges <= 0x00) {
		removeObjVar(this, "charges");
	} else {
		setObjVar(this, "charges", charges - 0x01);
		returnResourcesToBank(this, 0x03, "magic");
	}
	return(charges);
}

function void apply_stat_modifiers(obj it, int add) {
	int str_delta = str_mod;
	int da = dex_mod;
	int int_delta = int_mod;
	if (!add) {
		str_delta = 0x00 - str_mod;
		da = 0x00 - dex_mod;
		int_delta = 0x00 - int_mod;
	}
	apply_stat_mod(it, STAT_STR, str_delta);
	apply_stat_mod(it, STAT_DEX, da);
	apply_stat_mod(it, STAT_INT, int_delta);
	return();
}

trigger equip {
	if (use_charge()) {
		apply_stat_modifiers(equippedon, 0x01);
	} else {
		on_charges_expired(this);
	}
	return(0x01);
}

trigger unequip {
	apply_stat_modifiers(unequippedfrom, 0x00);
	return(0x01);
}

trigger time("min:*0") {
	if (isEquipped(this)) {
		obj it = containedBy(this);
		if (!use_charge()) {
			apply_stat_modifiers(it, 0x00);
			on_charges_expired(this);
		}
	}
	return(0x01);
}
