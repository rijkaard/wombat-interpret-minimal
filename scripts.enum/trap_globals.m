inherits globals;

forward void clear_trap();

forward int is_locked(obj , obj );

function void clear_trap() {
	removeObjVar(this, "trapLevel");
	removeObjVar(this, "trapType");
	return();
}

function int is_locked(obj user, obj this) {
	int locked = 0x00;
	if (hasObjVar(this, "isLocked")) {
		locked = getObjVar(this, "isLocked");
	}
	return(locked);
}

trigger creation {
	setObjVar(this, "isTrap", 0x01);
	return(0x00);
}

trigger use {
	list f_args;
	f_args = user, this;
	if (!hasObjVar(this, "disabled")) {
		message(this, "triggerTrap", f_args);
	}
	return(0x01);
}
