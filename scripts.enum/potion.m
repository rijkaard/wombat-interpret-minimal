inherits spelskil;

member int delay_ticks;

member int stat_type;

member int gold_amount_str;

trigger creation {
	if (delay_ticks == 0x00) {
		delay_ticks = 0x1E;
	}
	if (gold_amount_str == 0x00) {
		gold_amount_str = 0x0F;
	}
	return(0x01);
}

function int start_drink(obj user) {
	if (!getFreeHandSlot(user)) {
		systemMessage(user, "You must have a free hand to drink a potion.");
		return(0x00);
	}
	if (random(0x00, 0x01) == 0x01) {
		sfx(getLocation(user), 0x30, 0x00);
	} else {
		sfx(getLocation(user), 0x31, 0x00);
	}
	animateMobile(user, 0x21, 0x02, 0x01, 0x00, 0x01);
	return(0x01);
}

trigger use {
	int power = gold_amount_str;
	if (hasObjVar(this, "power")) {
		power = getObjVar(this, "power");
	}
	if (!start_drink(user)) {
		return(0x00);
	}
	setInvisible(user, 0x00);
	if (!apply_stat_effect_if_absent(user, stat_type, power, delay_ticks)) {
		systemMessage(user, "You are already under a similar effect.");
	} else {
		doMobAnimation(user, 0x375A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(getLocation(user), get_stat_effect_sfx_id(stat_type, power), 0x00);
		obj empty_bottle = createGlobalObjectOn(this, 0x0F0E);
		deleteObject(this);
	}
	return(0x00);
}
