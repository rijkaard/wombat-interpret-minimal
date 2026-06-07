inherits spelskil;

function void scatter_corpse_contents(obj corpse) {
	list contents;
	getContents(contents, corpse);
	int num = numInList(contents);
	for (int i = 0x00; i < num; i++) {
		obj item = contents[i];
		if (isHair(item)) {
			deleteObject(item);
		} else {
			int rc = teleport(item, getLocation(corpse));
		}
	}
	deleteObject(corpse);
	return();
}

function int is_corpse_type(obj corpse) {
	if (getObjType(corpse) == 0x2006) {
		return(0x01);
	}
	return(0x00);
}

function int get_summon_duration(obj it, obj caster, int flags, obj target) {
	int duration = 0x04 * (0x3C + getSkillLevel(caster, SKILL_MAGERY) * 0x03);
	return(duration);
}

function int validate_summon_target(obj caster, obj corpse) {
	loc caster_loc = getLocation(caster);
	loc corpse_loc = getLocation(corpse);
	int dist = getDistanceInTiles(getLocation(caster), getLocation(corpse));
	if (dist > 0x05) {
		return(0x00);
	}
	if (!is_corpse_type(corpse)) {
		barkTo(caster, caster, "I must use a human corpse.");
		return(0x00);
	}
	return(0x01);
}

function int summon_undead(obj user, obj corpse) {
	loc user_loc = getLocation(user);
	loc there = user_loc;
	list temp_list;
	there = getLocation(corpse);
	faceHere(user, getDirectionInternal(user_loc, there));
	int delay = 0x00;
	int delay_ticks = get_summon_duration(this, user, delay, corpse);
	int daemon_template = 0x021D;
	obj daemon = createGlobalNPCAt(daemon_template, there, 0x00);
	if (daemon == NULL()) {
		barkTo(user, user, "Something is in the way.");
		return(0x00);
	}
	doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
	doLocAnimation(there, 0x3728, 0x08, 0x14, 0x00, 0x00);
	attachScript(daemon, "destcrea");
	int result = setup_follower(daemon, user, 0x64, 0x01);
	scatter_corpse_contents(corpse);
	faceHere(daemon, getDirectionInternal(there, user_loc));
	callback(daemon, delay_ticks, 0x08);
	return(0x01);
}

trigger creation {
	setObjVar(this, "lookAtText", "Wand of Necromancy");
	return(0x01);
}

trigger use {
	if (!isEditing(user)) {
		return(0x00);
	}
	if (!isValid(user)) {
		return(0x00);
	}
	if (getTopmostContainer(this) != user) {
		return(0x00);
	}
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isEditing(user)) {
		return(0x00);
	}
	if (getTopmostContainer(this) != user) {
		return(0x00);
	}
	if (validate_summon_target(user, usedon)) {
		int result = summon_undead(user, usedon);
	}
	return(0x00);
}
