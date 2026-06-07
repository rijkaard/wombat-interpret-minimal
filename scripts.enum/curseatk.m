inherits spelskil;

member int is_bow;

member int skill_penalty;

trigger equip {
	list bow_types = 0x0F4F, 0x0F50, 0x13B1, 0x13B2, 0x13FC, 0x13FD;
	int weapon = getObjType(this);
	skill_penalty = 0xC8;
	for (int i = 0x00; i < numInList(bow_types); i++) {
		int weapon_type = bow_types[i];
		if (weapon_type == weapon) {
			is_bow = 0x01;
		}
	}
	if (is_bow == 0x01) {
		loseSkillLevel(equippedon, SKILL_ARCHERY, skill_penalty);
	} else {
		loseSkillLevel(equippedon, SKILL_TACTICS, skill_penalty);
	}
	return(0x01);
}

trigger unequip {
	skill_penalty = 0xC8;
	if (is_bow == 0x01) {
		addSkillLevel(unequippedfrom, SKILL_ARCHERY, skill_penalty);
	} else {
		addSkillLevel(unequippedfrom, SKILL_TACTICS, skill_penalty);
	}
	return(0x01);
}
