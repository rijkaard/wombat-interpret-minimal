inherits sndfx;

trigger use {
	systemMessage(user, "Who will you use the bandages on?");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		systemMessage(user, "You can not see that.");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(usedon), getLocation(user)) > 0x03) {
		systemMessage(user, "That is too far away.");
		return(0x00);
	}
	list healable_types = 0xD0, 0xCD, 0xCF, 0xDF, 0xCA, 0xD5, 0x31, 0xD4, 0xD3, 0xC8, 0xD2, 0xD9, 0xE1, 0xC9, 0xD8, 0xD1, 0xCB, 0xE2, 0xDA, 0xD6, 0xE7, 0xE4;
	if (!isMobile(usedon)) {
		systemMessage(user, "That cannot be healed.");
		return(0x00);
	}
	int cur_hp = getCurHP(usedon);
	int max_hp = getMaxHP(usedon);
	if (cur_hp == max_hp) {
		systemMessage(user, "That being is undamaged.");
		return(0x00);
	}
	if (hasScript(usedon, "noheal")) {
		systemMessage(user, "This being cannot be newly bandaged yet.");
		return(0x00);
	}
	int obj_type = getObjType(usedon);
	int okay = 0x00;
	int skill = 0x00;
	if (isInList(healable_types, obj_type)) {
		okay = 0x01;
		skill = 0x27;
	} else {
		okay = 0x01;
		skill = 0x11;
	}
	if (okay) {
		int damage = max_hp - cur_hp;
		int skill_diff = damage * 0x03E8 / max_hp;
		int skill_result = testAndLearnSkill(user, skill, skill_diff, 0x32);
		int heal_amt = 0x01;
		if (skill_result > 0x00) {
			sfx(getLocation(usedon), 0x57, 0x00);
			heal_amt = (damage * (0x32 + skill_result / 0x14)) / 0x64;
		}
		if ((cur_hp + heal_amt) <= max_hp) {
			addHP(usedon, heal_amt);
		} else {
			setCurHP(usedon, max_hp);
		}
		attachScript(usedon, "noheal");
		callback(usedon, 0xB4, 0x2C);
		if (heal_amt <= 0x01) {
			systemMessage(user, "You apply the bandages, but they barely help.");
		} else {
			systemMessage(user, "You apply the bandages.");
		}
		destroyOne(this);
		return(0x00);
	} else {
		systemMessage(user, "Bandages can not be used on that.");
	}
	return(0x00);
}
