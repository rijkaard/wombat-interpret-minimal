inherits spelskil;

function int cast_unlock(obj user, obj usedon) {
	int success = 0x00;
	if (is_valid_obj(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doLocAnimation(there, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01FF, 0x00);
		if (hasObjVar(usedon, "isLocked")) {
			int lock_level = getObjVar(usedon, "isLocked");
			int skill_power = getSkillLevelReal(user, 0x19) / 0x05;
			if (lock_level < 0xFF) {
				int required_level = lock_level;
				if (skill_power < required_level) {
					barkTo(user, user, "My spell does not seem to have an effect on that lock.");
				} else {
					removeObjVar(usedon, "isLocked");
					success = 0x01;
				}
			} else {
				barkTo(user, user, "My spell had no effect on that lock.");
			}
		} else {
			barkTo(user, user, "That did not need to be unlocked.");
		}
	}
	schedule_cleanup(this);
	return(success);
}
