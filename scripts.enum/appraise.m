inherits identify;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "appraise");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	targetObj(this, this);
	systemMessage(this, "What do you wish to appraise and identify?");
	return(0x00);
}

trigger oortargetobj {
	string msg;
	if (usedon == NULL()) {
		return(0x00);
	}
	if (isMobile(usedon)) {
		barkTo(this, this, "It appears to be " + getName(usedon) + ".");
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		systemMessage(user, "You can't see that object well enough to identify it.");
		return(0x00);
	}
	int skill_variance = 0x64 - getSkillLevel(user, SKILL_ITEM_ID);
	skill_variance = 0x64 + (random(0x00 - skill_variance, skill_variance) / 0x02);
	string name;
	if (skillTest(user, SKILL_ITEM_ID)) {
		setObjVar(usedon, "appraising", 0x01);
		name = identify_item(user, usedon);
	}
	if (name == "") {
		if (hasObjVar(usedon, "lookAtText")) {
			debugMessage("Void name with ObjVar");
			name = getObjVar(usedon, "lookAtText");
		} else {
			debugMessage("Void name no ObjVar");
			name = get_display_name(usedon);
		}
	}
	msg = "It appears to be " + name + ". ";
	if (!skillTest(user, SKILL_ITEM_ID)) {
		concat(msg, "You have no idea how much it might be worth.");
		barkTo(user, user, msg);
		return(0x00);
	}
	int estimated_value = getValue(usedon) * skill_variance / 0x64);
	concat(msg, "You guess the value of that item at ");
	string value_str = estimated_value;
	concat(msg, value_str);
	concat(msg, " gold coin");
	if (estimated_value > 0x01) {
		concat(msg, "s.");
	} else {
		concat(msg, ".");
	}
	barkTo(user, user, msg);
	return(0x00);
}
