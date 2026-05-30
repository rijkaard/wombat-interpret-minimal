inherits globals;

trigger message("TRAP") {
	obj victim = args[0x00];
	string msg_key = args[0x01];
	string me = "blah";
	if (hasObjVar(this, "TrapTheMessage")) {
		me = getObjVar(this, "TrapTheMessage");
	}
	if (me != msg_key) {
		return(0x00);
	}
	if (hasObjVar(this, "TrapDoesAnim")) {
		int anim_type = getObjVar(this, "TrapDoesAnim");
		switch(anim_type) {
		default
			bark(this, "Nothing visible happens.");
			break;
		case 0x01
			bark(this, "Eerie sparklies hover over " + getName(this) + ".");
			break;
		case 0x02
			bark(this, "A fiery explosion results!");
			break;
		case 0x03
			bark(this, "A puff of smoke goes up!");
			break;
		}
	}
	if (hasObjVar(this, "TrapPoisonLevel")) {
		int poison_level = getObjVar(this, "TrapPoisonLevel");
		barkTo(this, victim, "A tiny needle jabs at your finger!");
		int poison_strength = getObjVar(this, "TrapPoisonLevel");
		setObjVar(victim, "poison_strength", poison_strength);
	}
	if (hasObjVar(this, "TrapDamage")) {
		loseHP(victim, getObjVar(this, "TrapDamage"));
		bark(this, "You are hurt!");
	}
	if (hasObjVar(this, "TrapTeleportLoc")) {
		loc teleport_loc = getObjVar(this, "TrapTeleportLoc");
		int teleport_result = teleport(victim, teleport_loc);
	} else {
		bark(this, "No teleportation set on trap.");
	}
	return(0x00);
}
