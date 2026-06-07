inherits sndfx;

trigger use {
	systemMessage(user, "What do you want to pick?");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!hasObjVar(usedon, "isLocked")) {
		systemMessage(user, "This does not appear to be locked.");
		return(0x00);
	}
	int lock_level = getObjVar(usedon, "isLocked");
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x03) {
		bark(user, "I am too far away to do that.");
		return(0x00);
	}
	if (lock_level == 0x0100) {
		systemMessage(user, "You don't see how that lock can be manipulated.");
		return(0x00);
	}
	if (lock_level == 0x00) {
		systemMessage(user, "This lock cannot be picked by normal means...");
		return(0x00);
	}
	int skill_roll = skillTest(user, SKILL_LOCKPICKING);
	int pick_skill = getSkillLevelRealStat(user, SKILL_LOCKPICKING) / 0x04;
	int detect_skill = getSkillLevelRealStat(user, SKILL_DETECT_HIDDEN) / 0x04;
	int has_trap = 0x00;
	int trap_detected = 0x00;
	int trap_disarmed = 0x00;
	int roll;
	int mod;
	if (hasObjVar(usedon, "trapLevel")) {
		has_trap = 0x01;
		int trap_level = getObjVar(usedon, "trapLevel");
		roll = random(0x00, 0xFA);
		mod = trap_level * 0x0A;
		if (roll < (detect_skill - mod)) {
			trap_detected = 0x01;
		} else {
			pick_skill = pick_skill / 0x05;
		}
	}
	list f_args = user, usedon;
	if (trap_detected) {
		roll = random(0x00, 0xFA);
		mod = trap_level * 0x0A;
		if (roll < (pick_skill - mod)) {
			barkTo(usedon, user, "You notice a trap and carefully disarm it.");
			message(usedon, "removeTrap", f_args);
		} else {
			barkTo(usedon, user, "You fail to disable the trap.");
			pick_skill = 0x00;
		}
	}
	int lock_min = lock_level - 0x0A;
	if (lock_min < 0x00) {
		lock_min = 0x01;
	}
	int lock_roll = random(lock_min, lock_level);
	if (lock_roll > pick_skill) {
		if (lock_roll >= (lock_level - 0x02)) {
			barkTo(usedon, user, "You broke the lockpick.");
			sfx(there, 0x013F, 0x00);
			destroyOne(this);
		}
		barkTo(usedon, user, "You are unable to pick the lock.");
		return(0x00);
	}
	sfx(there, 0x0241, 0x00);
	removeObjVar(usedon, "isLocked");
	barkTo(usedon, user, "The lock quickly yields to your skill.");
	if ((hasObjVar(usedon, "playerMade"))) {
		callback(usedon, 0x0258, 0x25);
	}
	return(0x00);
}
