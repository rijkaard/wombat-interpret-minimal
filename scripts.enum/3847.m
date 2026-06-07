inherits potion;

trigger use {
	int power = getObjVar(this, "power");
	int cure_power_score = (power * 0x4B);
	if (!start_drink(user)) {
		return(0x00);
	}
	setInvisible(user, 0x00);
	if ((hasScript(user, "poisoned")) || (hasObjVar(user, "poison_strength"))) {
		int poison = getObjVar(user, "poison_strength");
		int poison_penalty_score = (poison * 0x06D6);
		if (((0x2710 + (cure_power_score - poison_penalty_score)) / 0x64) > random(0x01, 0x64)) {
			doMobAnimation(user, 0x373A, 0x0A, 0x0F, 0x00, 0x00);
			sfx(getLocation(user), 0x01E0, 0x00);
			cure_poison(user);
			systemMessage(user, "You feel cured of poison!");
		} else {
			systemMessage(user, "That potion was not strong enough to cure your ailment!");
		}
	}
	obj empty_bottle = createGlobalObjectOn(this, 0x0F0E);
	destroyOne(this);
	return(0x00);
}
