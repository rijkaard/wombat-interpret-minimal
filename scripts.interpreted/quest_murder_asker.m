inherits quest_general_funcs;

trigger creation {
	if (!hasObjVar(this, "questMurderReason")) {
		debugMessage("Attempted to attach murder quest without reason.");
		return(0x01);
	}
	if (!hasObjVar(this, "questMurderVictim")) {
		debugMessage("Attempted to attach murder quest without victim.");
		return(0x01);
	}

member string reason = getObjVar(this, "questMurderReason");

member obj victim = getObjVar(this, "questMurderVictim");
	setNotoriety(this, 0x00 - 0x63);
	return(0x01);
}

trigger 0x64 enterrange(0x05) {
	if (!is_valid_target(this, target)) {
		return(0x01);
	}
	string intro_msg = get_intro_opener(target) + reason + ". Bring me " + getHisHer(victim) + " head as proof of the deed. " + get_reward_phrase(this);
	setObjVar(this, "questIntroMessage", intro_msg);
	setObjVar(this, "questTarget", target);
	approach_target(this, target);
	return(0x01);
}

trigger give {
	if (!hasObjVar(givenobj, "questMurderObjTag")) {
		return(0x01);
	}
	obj head = getObjVar(givenobj, "questMurderObjTag");
	if (head != victim) {
		string intro_msg = "This is not the head of mine enemy! " + reason + get_murder_suffix() + get_reward_phrase(this);
		bark(this, intro_msg);
		return(0x00);
	}
	complete_quest_and_reward(this, giver, 0x00);
	removeObjVar(this, "questMurderVictim");
	removeObjVar(this, "questMurderReason");
	deleteObject(givenobj);
	detachScript(this, "quest_murder_asker");
	return(0x00);
}
