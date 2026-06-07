inherits potion;

trigger use {
	if (!start_drink(user)) {
		return(0x00);
	}
	setInvisible(user, 0x00);
	int cur_fatigue = getCurFatigue(user);
	int max_fatigue = getMaxFatigue(user);
	int restore_amt = 0xFA;
	if (hasObjVar(this, "power")) {
		restore_amt = getObjVar(this, "power");
	}
	restore_amt = (max_fatigue - cur_fatigue) * restore_amt / 0x03E8;
	if ((cur_fatigue + restore_amt) < max_fatigue) {
		addFatigue(user, restore_amt);
	} else {
		setCurFatigue(user, max_fatigue);
	}
	obj empty_bottle = createGlobalObjectOn(this, 0x0F0E);
	deleteObject(this);
	return(0x00);
}
