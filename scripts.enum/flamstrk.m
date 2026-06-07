inherits flamstrkbase;

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
	target_hostile_obj(user, this);
	return(0x00);
}

trigger targetobj {
	if (!confirm_and_clear_targeting(user, this)) {
		return(0x01);
	}
	if (usedon == NULL()) {
		return(0x00);
	}
	if (check_visible_range(user, usedon, 0x0C)) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, getLocation(usedon), this)) {
			if (hasScript(usedon, "reflctor")) {
				doMobAnimation(usedon, 0x37B9, 0x06, 0x05, 0x00, 0x00);
				apply_flame_strike(usedon, user, 0x01);
				detachScript(usedon, "reflctor");
			} else {
				apply_flame_strike(user, usedon, 0x00);
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
		apply_flame_strike(target, user, 0x01);
		remove_reflection(target);
	} else {
		apply_flame_strike(user, target, 0x00);
	}
	return(0x00);
}
