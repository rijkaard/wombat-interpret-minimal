inherits polymrphbase;

member int new_body_type;

trigger use {
	if (!hasObjVar(user, "oldBodyType")) {
		select_polymorph_form(user);
	} else {
		fizzle_spell(user);
	}
	return(0x00);
}

function void cast_polymorph(obj user, int newType) {
	new_body_type = newType;
	begin_spell_cast(this, user);
	return();
}

trigger message("castspell") {
	obj user = get_caster_2(this, args);
	if (!isValid(user)) {
		return(0x00);
	}
	if (hasObjVar(user, "oldBodyType")) {
		fizzle_spell(user);
		return(0x00);
	}
	if (!check_and_consume_reagents(user, this)) {
		return(0x00);
	}
	if ((!(hasObjVar(user, "oldBodyType"))) && (try_cast_spell(user, getLocation(user), this))) {
		set_polymorph_type(user, new_body_type);
	} else {
		fizzle_spell(user);
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
