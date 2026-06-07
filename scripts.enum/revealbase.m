inherits spelskil;

function int reveal_hidden_in_area(obj user, loc place) {
	int success = 0x00;
	if (isInMap(place)) {
		int unused;
		loc user_loc = getLocation(user);
		faceHere(user, getDirectionInternal(user_loc, place));
		list mobs;
		getMobsInRange(mobs, place, 0x02);
		for (int x = 0x00; x < numInList(mobs); x++) {
			obj victim = mobs[x];
			if (is_targetable_mobile(victim)) {
				if (hasScript(victim, "reminvis")) {
					doMobAnimation(victim, 0x375A, 0x09, 0x14, 0x00, 0x00);
					setInvisible(victim, 0x00);
					detachScript(victim, "reminvis");
					success = 0x01;
				}
			}
		}
		list objects;
		getObjectsInRange(objects, place, 0x02);
		for (int y = 0x00; y < numInList(objects); y++) {
			if (hasScript(objects[y], "reminvis")) {
				doLocAnimation(getLocation(objects[y]), 0x375A, 0x09, 0x14, 0x00, 0x00);
				setInvisible(objects[y], 0x00);
				detachScript(objects[y], "reminvis");
				success = 0x01;
			}
		}
		sfx(place, 0x01FD, 0x00);
	}
	schedule_cleanup(this);
	return(success);
}
