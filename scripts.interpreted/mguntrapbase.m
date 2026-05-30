inherits spelskil;

function int do_untrap(obj user, obj usedon) {
	int success = 0x00;
	if (is_valid_obj(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doLocAnimation(getLocation(usedon), 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01F0, 0x00);
		if (hasObjVar(usedon, "isTrapped")) {
			success = 0x01;
			setObjVar(usedon, "disarmed", 0x01);
		} else {
			if (hasScript(usedon, "mgtp_use")) {
				detachScript(usedon, "mgtp_use");
				success = 0x01;
			} else {
				barkToHued(user, user, 0x22, "That isn't trapped.");
			}
		}
	}
	schedule_cleanup(this);
	return(success);
}
