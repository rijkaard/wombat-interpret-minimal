trigger use {
	int poison_chance = (getObjVar(this, "poison_chance"));
	if (poison_chance == 0x00) {
		poison_chance = 0x32;
	}
	if (random(0x00, 0x64) < poison_chance) {
		int strength = (getObjVar(this, "poison_strength"));
		if ((!hasObjVar(user, "poison_strength")) && (!hasScript(user, "poisoned"))) {
			if (strength < 0x01) {
				strength = 0x01;
			}
			if (strength > 0x05) {
				strength = 0x05;
			}
			setObjVar(user, "poison_strength", strength);
			attachScript(user, "poisoned");
			receiveUnhealthyActionFrom(user, this);
			systemMessage(user, "That " + getName(this) + " was poisoned!");
		}
	}
	setDefaultReturn(0x01);
	detachscript(this, "poisfood");
	return(0x01);
}
