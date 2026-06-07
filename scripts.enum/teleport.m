inherits teleportbase;

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
	place = find_teleport_loc(user, place);
	if (getZ(place) == (0x00 - 0x80)) {
		return(0x00);
	}
	if (!check_and_consume_reagents(user, this)) {
		return(0x00);
	}
	if (try_cast_spell(user, place, this)) {
		cast_teleport(user, place);
	} else {
		fizzle_spell(user);
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
