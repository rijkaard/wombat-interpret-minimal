inherits spelskil;

function int has_multi_in_range(loc place, int range) {
	list objects;
	getObjectsInRange(objects, place, range);
	int num = numInList(objects);
	for (int i = 0x00; i < num; i++) {
		obj it = objects[i];
		if (isMultiComp(it)) {
			return(0x01);
		}
	}
	return(0x00);
}

function loc find_teleport_loc(obj user, loc place) {
	loc invalid_loc = 0x00, 0x00, (0x00 - 0x80);
	if (!isInMap(place)) {
		return(invalid_loc);
	}
	int error = 0x00;
	if (getDistanceInTiles(getLocation(user), place) > 0x0B) {
		systemMessage(user, "That location is too far away");
		error = 0x01;
	}
	if (!error && (getEncumbrance(user) > 0x64)) {
		systemMessage(user, "Thou art too encumbered to move.");
		error = 0x01;
	}
	if (!error && (canSeeLoc(user, place) != 0x01)) {
		systemMessage(user, "Target cannot be seen.");
		error = 0x01;
	}
	if (!error) {
		loc target = place;
		list mobs_at_target;
		getMobsAt(mobs_at_target, target);
		int user_height = getHeight(user);
		int base_z = getZ(target);
		int max_z = base_z + 0x08;
		int good_z = findGoodZ(target, base_z, max_z, user_height, 0x01);
		setZ(target, good_z);
		if (good_z == (0x00 - 0x80)) {
			systemMessage(user, "Cannot teleport to that spot.");
			return(invalid_loc);
		}
		if ((0x07 == canExistAt(target, user_height, 0x01)) && (!is_multi_at(target))) {
			if (0x00 == numInList(mobs_at_target)) {
				if (has_multi_in_range(target, 0x05)) {
					systemMessage(user, "Cannot teleport to that spot.");
					return(invalid_loc);
				}
				return(target);
			} else {
				systemMessage(user, "Someone is standing there!");
				return(invalid_loc);
			}
		} else {
			systemMessage(user, "Cannot teleport to that spot.");
			return(invalid_loc);
		}
	}
	return(invalid_loc);
}

function int cast_teleport(obj user, loc there) {
	int success = 0x00;
	there = find_teleport_loc(user, there);
	if (getZ(there) != (0x00 - 0x80)) {
		int ret;
		loc origin = getLocation(user);
		int teleport_result = teleport(user, there);
		if (teleport_result) {
			doLocAnimation(origin, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
			doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
			sfx(there, 0x01FE, 0x00);
			success = 0x01;
		} else {
			bark(user, "I can't teleport there!");
		}
	}
	schedule_cleanup(this);
	return(success);
}
