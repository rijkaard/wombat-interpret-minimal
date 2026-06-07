inherits sk_table;

function int assign_key_target(obj user, obj key, obj usedon) {
	if (!isEditing(user)) {
		return(0x00);
	}
	list doors;
	if (hasObjListVar(usedon, "myhousedoors")) {
		getObjListVar(doors, usedon, "myhousedoors");
	} else {
		if (isMultiComp(usedon)) {
			obj multi = getMultiSlaveId(usedon);
			if (hasObjListVar(multi, "myhousedoors")) {
				getObjListVar(doors, multi, "myhousedoors");
			} else {
				doors = usedon;
			}
		} else {
			doors = usedon;
		}
	}
	setObjVar(this, "whatIUnlock", doors);
	string obj_str;
	barkTo(this, user, "This key now unlocks:");
	int count = numInList(doors);
	for (int i = 0x00; i < count; i++) {
		obj door = doors[i];
		obj_str = objToStr(door);
		if (isValid(door)) {
			concat(obj_str, " ");
			concat(obj_str, getName(door));
		}
		barkTo(this, user, obj_str);
	}
	return(0x01);
}

function int is_key_accessible(obj it, obj user) {
	obj container = getTopmostContainer(it);
	if (container != user) {
		systemMessage(user, "That key is unreachable.");
		return(0x00);
	}
	return(0x01);
}

trigger use {
	if (!is_key_accessible(this, user)) {
		return(0x00);
	}

member int use_mode = 0x01;
	if (hasObjVar(this, "whatIUnlock")) {
		barkTo(this, user, "What shall I use this key on?");
		use_mode = 0x00;
	} else {
		barkTo(this, user, "This is a key blank.  Which key would you like to make a copy of?");
		use_mode = 0x01;
	}
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (!is_key_accessible(this, user)) {
		return(0x00);
	}
	if (usedon == NULL()) {
		return(0x00);
	}
	list unlock_list;
	int lockLevel;
	int usedon_type = getObjType(usedon);
	if (hasObjVar(this, "whatIUnlock")) {
		getObjListVar(unlock_list, this, "whatIUnlock");
	}
	if (isEditing(user) && (usedon == this)) {
		string obj_desc;
		barkTo(this, user, "This key unlocks:");
		int count = numInList(unlock_list);
		for (int i = 0x00; i < count; i++) {
			obj container = unlock_list[i];
			obj_desc = objToStr(container);
			if (isValid(container)) {
				concat(obj_desc, " ");
				concat(obj_desc, getName(container));
			}
			barkTo(this, user, obj_desc);
		}
	}
	if (usedon == this) {
		systemMessage(user, "Enter a description for this key:");
		textEntry(this, user, 0x16, 0x00, "");
		return(0x00);
	}
	if (use_mode == 0x00) {
		if (isMobile(usedon)) {
			barkTo(usedon, user, "You can't unlock that!");
			return(0x00);
		}
		int has_lock = hasScript(usedon, "locked");
		if (!has_lock) {
			has_lock = hasObjVar(usedon, "lockLevel");
		}
		if (!has_lock) {
			barkTo(usedon, user, "This doesn't appear to have a lock.");
			return(0x00);
		}
		if (!isInList(unlock_list, usedon)) {
			barkTo(usedon, user, "This key doesn't seem to unlock that.");
			return(0x00);
		}
		int is_locked = hasObjVar(usedon, "isLocked");
		int not_lockable = hasObjVar(usedon, "notLockable");
		if (not_lockable) {
			if (is_locked) {
				barkTo(usedon, user, "You can not currently unlock that.");
			} else {
				barkTo(usedon, user, "You can not currently lock that.");
			}
			return(0x00);
		}
		if (is_locked) {
			lockLevel = getObjVar(usedon, "isLocked");
			setObjVar(usedon, "lockLevel", lockLevel);
			removeObjVar(usedon, "isLocked");
			if (!hasObjVar(usedon, "playerMade")) {
				callback(usedon, 0x0258, 0x25);
			}
			if (hasObjVar(usedon, "trapLevel")) {
				barkTo(usedon, user, "You disable the trap temporarily.  Lock it again to re-enable it.");
				setObjVar(usedon, "disabled", 0x01);
			}
			barkTo(usedon, user, "You unlock " + getName(usedon) + ".");
		} else {
			lockLevel = getObjVar(usedon, "lockLevel");
			setObjVar(usedon, "isLocked", lockLevel);
			barkTo(usedon, user, "You lock " + getName(usedon) + ".");
			if (hasObjVar(usedon, "disabled")) {
				removeObjVar(usedon, "disabled");
				if (hasObjVar(usedon, "trapLevel")) {
					barkTo(usedon, user, "You re-enable the trap.");
				}
			}
			return(0x00);
		}
		return(0x00);
	}
	if (use_mode == 0x01) {
		obj top_container = getTopmostContainer(usedon);
		if (top_container != user) {
			barkTo(usedon, user, "This key is unreachable.");
			return(0x00);
		}
		switch(usedon_type) {
		case 0x100E
		case 0x100F
		case 0x1010
		case 0x1012
		case 0x1013
			if (testSkill(user, SKILL_TINKERING)) {
				if (!hasObjVar(usedon, "whatIUnlock")) {
					barkTo(usedon, user, "This key is also a blank.");
					return(0x00);
				}
				getObjListVar(unlock_list, usedon, "whatIUnlock");
				setObjVar(this, "whatIUnlock", unlock_list);
				systemMessage(user, "You make a copy of the key.");
				return(0x00);
			} else {
				barkTo(usedon, user, "You fail to make a copy of the key.");
				int rand_roll = random(0x01, 0x03);
				if (rand_roll == 0x01) {
					barkTo(usedon, user, "The key was destroyed in the attempt.");
					deleteObject(this);
				}
				return(0x00);
			}
			break;
		default
			if (!assign_key_target(user, this, usedon)) {
				systemMessage(user, "You can't make a copy of that.");
			}
			return(0x00);
			break;
		}
	}
	return(0x00);
}

trigger textentry(0x16) {
	if (button == 0x00) {
		return(0x00);
	}
	string desc;
	if (hasObjVar(this, "predesc")) {
		desc = getObjVar(this, "predesc");
	} else {
		desc = "a key";
	}
	if (text != "") {
		concat(desc, ": ");
		concat(desc, text);
	}
	setObjVar(this, "lookAtText", desc);
	barkTo(this, sender, "This key is now described as " + desc);
	return(0x00);
}
