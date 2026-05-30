inherits spelskil;

function int cast_dispel_field(obj user, obj usedon) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doLocAnimation(there, 0x376A, 0x09, 0x14, 0x00, 0x00);
		sfx(there, 0x0201, 0x00);
		if (hasScript(usedon, "destroy")) {
			deleteObject(usedon);
			success = 0x01;
		}
	}
	schedule_cleanup(this);
	return(success);
}
