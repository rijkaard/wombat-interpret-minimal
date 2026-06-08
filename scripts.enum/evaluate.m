inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "evaluate");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "What would you like to evaluate?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isMobile(usedon)) {
		return(0x00);
	}
	if (usedon == user) {
		barkTo(user, user, "Hmm, that person looks really silly.");
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x08) {
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "You can't see that.");
		return(0x00);
	}
	int skill = getSkillLevel(user, SKILL_EVAL_INT);
	int intel = getIntelligence(usedon);
	skill = 0x64 - skill;
	skill = skill / 0x05;
	intel = random(intel - skill, intel + skill);
	string desc;
	if (!skillTest(user, SKILL_EVAL_INT)) {
		desc = "You cannot quite judge ");
		concat(desc, getHisHer(usedon));
		concat(desc, " mental abilities.");
		barkTo(user, user, desc);
		return(0x00);
	}
	handleWatchingSkill(user, SKILL_EVAL_INT);
	intel = intel / 0x0A;
	desc = "slightly less intelligent than a rock";
	if (intel == 0x01) {
		desc = "fairly stupid";
	}
	if (intel == 0x02) {
		desc = "not the brightest";
	}
	if (intel == 0x03) {
		desc = "about average";
	}
	if (intel == 0x04) {
		desc = "moderately intelligent";
	}
	if (intel == 0x05) {
		desc = "very intelligent";
	}
	if (intel == 0x06) {
		desc = "extremely intelligent";
	}
	if (intel == 0x07) {
		desc = "extraordinarily intelligent";
	}
	if (intel == 0x08) {
		desc = "like a formidable intellect, well beyond even the extraordinary";
	}
	if (intel == 0x09) {
		desc = "like a definite genius";
	}
	if (intel > 0x09) {
		desc = "superhumanly intelligent in a manner you cannot comprehend";
	}
	string msg = getHeShe(usedon);
	toUpper(msg, 0x00, 0x01);
	concat(msg, " looks ");
	concat(msg, desc);
	concat(msg, ".");
	barkTo(usedon, user, msg);
	return(0x00);
}
