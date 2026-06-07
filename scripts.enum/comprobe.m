inherits globals;

member obj recipient;

member list message_queue;

trigger decay {
	return(0x00);
}

trigger creation {
	recipient = getObjVar(this, "recipient");
	removeObjVar(this, "recipient");
	return(0x01);
}

trigger callback(0x4E) {
	deleteObjectNoFall(this);
	return(0x00);
}

trigger lookedat {
	if (!isEditing(looker)) {
		return(0x00);
	}
	systemMessage(looker, "Messages for " + objtoint(recipient) + ":");
	int count = numInList(message_queue);
	printList(message_queue);
	for (int i = 0x00; i < count; i++) {
		string msg = oprlist(message_queue[0x00], 0x00);
		systemMessage(looker, msg);
	}
	return(0x00);
}

function void deliver_messages() {
	int count = numInList(message_queue);
	for (int i = 0x00; i < count; i++) {
		list args;
		copyList(args, message_queue[0x00]);
		string msg = args[0x00];
		removeItem(args, 0x00);
		message(recipient, msg, args);
		removeItem(message_queue, 0x00);
	}
	deleteObjectNoFall(this);
	return();
}

trigger message("addMessage") {
	appendToList(message_queue, args);
	callback(this, 0x00278D00, 0x4E);
	return(0x00);
}

trigger message("consolidate") {
	if (this == sender) {
		return(0x01);
	}
	obj target_recipient = args[0x00];
	if (recipient != target_recipient) {
		return(0x01);
	}
	int count = numInList(message_queue);
	for (int i = 0x00; i < count; i++) {
		message(sender, "addMessage", message_queue[0x00]);
		removeItem(message_queue, 0x00);
	}
	setDefaultReturn(0x01);
	deleteObjectNoFall(this);
	return(0x01);
}

trigger message("collect") {
	if (recipient != sender) {
		return(0x01);
	}
	if (isValid(recipient)) {
		deliver_messages();
		return(0x01);
	}
	loc dest = args[0x00];
	if (!isInMap(dest)) {
		int result = teleportNoFall(this, dest);
	}
	return(0x01);
}

function void teleported() {
	loc relay_loc = getRelayLoc(recipient);
	if (getLocation(this) == relay_loc) {
		list args;
		appendToList(args, recipient);
		messageToRange(relay_loc, 0x01, "consolidate", args);
		clearList(args);
		multiMessage(recipient, "requestCollection", args);
	} else {
		if (isValid(recipient)) {
			deliver_messages();
		} else {
			int teleport_result = teleportNoFall(this, relay_loc);
		}
	}
	return();
}

trigger message("teleported") {
	teleported();
	return(0x01);
}

trigger objectloaded {
	teleported();
	return(0x01);
}

trigger serverswitch {
	teleported();
	return(0x01);
}
