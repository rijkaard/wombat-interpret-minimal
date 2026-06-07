inherits quest_general_funcs;

trigger creation {
	if (!hasObjVar(this, "questFetchReason")) {
		debugMessage("Attempted to attach quest-fetch-asker without supplying a reason for desiring the object type.");
		detachScript(this, "quest_fetch_asker");
		return(0x01);
	}
	if (!hasObjVar(this, "questFetchObjType")) {
		if (!hasObjVar(this, "questFetchObject")) {
			debugMessage("Attempted to attach quest-fetch-asker without supplying a desired object.");
			detachScript(this, "quest_fetch_asker");
			return(0x01);
		}
	}

member string fetch_reason = getObjVar(this, "questFetchReason");

member int fetch_obj_type;
	if (hasObjVar(this, "questFetchObjType")) {
		fetch_obj_type = getObjVar(this, "questFetchObjType");
	}

member obj fetch_obj;

member obj item_holder;
	if (hasObjVar(this, "questFetchObject")) {
		fetch_obj = getObjVar(this, "questFetchObject");
		item_holder = getObjVar(this, "questItemHolder");
	}
	return(0x01);
}

trigger 0x64 enterrange(0x05) {
	if (!is_valid_target(this, target)) {
		return(0x01);
	}
	string intro_msg = get_intro_opener(target);
	string recipient_name;
	if (fetch_obj != NULL()) {
		recipient_name = getName(fetch_obj);
	} else {
		recipient_name = getNameByType(fetch_obj_type) + "s";
	}
	intro_msg = intro_msg + fetch_reason + recipient_name + ". ";
	if (item_holder != NULL()) {
		intro_msg = intro_msg + " " + getName(item_holder) + " hath one, I hear. ";
	}
	intro_msg = intro_msg + get_reward_phrase(this);
	setObjVar(this, "questIntroMessage", intro_msg);
	setObjVar(this, "questTarget", target);
	approach_target(this, target);
	return(0x01);
}

trigger give {
	int matched = 0x00;
	if (fetch_obj != NULL()) {
		if (givenobj == fetch_obj) {
			matched = 0x01;
		}
	}
	if (!matched) {
		if (getObjType(givenobj) == fetch_obj_type) {
			matched = 0x01;
		}
	}
	if (!matched) {
		return(0x01);
	}
	complete_quest_and_reward(this, giver, 0x01);
	deleteObject(givenobj);
	removeObjVar(this, "fetchQuestTarget");
	removeObjVar(this, "fetchQuestIntroMessage");
	removeObjVar(this, "isActor");
	removeObjVar(this, "questFetchObjType");
	removeObjVar(this, "questFetchReason");
	detachScript(this, "quest_fetch_asker");
	return(0x00);
}
