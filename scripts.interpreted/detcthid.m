inherits spelskil;

function void detect_hidden(obj user, loc place) {
	loc here = getLocation(user);
	faceHere(user, getDirectionInternal(here, place));
	int found = 0x00;
	if (testSkill(user, 0x0E)) {
		list nearby;
		list objects;
		getMobsInRange(nearby, place, 0x02);
		getObjectsInRange(objects, place, 0x02);
		concatList(nearby, objects);
		for (int x = 0x00; x < numInList(nearby); x++) {
			if (!isMobile(nearby[x])) {
				if (hasObjVar(nearby[x], "trapLevel")) {
					barkTo(nearby[x], user, "You notice something funny about this object.");
					found = 0x01;
				}
			}
			if (isInvisible(nearby[x]) && !isEditing(nearby[x])) {
				found = 0x01;
				setInvisible(nearby[x], 0x00);
				if (isPlayer(nearby[x])) {
					barkTo(nearby[x], nearby[x], "You have been revealed!");
				}
			}
		}
	}
	if (!found) {
		systemMessage(user, "You can see nothing hidden there.");
	}
	return();
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "detcthid");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "Where will you search?");
	targetLoc(this, this);
	return(0x00);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	detect_hidden(user, place)return(0x00);
}
