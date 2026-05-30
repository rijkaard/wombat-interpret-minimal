inherits sndfx;

trigger use {
	systemMessage(user, "What do you want to pick?");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
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
	int skill_roll = skillTest(user, 0x18);
	int skill_threshold = getSkillLevelRealStat(user, 0x18) / 0x04;
	int roll_min = lock_level - 0x0A;
	if (roll_min < 0x00) {
		roll_min = 0x01;
	}
	int roll = random(roll_min, lock_level);
	if (roll > skill_threshold) {
		if (roll >= (lock_level - 0x02)) {
			barkTo(usedon, user, "You broke the lockpick.");
			sfx(there, 0x013F, 0x00);
			deleteObject(this);
		}
		barkTo(usedon, user, "You are unable to pick the lock.");
		return(0x00);
	}
	sfx(there, 0xEA, 0x00);
	removeObjVar(usedon, "isLocked");
	barkTo(usedon, user, "The lock quickly yields to your skill.");
	callback(usedon, 0x0258, 0x25);
	return(0x00);
}
