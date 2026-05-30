inherits globals;

member obj gm;

member obj crier_obj;

member list message_list;

trigger 0x0190 enterrange(0x05) {
	if (numInList(message_list) < 0x01) {
		return(0x01);
	}
	string msg = message_list[random(0x00, numInList(message_list) - 0x01)];
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(target)));
	bark(this, "Hear ye! Hear ye!");
	bark(this, msg);
	return(0x01);
}

trigger speech("news") {
	if (numInList(message_list) < 0x01) {
		bark(this, "I have no news for thee at this time.");
		return(0x01);
	}
	string msg = message_list[random(0x00, numInList(message_list) - 0x01)];
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(speaker)));
	bark(this, "Some of the latest news!");
	bark(this, msg);
	return(0x01);
}

function void list_messages() {
	string msg_text;
	string idx;
	systemMessage(gm, "TOWN CRIER MESSAGES");
	for (int i = 0x00; i < numInList(message_list); i++) {
		idx = i;
		msg_text = message_list[i];
		systemMessage(gm, idx + ": " + msg_text);
	}
	return;
}

trigger textentry(0x26) {
	if (sender != gm) {
		return(0x00);
	}
	if (button == 0x00) {
		systemMessage(gm, "Message entry cancelled.");
		return(0x00);
	}
	string confirm_msg = "The text '" + text + "' has been added to this town crier.";
	systemMessage(gm, confirm_msg);
	appendToList(message_list, text);
	return(0x00);
}

function loc get_broadcast_loc() {
	return(getMasterObjLoc(0x02));
}

trigger textentry(0x25) {
	if (sender != gm) {
		return(0x00);
	}
	if (button == 0x00) {
		systemMessage(gm, "Message entry cancelled.");
		return(0x00);
	}
	string msg = "The text '" + text + "' has been added to town criers.";
	systemMessage(gm, msg);
	list f_args;
	appendToList(f_args, text);
	multiMessageToLoc(get_broadcast_loc(), "towncrieraddmessage", f_args);
	return(0x00);
}

trigger textentry(0x27) {
	if (sender != gm) {
		return(0x00);
	}
	if (button == 0x00) {
		systemMessage(gm, "Message removal cancelled.");
		return(0x00);
	}
	int idx = text;
	if ((idx < 0x00) || (idx > numInList(message_list) - 0x01)) {
		systemMessage(gm, "You have entered an invalid index number.");
	}
	string msg_text = message_list[idx];
	string confirm_msg = "Removing index #" + text + ", message text reading '" + msg_text + "' from all town criers.");
	systemMessage(gm, confirm_msg);
	list args;
	appendToList(args, msg_text);
	multiMessageToLoc(get_broadcast_loc(), "towncrierremovemessage", args);
	return(0x00);
}

trigger message("towncrieraddmessage") {
	string text = args[0x00];
	appendToList(message_list, text);
	return(0x00);
}

trigger message("towncrierremovemessage") {
	string text = args[0x00];
	removeSpecificItem(message_list, text);
	return(0x00);
}

trigger use {
	if (!isEditing(user)) {
		return(0x01);
	}
	crier_obj = this;
	gm = user;
	list menu_opts;
	appendToList(menu_opts, 0x00);
	appendToList(menu_opts, "View current town crier messages.");
	appendToList(menu_opts, 0x01);
	appendToList(menu_opts, "Add a message to the town criers.");
	appendToList(menu_opts, 0x02);
	appendToList(menu_opts, "Delete a message from the town criers.");
	appendToList(menu_opts, 0x03);
	appendToList(menu_opts, "Add a message to this town crier ONLY.");
	selectType(gm, crier_obj, 0x3C, "TOWN CRIER CONTROL MENU", menu_opts);
	return(0x00);
}

trigger typeselected(0x3C) {
	if (user != gm) {
		return(0x00);
	}
	if (listindex == 0x00) {
		barkTo(gm, gm, "Town crier update cancelled.");
		return(0x01);
	}
	switch(objtype) {
	case 0x00
		list_messages();
		break;
	case 0x01
		systemMessage(gm, "Type in the message you wish to add: ");
		textEntry(crier_obj, gm, 0x25, 0x00, "");
		return(0x00);
		break;
	case 0x02
		systemMessage(gm, "Enter the number of the message you wish to remove: ");
		textEntry(crier_obj, gm, 0x27, 0x00, "");
		return(0x00);
		break;
	case 0x03
		systemMessage(gm, "Type in the message you wish to add: ");
		textEntry(crier_obj, gm, 0x26, 0x00, "");
		return(0x00);
		break;
	default
		break;
	}
	return(0x01);
}

function void broadcast_crier_add(obj it) {
	list msg_args;
	appendToList(msg_args, it);
	multiMessageToLoc(get_broadcast_loc(), "towncrieradd", msg_args);
	return();
}

function void broadcast_crier_remove(obj it) {
	list msg_args;
	appendToList(msg_args, it);
	multiMessageToLoc(get_broadcast_loc(), "towncrierremove", msg_args);
	return();
}

trigger creation {
	broadcast_crier_add(this);
	return(0x01);
}

trigger objectloaded {
	broadcast_crier_add(this);
	return(0x01);
}

trigger destroyed {
	broadcast_crier_remove(this);
	return(0x01);
}
