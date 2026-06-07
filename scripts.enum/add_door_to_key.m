inherits lock_it;

function int attach_lockable_to_key(obj lockable, obj key) {
	list unlock_list;
	int key_type = getObjType(key);
	switch(key_type) {
	case 0x100E
	case 0x100F
	case 0x1010
	case 0x1012
	case 0x1013
		break;
	default
		bark(key, "Honestly, I'm not a key.");
		return(0x00);
		break;
	}
	if (hasObjVar(key, "whatIUnlock")) {
		getObjListVar(unlock_list, key, "whatIUnlock");
	}
	appendToList(unlock_list, lockable);
	setObjVar(key, "whatIUnlock", unlock_list);
	return(0x01);
}

function int can_unlock(obj key, obj m_target) {
	if (!hasObjVar(key, "whatIUnlock")) {
		return(0x00);
	}
	list unlock_list;
	getObjListVar(unlock_list, key, "whatIUnlock");
	if (isInList(unlock_list, m_target)) {
		return(0x01);
	}
	return(0x00);
}

function int toggle_lock(obj key, obj lockable) {
	if (!hasObjVar(lockable, "isLocked")) {
		int one = getObjVar(lockable, "lockLevel");
		setObjVar(lockable, "isLocked", one);
		return(0x01);
	}
	removeObjVar(lockable, "isLocked");
	return(0x00);
}
