inherits spelskil;

function int validate_target(obj user, obj usedon) {
	if (!isValid(usedon)) {
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "Target can not be seen");
		return(0x00);
	}
	return(0x01);
}

function int apply_telekinesis(obj user, obj usedon) {
	int success = 0x00;
	if (validate_target(user, usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doLocAnimation(getLocation(usedon), 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01F5, 0x00);
		useItem(user, usedon);
		success = 0x01;
	}
	schedule_cleanup(this);
	return(success);
}
