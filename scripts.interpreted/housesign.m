inherits housestuff;

function void clear_lock(obj it) {
	if (hasScript(it, "locked")) {
		detachScript(it, "locked");
	}
	if (hasObjVar(it, "isLocked")) {
		removeObjVar(it, "isLocked");
	}
	if (hasObjVar(it, "lockLevel")) {
		removeObjVar(it, "lockLevel");
	}
	return();
}

trigger creation {
	clear_lock(this);
	obj house = getMultiSlaveId(this);
	setObjVar(house, "myhousesign", this);
	return(0x01);
}

trigger objectloaded {
	clear_lock(this);
	return(0x01);
}

trigger use {
	obj house = getMultiSlaveId(this);
	if (has_house_key(house, user) || isEditing(user)) {
		systemMessage(user, "What dost thou wish the sign to say?");
		textEntry(this, user, 0x17, 0x00, "");
	}
	return(0x00);
}

trigger textentry(0x17) {
	if (button == 0x00) {
		return(0x00);
	}
	obj house = getMultiSlaveId(this);
	if (has_house_key(house, sender) || isEditing(sender)) {
		if (text == "") {
			if (has_name(house)) {
				clear_name(house);
				barkTo(this, sender, "I now say nothing.");
			}
		} else {
			string reply = "I now say ";
			concat(reply, text);
			concat(reply, ".");
			barkTo(this, sender, reply);
			set_name(house, text);
		}
	}
	return(0x00);
}

trigger lookedat {
	obj multi = getMultiSlaveId(this);
	if (has_name(multi)) {
		barkTo(this, looker, get_custom_multi_name(multi));
		bark_decay_status(this, looker, "house");
		return(0x00);
	}
	bark_decay_status(this, looker, "house");
	return(0x01);
}
