inherits sk_table;

member obj tame_target;

member int tame_attempt_count;

trigger message("canUseSkill") {
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x5C);
	systemMessage(this, "Tame which animal?");
	targetObj(this, this);
	return(0x00);
}

trigger callback(0x5C) {
	if (tame_attempt_count == 0x00) {
		detachScript(this, "tame");
	}
	return(0x00);
}

function void say_taming_phrase(obj animal) {
	string name = getName(animal);
	removePrefix(name, "a ");
	removePrefix(name, "an ");
	switch(random(0x00, 0x09)) {
	case 0x00
	case 0x01
		bark(this, "Here " + name + ".");
		break;
	case 0x02
	case 0x03
		bark(this, "Nice " + name + ".");
		break;
	case 0x04
	case 0x05
		bark(this, "Good " + name + ".");
		break;
	case 0x06
		bark(this, "Will you be my friend?");
		break;
	case 0x07
		bark(this, "I've always wanted a pet like you.");
		break;
	case 0x08
		bark(this, "Don't be afraid.");
		break;
	case 0x09
		bark(this, "I won't hurt you.");
		break;
	}
	return();
}

trigger callback(0x5D) {
	if (!hasScript(tame_target, "beingtamed")) {
		ebarkTo(tame_target, this, "The animal is too angry to continue taming.");
		detachScript(this, "tame");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(this), getLocation(tame_target)) > 0x07) {
		ebarkTo(tame_target, this, "You are too far away to continue taming.");
		callback(tame_target, 0x00, 0x5C);
		detachScript(this, "tame");
		return(0x00);
	}
	tame_attempt_count++;
	if (tame_attempt_count < 0x05) {
		if (random(0x00, 0x01) == 0x00) {
			say_taming_phrase(tame_target);
		}
		shortCallback(this, 0x08, 0x5D);
		return(0x00);
	}
	callback(tame_target, 0x00, 0x5C);
	int success = testAndLearnSkill(this, SKILL_ANIMAL_TAMING, 0x0C * getObjVar(tame_target, "petCanTame"), 0x32);
	if (success >= 0x03E8) {
		ebarkTo(tame_target, this, "That wasn't even challenging.");
	}
	if (success < 0x00) {
		ebarkTo(tame_target, this, "You fail to tame the creature.");
		detachScript(this, "tame");
		return(0x00);
	}
	if (success > 0x0384) {
		success = 0x0384;
	}
	list myBoss = this;
	setObjVar(tame_target, "myBoss", myBoss);
	setObjVar(tame_target, "myLoyalty", success / 0x0A + 0x0A);
	setObjVar(tame_target, "isPet", 0x01);
	makeBeelineFailPathfind(tame_target, 0x01);
	disableBehaviors(tame_target);
	attachScript(tame_target, "pet");
	ebarkTo(tame_target, this, "It seems to accept you as master.");
	detachScript(this, "tame");
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		detachScript(this, "tame");
		return(0x00);
	}
	if (!canSeeObj(this, usedon)) {
		ebarkTo(usedon, this, "You can't see that.");
		detachScript(this, "tame");
		return(0x00);
	}
	if ((!isMobile(usedon)) || (!hasObjVar(usedon, "petCanTame"))) {
		ebarkTo(usedon, this, "You can't tame that!");
		detachScript(this, "tame");
		return(0x00);
	}
	if (hasScript(usedon, "beingtamed")) {
		ebarkTo(usedon, this, "Someone else is already taming this.");
		detachScript(this, "tame");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(this), getLocation(usedon)) > 0x03) {
		ebarkTo(usedon, this, "It's too far away.");
		detachScript(this, "tame");
		return(0x00);
	}
	if (hasObjListVar(usedon, "myBoss")) {
		ebarkTo(usedon, this, "That animal looks tame already.");
		detachScript(this, "tame");
		return(0x00);
	}
	int obj_type = getObjType(usedon);
	if ((obj_type == 0x0C) || (obj_type == 0x3B) || (obj_type == 0x3C) || (obj_type == 0x3D)) {
		int roll = random(0x01, 0x0A);
		if (roll != 0x01) {
			ebarkTo(usedon, this, "You seem to anger the beast!");
			attack(usedon, this);
			detachScript(this, "tame");
			return(0x00);
		}
	}
	int success = getSkillSuccessChance(this, SKILL_ANIMAL_TAMING, 0x0C * getObjVar(usedon, "petCanTame"), 0x32);
	if (success <= 0x00) {
		ebarkTo(usedon, this, "You have no chance of taming this creature.");
		detachScript(this, "tame");
		return(0x00);
	}
	tame_target = usedon;
	actionBark(this, 0x59, "*You start to tame " + getName(tame_target) + ".*", "*" + getName(this) + " starts to tame " + getName(tame_target) + ".*");
	attachScript(tame_target, "beingtamed");
	tame_attempt_count = 0x00;
	shortCallback(this, 0x08, 0x5D);
	return(0x00);
}
