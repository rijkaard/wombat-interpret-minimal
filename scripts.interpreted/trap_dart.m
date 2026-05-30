inherits trap_globals;

trigger creation {
	setObjVar(this, "trapType", 0x03);
	setObjVar(this, "trapLevel", 0x01);
	return(0x00);
}

trigger message("removeTrap") {
	clear_trap();
	detachScript(this, "trap_dart");
	return(0x00);
}

trigger message("triggerTrap") {
	obj user;
	user = args[0x00];
	if (is_locked(user, this) > 0x00) {
		return(0x01);
	}
	barkTo(this, user, "A dart imbeds itself into your flesh.");
	int trap_level = 0x01;
	if (hasObjVar(this, "trapLevel")) {
		trap_level = getObjVar(this, "trapLevel");
	}
	int damage = random(0x05, 0x0F) * trap_level;
	doDamage(this, user, damage);
	clear_trap();
	detachScript(this, "trap_dart");
	return(0x01);
}
