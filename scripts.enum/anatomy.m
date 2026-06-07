inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "anatomy");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "Whom shall I examine?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	string msg;
	if (!isMobile(usedon)) {
		barkTo(usedon, user, "Only living things have anatomies!");
		return(0x00);
	}
	if (usedon == user) {
		barkTo(usedon, user, "You know yourself quite well enough already.");
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x08) {
		barkTo(usedon, user, "I am too far away to do that.");
		return(0x00);
	}
	int skill = getSkillLevel(user, SKILL_ANATOMY);
	int str_val = getStrength(usedon);
	int dex_val = getDexterity(usedon);
	skill = 0x64 - skill;
	skill = skill / 0x04;
	str_val = random(str_val - skill, str_val + skill);
	dex_val = random(dex_val - skill, dex_val + skill);
	if (!skillTest(user, SKILL_ANATOMY)) {
		msg = "You can not quite get a sense of ");
		concat(msg, getHisHer(usedon));
		concat(msg, " physical characteristics.");
		barkTo(usedon, user, msg);
		return(0x00);
	}
	handleWatchingSkill(user, SKILL_ANATOMY);
	str_val = str_val / 0x0A;
	dex_val = dex_val / 0x0A;
	string str_desc = "like they have trouble lifting small objects";
	string dex_desc = "like they barely manage to stay standing";
	if (dex_val == 0x01) {
		dex_desc = "very clumsy";
	}
	if (dex_val == 0x02) {
		dex_desc = "somewhat uncoordinated";
	}
	if (dex_val == 0x03) {
		dex_desc = "moderately dexterous";
	}
	if (dex_val == 0x04) {
		dex_desc = "somewhat agile";
	}
	if (dex_val == 0x05) {
		dex_desc = "very agile";
	}
	if (dex_val == 0x06) {
		dex_desc = "extremely agile";
	}
	if (dex_val == 0x07) {
		dex_desc = "extraordinarily agile";
	}
	if (dex_val == 0x08) {
		dex_desc = " moves like quicksilver";
	}
	if (dex_val == 0x09) {
		dex_desc = "like one of the fastest people you have ever seen";
	}
	if (dex_val > 0x09) {
		dex_desc = "superhumanly agile";
	}
	if (str_val == 0x01) {
		str_desc = "rather feeble";
	}
	if (str_val == 0x02) {
		str_desc = "somewhat weak";
	}
	if (str_val == 0x03) {
		str_desc = "to be of normal strength";
	}
	if (str_val == 0x04) {
		str_desc = "somewhat strong";
	}
	if (str_val == 0x05) {
		str_desc = "very strong";
	}
	if (str_val == 0x06) {
		str_desc = "extremely strong";
	}
	if (str_val == 0x07) {
		str_desc = "extraordinarily strong";
	}
	if (str_val == 0x08) {
		str_desc = "strong as an ox";
	}
	if (str_val == 0x09) {
		str_desc = "like one of the strongest people you have ever seen";
	}
	if (str_val > 0x09) {
		str_desc = "superhumanly strong";
	}
	msg = getHeShe(usedon);
	if (dex_val != 0x08) {
		concat(msg, " looks ");
	}
	concat(msg, dex_desc);
	concat(msg, " and ");
	concat(msg, str_desc);
	concat(msg, ".");
	toUpper(msg, 0x00, 0x01);
	barkTo(usedon, user, msg);
	return(0x00);
}
