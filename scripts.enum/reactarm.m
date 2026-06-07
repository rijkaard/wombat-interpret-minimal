inherits reactarmbase;

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
	target_friendly_obj(user, this);
	return(0x00);
}

trigger targetobj {
	if (!confirm_and_clear_targeting(user, this)) {
		return(0x01);
	}
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isMobile(usedon)) {
		return(0x00);
	}
	if (check_target_in_range(user, usedon, 0x00)) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, getLocation(usedon), this)) {
			apply_reactive_armor(user, usedon);
		} else {
			fizzle_spell(user);
		}
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
