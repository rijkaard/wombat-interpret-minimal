inherits quest_general_funcs;

trigger creation {
	if (!hasObjVar(this, "questMyMurderer")) {
		debugMessage("Attempted to set up murder quest without telling the victim who wants him dead.");
		detachScript(this, "quest_murder_victim");
		return(0x00);
	}

member obj murderer = getObjVar(this, "questMyMurderer");
	return(0x01);
}

function string get_murderer_outcry() {
	list phrases = " intends to kill me!", " wishes me dead!", " hates me for no reason I can discern!", " wants me dead!", " hates me and wants me dead!", " hates me and wishes me dead!", " plans to kill me!", " hopes to see me dead!", " hates me and hopes to see me dead!";
	string phrase;
	phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(getName(murderer) + phrase);
}

trigger 0xC8 enterrange(0x05) {
	string intro_msg;
	if (!is_valid_target(this, target)) {
		return(0x01);
	}
	intro_msg = get_intro_opener(target) + get_murderer_outcry();
	setObjVar(this, "questIntroMessage", intro_msg);
	setObjVar(this, "questTarget", target);
	approach_target(this, target);
	return(0x01);
}

trigger speech("*") {
	list args;
	string killer = getName(murderer);
	split(args, arg);
	if (!isInList(args, killer)) {
		return(0x01);
	}
	bark(this, get_murderer_outcry());
	return(0x00);
}

trigger death {
	obj head;
	bark(this, "You lop off the head!");
	head = createGlobalObjectIn(0x1DA0, this);
	setObjVar(head, "questMurderObjTag", this);
	string look_text = "the head of " + getName(this);
	setObjVar(head, "lookAtText", look_text);
	if (giveItem(attacker, head) == NULL()) {
		int teleport_result = teleport(head, getLocation(attacker));
	}
	return(0x00);
}
