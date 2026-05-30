inherits spelskil;

function int is_lockable(obj user, obj usedon) {
	int item = getObjType(usedon);
	if ((0x0E40 <= item) && (item <= 0x0E43)) {
		if (!hasObjVar(usedon, "isLocked")) {
			return(0x01);
		}
	}
	return(0x00);
}

function int apply_magic_lock(obj user, obj usedon) {
	int success = 0x00;
	if (is_valid_obj(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		if (is_lockable(user, usedon)) {
			doLocAnimation(getLocation(usedon), 0x376A, 0x09, 0x20, 0x00, 0x00);
			sfx(there, 0x01F4, 0x00);
			if (!hasScript(usedon, "locked")) {
				attachScript(usedon, "locked");
			}
			setObjVar(usedon, "isLocked", 0x00);
			bark(user, "The chest is now locked!");
			success = 0x01;
		}
	}
	if (!success) {
		bark(user, "Hmmm...I can't lock that.");
	}
	schedule_cleanup(this);
	return(success);
}
