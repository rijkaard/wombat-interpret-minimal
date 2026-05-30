inherits spelskil;

function void detect_invisible(obj user, loc place) {
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, place));
	int skill = getSkillLevelReal(user, 0x19);
	int roll = dice(0x01, 0x03E8);
	if (roll < skill) {
		list mobiles;
		getMobsInRange(mobiles, place, 0x02);
		for (int x = 0x00; x < numInList(mobiles); x++) {
			if (hasScript(mobiles[x], "reminvis")) {
				doMobAnimation(mobiles[x], 0x376A, 0x09, 0x28, 0x00, 0x00);
			}
		}
		list objects;
		getObjectsInRange(objects, place, 0x02);
		for (int y = 0x00; y < numInList(objects); y++) {
			if (hasScript(objects[y], "reminvis")) {
				doLocAnimation(getLocation(objects[y]), 0x376A, 0x09, 0x14, 0x00, 0x00);
			}
		}
	}
	int advance_roll = dice(0x01, 0x03E8);
	if ((0x03E8 - skill) < advance_roll) {
		int gain = dice(0x0A, 0x3C);
		if ((gain + skill) < 0x03E8) {
			addSkillLevel(user, 0x0E, gain);
		} else {
			setSkillLevel(user, 0x0E, 0x03E8);
		}
	}
	return();
}

trigger use {
	targetLoc(user, this);
	return(0x00);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	detect_invisible(user, place);
	return(0x00);
}
