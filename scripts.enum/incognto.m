inherits incogntobase;

trigger use {
	begin_spell_cast(this, user);
	return(0x00);
}

trigger message("castspell") {
	obj user = get_caster_2(this, args);
	if (!isValid(user)) {
		return(0x00);
	}
	obj usedon = user;
	if (check_target_in_range(user, usedon, 0x00)) {
		if (validate_incognito_target(usedon)) {
			if (!check_and_consume_reagents(user, this)) {
				return(0x00);
			}
			if (try_cast_spell(user, getLocation(usedon), this)) {
				apply_incognito(user, usedon);
			} else {
				fizzle_spell(user);
			}
		} else {
			systemMessage(user, "Incognito can not be cast on that.");
			return(0x00);
		}
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
