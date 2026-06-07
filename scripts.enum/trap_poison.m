inherits trap_globals;

trigger creation {
	setObjVar(this, "trapType", 0x01);
	setObjVar(this, "trapLevel", 0x01);
	return(0x00);
}

trigger message("removeTrap") {
	clear_trap();
	detachScript(this, "trap_poison");
	return(0x00);
}

trigger message("triggerTrap") {
	obj user = args[0x00];
	if (is_locked(user, this) > 0x00) {
		return(0x01);
	}
	barkTo(this, user, "A cloud of green gas engulfs your body!");
	int trap_level = 0x01;
	if (hasObjVar(this, "trapLevel")) {
		trap_level = getObjVar(this, "trapLevel");
	}
	setObjVar(user, "poison_strength", trap_level);
	attachScript(user, "poisoned");
	receiveUnhealthyActionFrom(user, this);
	clear_trap();
	detachScript(this, "trap_poison");
	return(0x01);
}
