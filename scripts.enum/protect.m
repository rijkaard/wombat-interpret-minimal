inherits protectbase;

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
		systemMessage(user, "That can not be protected.");
		return(0x00);
	}
	if (check_visible_range(user, usedon, 0x0C)) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, getLocation(usedon), this)) {
			if (hasScript(usedon, "reflctor")) {
				doMobAnimation(usedon, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
				apply_protection_effect(usedon, user);
				detachScript(usedon, "reflctor");
			} else {
				apply_protection_effect(user, usedon);
			}
		} else {
			fizzle_spell(user);
		}
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}

trigger callback(0x49) {
	obj user = getObjVar(this, "user");
	obj target = getObjVar(this, "target");
	if (is_reflected(user, target)) {
		apply_protection_effect(target, user);
		remove_reflection(target);
	} else {
		apply_protection_effect(user, target);
	}
	return(0x00);
}
