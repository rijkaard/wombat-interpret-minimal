inherits quest_general_funcs;

trigger creation {
	if (!hasObjVar(this, "questDeliverReason")) {
		debugMessage("Attempted to attach quest-deliver-asker without supplying a reason.");
		detachScript(this, "quest_deliver_asker");
		return(0x01);
	}
	if (!hasObjVar(this, "questDeliverObject")) {
		debugMessage("Attempted to attach quest-deliver-asker without supplying an object.");
		detachScript(this, "quest_fetch_asker");
		return(0x01);
	}
	if (!hasObjVar(this, "questItemDestination")) {
		debugMessage("Attempted to attach quest-deliver-asker without supplying a destination.");
		detachScript(this, "quest_fetch_asker");
		return(0x01);
	}

member string reason = getObjVar(this, "questDeliverReason");

member obj deliver_obj;

member obj destination;
	deliver_obj = getObjVar(this, "questDeliverObject");
	destination = getObjVar(this, "questItemDestination");
	return(0x01);
}

trigger 0x64 enterrange(0x05) {
	if (!is_valid_target(this, target)) {
		return(0x01);
	}
	string intro_msg = get_intro_opener(target);
	string recipient_name;
	if (deliver_obj != NULL()) {
		recipient_name = getName(deliver_obj);
	}
	intro_msg = intro_msg + reason + recipient_name + ". ";
	intro_msg = intro_msg + "Couldst thou take this one to " + getName(destination) + "? ";
	intro_msg = intro_msg + get_reward_phrase(destination);
	intro_msg = intro_msg + " Payment will be upon delivery. Say 'agreed' if thou dost agree.";
	setObjVar(this, "questIntroMessage", intro_msg);
	setObjVar(this, "questTarget", target);
	setObjVar(this, "questJustAsked", target);
	approach_target(this, target);
	return(0x01);
}

trigger speech("*") {
	if (!hasObjVar(this, "questJustAsked")) {
		return(0x01);
	}
	obj them = getObjVar(this, "questJustAsked");
	if (them != speaker) {
		return(0x01);
	}
	removeObjVar(this, "questJustAsked");
	list args;
	split(args, arg);
	if (!isInList(args, "agreed")) {
		return(0x01);
	}
	bark(this, "I thank thee! In that case, I wash my hands of the task. Here is the item.");
	setObjVar(deliver_obj, "valueless", 0x01);
	if (giveItem(speaker, deliver_obj) == NULL()) {
		int teleport_result = teleport(deliver_obj, getLocation(speaker));
	}
	removeObjVar(this, "questDeliverObject");
	removeObjVar(this, "questItemDestination");
	removeObjVar(this, "questDeliverReason");
	removeObjVar(this, "isActor");
	detachScript(this, "quest_deliver_asker");
	return(0x00);
}
