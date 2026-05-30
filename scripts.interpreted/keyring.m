inherits add_door_to_key;

function void update_keyring_type(obj keyring, int add) {
	int cur_type = getObjType(keyring);
	list contents;
	getContents(contents, keyring);
	int num = numInList(contents);
	num = num + add;
	int newtype;
	if (num < 0x00) {
		newtype = 0x1011;
	} else {
		switch(num) {
		case 0x00
			newtype = 0x1011;
			break;
		case 0x01
		case 0x02
			newtype = 0x1769;
			break;
		case 0x03
		case 0x04
			newtype = 0x176A;
			break;
		default
			newtype = 0x176B;
			break;
		}
	}
	if (cur_type != newtype) {
		setType(keyring, newtype);
	}
	return;
}

function int is_keyed(obj key) {
	return(hasObjVar(key, "whatIUnlock"));
}

trigger use {
	systemMessage(user, "What do you want to unlock?");
	targetObj(user, this);
	return(0x00);
}

function int open_keyring(obj keyring, obj user) {
	obj container = getItemAtSlot(user, 0x15);
	if (container == NULL()) {
		return(0x01);
	}
	if (!isContainer(container)) {
		return(0x01);
	}
	list keys;
	getContents(keys, keyring);
	int num = numInList(keys);
	for (int i = 0x00; i < num; i++) {
		obj key = keys[i];
		int result = putObjContainer(key, container);
	}
	update_keyring_type(keyring, 0x00);
	systemMessage(user, "You open the keyring.");
	return(0x01);
}

function int try_lock_unlock(obj keyring, obj user, obj usedon) {
	list keys;
	getContents(keys, keyring);
	int num = numInList(keys);
	for (int i = 0x00; i < num; i++) {
		obj key = keys[i];
		if (can_unlock(key, usedon)) {
			if (toggle_lock(key, usedon)) {
				barkTo(usedon, user, "You lock " + getName(usedon) + ".");
			} else {
				barkTo(usedon, user, "You unlock " + getName(usedon) + ".");
			}
			return(0x01);
		}
	}
	barkTo(usedon, user, "You do not have a key for " + getName(usedon) + ".");
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (usedon == this) {
		return(open_keyring(this, user));
	}
	return(try_lock_unlock(this, user, usedon));
}

trigger give {
	if (!is_keyed(givenobj)) {
		systemMessage(giver, "Only non-blank keys can be put on a keyring.");
		return(0x00);
	}
	update_keyring_type(this, 0x01);
	systemMessage(giver, "You put the key on the keyring.");
	int result = putObjContainer(givenobj, this);
	return(0x00);
}

function int detach_if_present(obj m_target, string script_name) {
	if (hasScript(m_target, script_name)) {
		detachScript(m_target, script_name);
		return(0x01);
	}
	return(0x00);
}

trigger objectloaded {
	int result;
	result = detach_if_present(this, "5993");
	result = detach_if_present(this, "5994");
	result = detach_if_present(this, "5995");
	return(0x01);
}
