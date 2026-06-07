inherits sndfx;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "seance");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	if (!skillTest(this, SKILL_SPIRIT_SPEAK)) {
		systemMessage(this, "You fail your attempt at contacting the netherworld.");
		return(0x00);
	}
	systemMessage(this, "You establish contact with the netherworld.");
	sfx(getLocation(this), 0x024A, 0x00);
	int duration = getSkillLevel(this, SKILL_SPIRIT_SPEAK);
	duration = (0x03 * duration) + getIntelligence(this);
	setObjVar(this, "seance_setting", 0x01);
	seance(this, 0x01);
	attachScript(this, "seance_user");
	callback(this, duration, 0x47);
	return(0x00);
}
