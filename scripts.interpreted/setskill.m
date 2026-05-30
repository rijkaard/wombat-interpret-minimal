inherits sk_table;

trigger use {
	string skill = "UNKNOWN";
	skill = getObjVar(this, "skill");
	int skill_id;
	if (skill == "SKILL_ALCHEMY") {
		skill_id = 0x00;
	}
	if (skill == "SKILL_ANATOMY") {
		skill_id = 0x01;
	}
	if (skill == "SKILL_ANIMAL_LORE") {
		skill_id = 0x02;
	}
	if (skill == "SKILL_APPRAISE") {
		skill_id = 0x03;
	}
	if (skill == "SKILL_ARMSLORE") {
		skill_id = 0x04;
	}
	if (skill == "SKILL_BATTLE_DEFENSE") {
		skill_id = 0x05;
	}
	if (skill == "SKILL_BEGGING") {
		skill_id = 0x06;
	}
	if (skill == "SKILL_BLACKSMITH") {
		skill_id = 0x07;
	}
	if (skill == "SKILL_FLETCHER") {
		skill_id = 0x08;
	}
	if (skill == "SKILL_CALM") {
		skill_id = 0x09;
	}
	if (skill == "SKILL_CAMPING") {
		skill_id = 0x0A;
	}
	if (skill == "SKILL_CARPENTRY") {
		skill_id = 0x0B;
	}
	if (skill == "SKILL_MAPMAKING") {
		skill_id = 0x0C;
	}
	if (skill == "SKILL_COOKING") {
		skill_id = 0x0D;
	}
	if (skill == "SKILL_DETECT_HIDDEN") {
		skill_id = 0x0E;
	}
	if (skill == "SKILL_ENTICE") {
		skill_id = 0x0F;
	}
	if (skill == "SKILL_EVALUATE") {
		skill_id = 0x10;
	}
	if (skill == "SKILL_FIRST_AID") {
		skill_id = 0x11;
	}
	if (skill == "SKILL_FISHING") {
		skill_id = 0x12;
	}
	if (skill == "SKILL_FORENSICS") {
		skill_id = 0x13;
	}
	if (skill == "SKILL_HERDING") {
		skill_id = 0x14;
	}
	if (skill == "SKILL_HIDE") {
		skill_id = 0x15;
	}
	if (skill == "SKILL_INCITE") {
		skill_id = 0x16;
	}
	if (skill == "SKILL_PICK_LOCK") {
		skill_id = 0x18;
	}
	if (skill == "SKILL_MAGIC") {
		skill_id = 0x19;
	}
	if (skill == "SKILL_MAGIC_DEFENSE") {
		skill_id = 0x1A;
	}
	if (skill == "SKILL_MELEE") {
		skill_id = 0x1B;
	}
	if (skill == "SKILL_PEEK") {
		skill_id = 0x1C;
	}
	if (skill == "SKILL_PLAY") {
		skill_id = 0x1D;
	}
	if (skill == "SKILL_POISONING") {
		skill_id = 0x1E;
	}
	if (skill == "SKILL_RANGED_WEAPONS") {
		skill_id = 0x1F;
	}
	if (skill == "SKILL_SEANCE") {
		skill_id = 0x20;
	}
	if (skill == "SKILL_STEALING") {
		skill_id = 0x21;
	}
	if (skill == "SKILL_TAILOR") {
		skill_id = 0x22;
	}
	if (skill == "SKILL_TAME_ANIMAL") {
		skill_id = 0x23;
	}
	if (skill == "SKILL_TASTE") {
		skill_id = 0x24;
	}
	if (skill == "SKILL_TINKER") {
		skill_id = 0x25;
	}
	if (skill == "SKILL_TRACKING") {
		skill_id = 0x26;
	}
	if (skill == "SKILL_VET") {
		skill_id = 0x27;
	}
	if (skill == "UNKNOWN") {
		systemMessage(user, "Unknown skill type");
		return(0x00);
	}
	int value = getObjVar(this, "value");
	if (value > 0x64) {
		systemMessage(user, "Value too high.  0-100 only");
		return(0x00);
	}
	setSkillLevel(user, skill_id, value * 0x0A);
	string value_str = value;
	systemMessage(user, skill + " = " + value_str);
	return(0x00);
}
