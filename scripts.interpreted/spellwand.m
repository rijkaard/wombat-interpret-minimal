function int can_start_cast(obj user_obj) {
	list f_args;
	int result = messageret(this, user_obj, "spellcanstartcast", f_args);
	return(result);
}

function int is_equipped(obj user_obj, obj item) {
	return(hasObjEquipped(user_obj, item));
}

function int can_use_wand(obj user_obj, obj item) {
	if (hasObjEquipped(user_obj, item)) {
		if (can_start_cast(user_obj)) {
			return(0x01);
		}
	}
	return(0x00);
}

function void start_cast(obj user) {
	list f_args;
	attachScript(user, "spellwords");
	message(user, "spellstartcast", f_args);
	return();
}

trigger use {
	if (can_use_wand(user, this)) {
		start_cast(user);
	}
	return(0x01);
}
