inherits bldsprtsbase;

trigger use {
	begin_spell_cast(this, user);
	return(0x00);
}

trigger message("castspell") {
	obj user = get_caster_2(this, args);
	if (!isValid(user)) {
		return(0x00);
	}
	begin_targeting(user, this);
	targetLoc(user, this);
	return(0x00);
}

trigger targetloc {
	if (!confirm_and_clear_targeting(user, this)) {
		return(0x01);
	}
	if (!isInMap(place)) {
		return(0x00);
	}
	if (canSeeLoc(user, place) == 0x01) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, place, this)) {
			summon_blood_spirit(user, place);
		} else {
			fizzle_spell(user);
		}
	} else {
		systemMessage(user, "Target cannot be seen.");
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}

trigger callback(0x49) {
	obj user = getObjVar(this, "user");
	obj target = getObjVar(this, "target");
	summon_blood_spirit(user, getLocation(target));
	return(0x00);
}
