inherits potion;

trigger creation {
	return(0x00);
}

trigger use {
	if (hasObjVar(user, "potionHealed")) {
		barkToHued(user, user, 0x22, "You must wait 10 seconds before using another healing potion.");
		return(0x00);
	}
	if (!start_drink(user)) {
		return(0x00);
	}
	if (can_drink_potion(user) == 0x00) {
		return(0x00);
	}
	setInvisible(user, 0x00);
	int power = 0x64;
	if (hasObjVar(this, "power")) {
		power = getObjVar(this, "power");
	}
	int heal_amount = random(power / 0x1E, power / 0x0A);
	addHP(user, heal_amount);
	systemMessage(user, "" + heal_amount + " points of damage have been healed.");
	obj empty_bottle = createGlobalObjectAt(0x0F0E, getLocation(this));
	setObjVar(user, "potionHealed", 0x01);
	attachScript(user, "potiontime");
	callback(user, 0x0A, 0x57);
	deleteObject(this);
	return(0x00);
}
