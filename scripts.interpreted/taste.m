inherits sndfx;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "taste");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "What would you like to taste?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int food = 0x00;
	int drink = 0x00;
	int is_alcohol = 0x00;
	int tasteable = 0x00;
	int potion = 0x00;
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x01) {
		systemMessage(user, "You are too far away to do that.");
		return(0x00);
	}
	if (isMobile(usedon)) {
		barkTo(usedon, user, "That's not something you can taste.");
		return(0x00);
	}
	int item_type = getObjType(usedon);
	switch(item_type) {
	case 0x0F06
	case 0x0F07
	case 0x0F08
	case 0x0F09
	case 0x0F0A
	case 0x0F0B
	case 0x0F0C
	case 0x0F0D
		tasteable = 0x01;
		potion = 0x01;
		break;
	default
		tasteable = 0x00;
		break;
	}
	if (hasObjVar(usedon, "I_am_food")) {
		food = getObjVar(usedon, "I_am_food");
		if (food == 0x01) {
			tasteable = 0x01;
		}
	}
	if (hasObjVar(usedon, "I_am_alcohol")) {
		is_alcohol = getObjVar(usedon, "I_am_alcohol");
		if (is_alcohol == 0x01) {
			tasteable = 0x01;
		}
	}
	if (hasObjVar(usedon, "I_am_potable")) {
		drink = getObjVar(usedon, "I_am_potable");
		if (drink == 0x01) {
			tasteable = 0x01;
		}
	}
	if (tasteable == 0x00) {
		barkTo(usedon, user, "That's not something you can taste.");
		return(0x00);
	}
	int skill = getSkillLevelReal(user, 0x24);
	int roll = random(0x01, 0x03E8);
	if (tasteable == 0x01) {
		if (testSkill(user, 0x24)) {
			sfx(getLocation(user), 0x30, 0x00);
			if (potion) {
				int potion_type = getObjType(usedon);
				switch(potion_type) {
				case 0x0F0B
					barkTo(usedon, user, "This potion may have been made from black pearl.");
					break;
				case 0x0F08
					barkTo(usedon, user, "This potion may have been made from bloodmoss.");
					break;
				case 0x0F06
					barkTo(usedon, user, "This potion may have been made from garlic.")break;
				case 0x0F0C
					barkTo(usedon, user, "This potion may have been made from ginseng.");
					break;
				case 0x0F09
					barkTo(usedon, user, "This potion may have been made from mandrake.");
					break;
				case 0x0F0A
					barkTo(usedon, user, "You sense a hint of foulness about " + getName(usedon) + ".");
					barkTo(usedon, user, "This potion may have been made from nightshade.");
					break;
				case 0x0F07
					barkTo(usedon, user, "This potion may have been made from spider silk.");
					break;
				case 0x0F0D
					barkTo(usedon, user, "This potion may have been made from sulfurous ash.");
					break;
				default
					barkTo(usedon, user, "This potion's ingredients are unknown to you.");
					break;
				}
				return(0x00);
			}
			if (hasScript(usedon, "poisfood")) {
				barkTo(usedon, user, "You sense a hint of foulness about " + getName(usedon) + ".");
				return(0x00);
			}
			barkTo(usedon, user, "There is nothing unusual about " + getName(usedon) + ".");
			return(0x00);
		} else {
			barkTo(usedon, user, "You cannot discern anything about this substance.");
			return(0x00);
		}
	}
	return(0x00);
}
