inherits meteorbase;

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
	target_hostile_loc(user, this, 0x02);
	return(0x00);
}

trigger targetloc {
	if (!confirm_and_clear_targeting(user, this)) {
		return(0x01);
	}
	if (!isInMap(place)) {
		return(0x00);
	}
	if (!canSeeLoc(user, place)) {
		systemMessage(user, "Target cannot be seen.");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(user), place) > 0x0C) {
		systemMessage(user, "Target is too far away.");
		return(0x00);
	}
	if (!check_and_consume_reagents(user, this)) {
		return(0x00);
	}
	if (try_cast_spell(user, place, this)) {
		apply_meteor_swarm(user, place);
	} else {
		fizzle_spell(user);
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
