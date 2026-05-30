inherits trap_globals;

trigger creation {
	setObjVar(this, "trapType", 0x00);
	setObjVar(this, "trapLevel", 0x01);
	return(0x00);
}

trigger message("removeTrap") {
	clear_trap();
	detachScript(this, "trap_explosion");
	return(0x00);
}

trigger message("triggerTrap") {
	obj user;
	user = args[0x00];
	if (is_locked(user, this) > 0x00) {
		return(0x01);
	}
	barkTo(this, user, "You set off a trap!");
	int trap_level = 0x01;
	if (hasObjVar(this, "trapLevel")) {
		trap_level = getObjVar(this, "trapLevel");
	}
	int damage = random(0x0A, 0x1E) * trap_level;
	doDamageType(this, user, damage, 0x04);
	doMobAnimation(user, 0x36BD, 0x14, 0x0A, 0x00, 0x00);
	sfx(getLocation(user), 0x0207, 0x00);
	clear_trap();
	detachScript(this, "trap_explosion");
	return(0x01);
}
