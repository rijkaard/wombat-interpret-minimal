inherits sndfx;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "poisonsk");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);

member int stage = 0x00;
	systemMessage(this, "Select the poison you wish to use.");
	stage = 0x01;
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x03) {
		systemMessage(this, "That is too far away for you to use.");
		return(0x00);
	}

member obj poison_potion;

member int poison_power;
	if (stage == 0x01) {
		if ((isMobile(usedon)) || (getObjType(usedon) != 0x0F0A)) {
			systemMessage(user, "That is not a poison potion.");
			stage = 0x00;
			return(0x00);
		}
		poison_potion = usedon;
		poison_power = getObjVar(usedon, "power");
		stage = 0x02;
		systemMessage(user, "To what do you wish to apply the poison?");
		targetObj(user, this);
		return(0x00);
	}
	if (stage != 0x02) {
		stage = 0x00;
		return(0x00);
	}
	int food = 0x00;
	int drink = 0x00;
	int is_alcohol = 0x00;
	int is_consumable = 0x00;
	if (hasObjVar(usedon, "I_am_food")) {
		food = getObjVar(usedon, "I_am_food");
		if (food == 0x01) {
			is_consumable = 0x01;
		}
	}
	if (hasObjVar(usedon, "I_am_alcohol")) {
		is_alcohol = getObjVar(usedon, "I_am_alcohol");
		if (is_alcohol == 0x01) {
			is_consumable = 0x01;
		}
	}
	if (hasObjVar(usedon, "I_am_potable")) {
		drink = getObjVar(usedon, "I_am_potable");
		if (drink == 0x01) {
			is_consumable = 0x01;
		}
	}
	if (!isWeapon(usedon) && (!is_consumable)) {
		systemMessage(user, "You cannot poison that! You can only poison bladed or piercing weapons, food or drink.");
		return(0x00);
	}
	if (isWeapon(usedon)) {
		if (!isPiercing(usedon) && !isSlashing(usedon)) {
			systemMessage(user, "You cannot poison that! You can only poison bladed or piercing weapons.");
			return(0x00);
		}
		if (!testSkill(user, SKILL_POISONING)) {
			systemMessage(user, "You fail to apply a sufficient dose of poison on " + getWeaponName(usedon) + ".");
			destroyOne(poison_potion);
			return(0x00);
		}
		if (random(0x00, 0x64) < getSkillLevel(this, SKILL_POISONING)) {
			systemMessage(user, "You apply a dose of poison to " + getWeaponName(usedon) + ".");
			if (poison_power != 0x01) {
				poison_power--;
			} else {
				poison_power = 0x01;
			}
			setObjVar(usedon, "poison_strength", poison_power);
			sfx(getLocation(user), 0x0247, 0x00);
		} else {
			systemMessage(user, "You apply a strong dose of poison to " + getWeaponName(usedon) + ".");
			poison_power;
			setObjVar(usedon, "poison_strength", poison_power);
			sfx(getLocation(user), 0x0247, 0x00);
		}
		attachScript(usedon, "poisweap");
		setObjVar(usedon, "poison_chance", getSkillLevel(this, SKILL_POISONING) / 0x04);
		setObjVar(usedon, "poison_left", (0x14 - (poison_power * 0x02)));
		destroyOne(poison_potion);
		return(0x00);
	} else {
		if (!testSkill(user, SKILL_POISONING)) {
			systemMessage(user, "You fail to apply a sufficient dose of poison to " + getName(usedon) + ".");
			return(0x00);
		}
		if (getSkillLevel(this, SKILL_POISONING) < random(0x00, 0x64)) {
			systemMessage(user, "You apply a dose of poison to " + getName(usedon) + ".");
			if (poison_power > 0x01) {
				poison_power--;
			}
			setObjVar(usedon, "poison_strength", poison_power);
			sfx(getLocation(user), 0x0247, 0x00);
		} else {
			systemMessage(user, "You apply a strong dose of poison to " + getName(usedon) + ".");
			if (poison_power < 0x05) {
				poison_power++;
			}
			setObjVar(usedon, "poison_strength", poison_power);
			sfx(getLocation(user), 0x0247, 0x00);
		}
		copyControllerInfo(usedon, user);
		attachScript(usedon, "poisfood");
		setObjVar(usedon, "poison_chance", getSkillLevel(this, SKILL_POISONING) / 0x04);
		destroyOne(poison_potion);
		return(0x00);
	}
	return(0x00);
}
