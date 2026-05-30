inherits spelskil;

member int is_bow;

member int skill_bonus;

trigger equip {
	list bow_types = 0x0F4F, 0x0F50, 0x13B1, 0x13B2, 0x13FC, 0x13FD;
	int weapon = getObjType(this);
	for (int i = 0x00; i < numInList(bow_types); i++) {
		int bow_type = bow_types[i];
		if (bow_type == weapon) {
			is_bow = 0x01;
		}
	}
	int mod;
	if (is_bow == 0x01) {
		mod = modifySkillMod(equippedon, 0x1F, skill_bonus);
	} else {
		mod = modifySkillMod(equippedon, 0x1B, skill_bonus);
	}
	return(0x01);
}

trigger unequip {
	int mod;
	if (is_bow == 0x01) {
		mod = modifySkillMod(unequippedfrom, 0x1F, (0x00 - skill_bonus));
	} else {
		mod = modifySkillMod(unequippedfrom, 0x1B, (0x00 - skill_bonus));
	}
	return(0x01);
}
