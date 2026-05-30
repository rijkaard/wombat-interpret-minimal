inherits recallbase;

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
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (!confirm_and_clear_targeting(user, this)) {
		return(0x01);
	}
	if (!validate_recall_target(user, usedon)) {
		return(0x00);
	}
	reveal_and_notify(user);
	if (hasObjVar(usedon, "markLoc")) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, getLocation(usedon), this)) {
			execute_recall(user, usedon);
		} else {
			fizzle_spell(user);
		}
	} else {
		systemMessage(user, "Target is not marked.");
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
