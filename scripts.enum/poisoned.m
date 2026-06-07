inherits spelskil;

member int callback_delay;

member int ticks_remaining;

member int strength;

member int damage_per_tick;

member int current_hp;

function void apply_poison_effect(obj victim, int strength) {
	current_hp = getCurHP(victim);
	switch(strength) {
	case 0x01
		actionBark(victim, 0x21, "* You feel a bit nauseous... *", "* " + getName(victim) + " looks ill. *");
		damage_per_tick = current_hp / 0x14;
		break;
	case 0x02
		actionBark(victim, 0x21, "* You feel disoriented and nauseous! *", "* " + getName(victim) + " looks extremely ill. *");
		damage_per_tick = current_hp / 0x0F;
		callback_delay = 0x0A;
		break;
	case 0x03
		actionBark(victim, 0x21, "* You begin to feel pain throughout your body! *", "* " + getName(victim) + " stumbles around in confusion and pain. *");
		damage_per_tick = current_hp / 0x08;
		callback_delay = 0x0A;
		break;
	case 0x04
		actionBark(victim, 0x21, "* You feel extremely weak and are in severe pain! *", "* " + getName(victim) + " is wracked with extreme pain. *");
		damage_per_tick = current_hp / 0x04;
		callback_delay = 0x05;
		break;
	case 0x05
		actionBark(victim, 0x21, "* You are in extreme pain, and require immediate aid! *", "* " + getName(victim) + " begins to spasm uncontrollably. *");
		damage_per_tick = current_hp / 0x02;
		callback_delay = 0x05;
		break;
	}
	return();
}

function int check_poison_active(obj victim) {
	if (isDead(this)) {
		return(0x00);
	}
	if (!hasObjVar(this, "poison_strength")) {
		setObjVar(this, "poison_strength", 0x01);
		return(0x01);
	}
	if (getCurHP(this) < 0x00) {
		return(0x00);
	}
	return(0x01);
}

trigger creation {
	if (!check_poison_active(this)) {
		cure_poison(this);
		return(0x00);
	}
	strength = getObjVar(this, "poison_strength");
	setPoisoned(this, 0x01);
	callback_delay = 0x0F;
	apply_poison_effect(this, strength);
	ticks_remaining = (random(0x0A, 0x14) * strength);
	callBack(this, callback_delay, 0x53);
	return(0x01);
}

trigger callback(0x53) {
	if (!check_poison_active(this)) {
		cure_poison(this);
		return(0x00);
	}
	ticks_remaining--;
	if (ticks_remaining < 0x01) {
		systemMessage(this, "The poison seems to have worn off.");
		cure_poison(this);
		return(0x00);
	}
	doDamageType(NULL(), this, (damage_per_tick + 0x02), 0x08);
	if (!check_poison_active(this)) {
		cure_poison(this);
		return(0x00);
	} else {
		if (!random(0x00, 0x02)) {
			strength = getObjVar(this, "poison_strength");
			apply_poison_effect(this, strength);
		}
		callBack(this, callback_delay, 0x53);
		return(0x00);
	}
	cure_poison(this);
	return(0x00);
}

trigger ishealthy {
	return(0x00);
}
