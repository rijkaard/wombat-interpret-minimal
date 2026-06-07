inherits globals;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "removetrap");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "Which trap will you attempt to disarm?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x03) {
		bark(user, "I am too far away to do that.");
		return(0x00);
	}
	if (!hasObjVar(usedon, "trapLevel")) {
		systemMessage(user, "That doesn't appear to be trapped.");
		return(0x00);
	}
	int trap_level = getObjVar(usedon, "trapLevel");
	list f_args = user, usedon;
	if (testSkill(user, SKILL_REMOVE_TRAP)) {
		systemMessage(user, "You successfully render the trap harmless.");
		message(usedon, "removeTrap", f_args);
	} else {
		int mod = trap_level * 0x0A;
		if (random(0x00, 0xFA) < mod) {
			systemMessage(user, "You set off a trap!");
			message(usedon, "triggerTrap", f_args);
		} else {
			systemMessage(user, "You fail to disarm the trap, but you don't set it off.");
		}
	}
	return(0x00);
}
