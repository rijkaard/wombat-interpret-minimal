inherits spelskil;

member loc where;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "hidesk");
	return(0x00);
}

trigger callback(0x54) {
	reveal(this);
	return(0x00);
}

trigger callback(0x94) {
	if (getLocation(this) != where) {
		reveal_impl(this, 0x00);
	} else {
		callback(this, 0x01, 0x94);
	}
	return(0x01);
}

function int can_see_any(list them, obj it) {
	int num = numInList(them);
	for (int i = 0x00; i < num; i++) {
		obj mob = them[i];
		if (canSeeObj(it, mob)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int can_hide(obj it) {
	int combat_count = getNumTargets(it) + getNumAttackers(it);
	list targets;
	list attackers;
	getTargets(targets, it);
	getAttackers(attackers, it);
	if (can_see_any(targets, it)) {
		return(0x00);
	}
	if (can_see_any(attackers, it)) {
		return(0x00);
	}
	return(0x01);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	if (!can_hide(this)) {
		barkToHued(this, this, 0x22, "You can't seem to hide right now.");
		return(0x00);
	}
	loc here = getLocation(this);
	int skill = getSkillLevel(this, 0x15);
	list nearby;
	getObjectsInRangeWithFlags(nearby, here, 0x02, 0x40);
	int nearby_count = numInList(nearby);
	int roll_threshold = skill + nearby_count;
	int roll = random(0x01, 0x64);
	if (roll <= roll_threshold) {
		where = getLocation(this);
		callback(this, 0x01, 0x94);
		hide(this);
		barkToHued(this, this, 0x01F4, "You have hidden yourself well.");
	} else {
		barkToHued(this, this, 0x22, "You can't seem to hide here.");
	}
	int test = testSkill(this, 0x15);
	callback(this, 0x012C, 0x54);
	return(0x00);
}

trigger message("uninvis") {
	reveal_impl(this, 0x00);
	return(0x01);
}
