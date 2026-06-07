inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "begging");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "To whom do you wish to grovel?");
	targetObj(this, this);
	if (!getCompileFlag(0x01)) {
		if (getNotorietyLevel(this) > (0x00 - 0x01)) {
			removeNotoriety(this, 0x01);
		}
	} else {
		if (getKarmaLevel(this) > 0x01) {
			changeKarma(this, (0x00 - 0x0960));
		}
	}
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isNPC(usedon)) {
		if (isPlayer(usedon)) {
			barkTo(usedon, user, "Perhaps just asking would work better.");
		} else {
			barkTo(usedon, user, "There is little chance of getting money from that!");
		}
		return(0x00);
	}
	if (!isHuman(usedon)) {
		barkTo(usedon, user, "There is little chance of getting money from that!");
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x04) {
		int npc_type = getObjType(usedon);
		if (npc_type == 0x0190) {
			systemMessage(this, "You are too far away to beg from him.");
		}
		if (npc_type == 0x0191) {
			systemMessage(this, "You are too far away to beg from her.");
		}
		if ((npc_type != 0x0190) && (npc_type != 0x0190)) {
			systemMessage(this, "That's too far away.  You couldn't beg from it anyway.");
		}
		return(0x00);
	}
	if (!skillTest(user, SKILL_BEGGING)) {
		barkTo(usedon, user, "They seem unwilling to give you any money.");
		return(0x00);
	}
	handleWatchingSkill(user, SKILL_BEGGING);
	setObjVar(usedon, "beggingVictim", usedon);
	setObjVar(usedon, "beggingBeggar", user);
	attachScript(usedon, "beggingpathfind");
	bark(usedon, "I feel sorry for thee...");
	walkTo(usedon, getLocation(user), 0x12);
	return(0x00);
}
