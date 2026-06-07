inherits housestuff;

trigger creation {
	setObjVar(this, "predesc", "a house key");
	setObjVar(this, "lookAtText", "a house key");
	return(0x01);
}

function void lock_down(obj it) {
	attachScript(it, "lockdown");
	return();
}

function void release_lockdown(obj it) {
	detachScript(it, "lockdown");
	return();
}

function int is_locked_down(obj it) {
	return(hasScript(it, "lockdown"));
}

function int key_matches_house(obj key, obj house) {
	list unlocks;
	getObjListVar(unlocks, key, "whatIUnlock");
	list doors;
	if (hasObjVar(house, "myhousedoors")) {
		getObjListVar(doors, house, "myhousedoors");
	}
	int door_count = numInList(doors);
	for (int i = 0x00; i < door_count; i++) {
		if (isInList(unlocks, doors[i])) {
			return(0x01);
		}
	}
	return(0x00);
}

function int toggle_lockdown(obj key, obj user_obj, obj it) {
	loc where = getLocation(user_obj);
	obj house = get_nearby_house_for_user(user_obj, where);
	if (!isValid(house)) {
		systemMessage(user_obj, "You are not around your house.");
		return(0x00);
	}
	if (!key_matches_house(key, house)) {
		systemMessage(user_obj, "This key is not for this house.");
		return(0x00);
	}
	if (is_locked_down(it)) {
		release_lockdown(it);
		systemMessage(user_obj, "You release that locked down object.");
	} else {
		lock_down(it);
		systemMessage(user_obj, "You lock that down.");
	}
	return(0x01);
}

function int is_locked(obj it) {
	return(hasScript(it, "locked"));
}

function int key_unlocks_item(obj key, obj it) {
	list unlocks;
	getObjListVar(unlocks, key, "whatIUnlock");
	return(isInList(unlocks, it));
}
