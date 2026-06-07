trigger use {
	list mobs;
	clearList(mobs);
	getMobsInRange(mobs, getLocation(this), 0x14);
	for (int i = (numInList(mobs) - 0x01); i >= 0x00; i--) {
		obj mob = mobs[i];
		if (!isPlayer(mob)) {
			loc mob_loc = getLocation(mob);
			int mob_z = getZ(mob_loc);
			loc above_loc = mob_loc;
			setZ(above_loc, mob_z + 0x10);
			int ok = teleport(mobs[i], above_loc);
			int good_z = findGoodZ(mob_loc, mob_z, mob_z, 0x10, 0x02);
			ok = teleport(mobs[i], mob_loc);
			if ((good_z == (0x00 - 0x80)) || (good_z > mob_z)) {
				systemMessage(user, "FoundZ=" + good_z + " Currently at:" + mob_z);
				systemMessage(user, "'" + getName(mob) + "' was not in a valid position");
				ok = teleport(user, mob_loc);
				return(0x00);
			}
		}
	}
	systemMessage(user, "All mobiles were in valid positions (for flying creatures)");
	return(0x01);
}
