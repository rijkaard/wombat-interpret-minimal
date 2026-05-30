inherits globals;

member obj subject;

member int bounty;

member int is_active;

member string killer_name;

member list descriptor_list;

trigger decay {
	return(0x00);
}

function void schedule_periodic_callback() {
	callbackAdvanced(this, 0x004F1A00, 0x01, 0x00);
	return();
}

function void broadcast_bounty_update() {
	if (!is_active) {
		return();
	}
	list args = subject, bounty, killer_name;
	if (numInList(descriptor_list) > 0x00) {
		appendToList(args, descriptor_list);
	}
	messageToRange(getMasterObjLoc(0x00), 0x01, "updateBounty", args);
	return();
}

trigger lookedat {
	if (!isEditing(looker)) {
		return(0x00);
	}
	string status_str = "(active)";
	if (!is_active) {
		status_str = "(inactive)";
	}
	string descriptor = "???";
	if (numInList(descriptor_list) > 0x00) {
		int desc_val = descriptor_list[0x00];
		descriptor = desc_val;
	}
	barkTo(this, looker, "Bounty for " + killer_name + " (" + objtoint(subject) + ") with " + descriptor + " kills and " + bounty + " gold. " + status_str);
	return(0x00);
}

trigger creation {
	subject = getObjVar(this, "subject");
	removeObjVar(this, "subject");
	return(0x01);
}

trigger destroyed {
	if (subject == NULL()) {
		return(0x01);
	}
	broadcast_bounty_update();
	return(0x01);
}

function void send_bounty_info(obj recipient) {
	list args = subject, bounty, killer_name;
	bark(this, "messaging via probe to (" + objtoint(recipient) + ").");
	relay_message(recipient, "bountyInfo", args);
	return();
}

trigger message("setBountyActivity") {
	if (subject != oprlist(args, 0x00)) {
		return(0x01);
	}
	is_active = oprlist(args, 0x01);
	schedule_periodic_callback();
	broadcast_bounty_update();
	return(0x01);
}

trigger message("addBounty") {
	debugMessage("addBounty args=");
	printList(args);
	if (subject != oprlist(args, 0x00)) {
		return(0x01);
	}
	bounty = bounty + oprlist(args, 0x01);
	if (args[0x02]) {
		is_active = 0x01;
	}
	if (killer_name == "") {
		killer_name = args[0x03];
	}
	if (numInList(descriptor_list) == 0x00) {
		if (numInList(args) > 0x04) {
			copyList(descriptor_list, args[0x04]);
		}
	}
	schedule_periodic_callback();
	return(0x00);
}

trigger message("updateBountyDesc") {
	if (subject != oprlist(args, 0x00)) {
		return(0x01);
	}
	removeItem(args, 0x00);
	descriptor_list = args;
	is_active = 0x01;
	broadcast_bounty_update();
	return(0x01);
}

trigger message("consolidateBounty") {
	if (this == sender) {
		return(0x01);
	}
	if (subject != oprlist(args, 0x00)) {
		return(0x01);
	}
	args = subject, bounty, is_active, "", descriptor_list;
	message(sender, "addBounty", args);
	setDefaultReturn(0x01);
	subject = NULL();
	deleteObjectNoFall(this);
	return(0x01);
}

trigger message("takeBounty") {
	if (!is_active) {
		return(0x01);
	}
	if (subject != oprlist(args, 0x00)) {
		return(0x01);
	}
	bark(this, "(" + objtoint(args[0x01]) + ") is collecting this bounty for " + killer_name);
	send_bounty_info(args[0x01]);
	setDefaultReturn(0x01);
	bounty = 0x00;
	deleteObjectNoFall(this);
	return(0x00);
}

function void teleported() {
	list args = subject;
	messageToRange(getLocation(this), 0x01, "consolidateBounty", args);
	broadcast_bounty_update();
	callback(this, random(0x0E10, 0x0FA0), 0x2F);
	return();
}

trigger message("teleported") {
	teleported();
	return(0x00);
}

trigger serverswitch {
	teleported();
	return(0x00);
}

trigger callback(0x2F) {
	broadcast_bounty_update();
	callback(this, random(0x0E10, 0x0FA0), 0x2F);
	return(0x01);
}

trigger objectloaded {
	callback(this, 0x01, 0x2F);
	return(0x00);
}
