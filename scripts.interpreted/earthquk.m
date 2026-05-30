inherits earthqukbase;

trigger use {
	begin_spell_cast(this, user);
	return(0x00);
}

trigger message("castspell") {
	obj user = get_caster_2(this, args);
	if (!isValid(user)) {
		return(0x00);
	}
	if (!check_and_consume_reagents(user, this)) {
		return(0x00);
	}
	if (try_cast_spell(user, getLocation(user), this)) {
		cast_earthquake(user);
	} else {
		fizzle_spell(user);
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
