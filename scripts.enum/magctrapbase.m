inherits spelskil;

function int cast_magic_trap(obj user, obj usedon) {
	int success = 0x00;
	if (is_valid_obj(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		int item = getObjType(usedon);
		loc loc_east = there;
		loc loc_north = there;
		loc loc_west = there;
		loc loc_south = there;
		setX(loc_east, getX(there) + 0x01);
		setY(loc_north, getY(there) - 0x01);
		setX(loc_west, getX(there) - 0x01);
		setY(loc_south, getY(there) + 0x01);
		beginSequence();
		doLocAnimation(loc_east, 0x376A, 0x09, 0x0A, 0x00, 0x00);
		doLocAnimation(loc_north, 0x376A, 0x09, 0x0A, 0x00, 0x00);
		doLocAnimation(loc_west, 0x376A, 0x09, 0x0A, 0x00, 0x00);
		doLocAnimation(loc_south, 0x376A, 0x09, 0x0A, 0x00, 0x00);
		endSequence(0x01);
		sfx(there, 0x01EF, 0x00);
		int power = getSkillLevel(user, SKILL_MAGERY) + 0x01;
		if (0x0675 <= item) {
			if (item <= 0x06F4) {
				setObjVar(usedon, "magictrappower", power);
				attachScript(usedon, "mgtp_use");
				success = 0x01;
			}
		} else {
			if (0x0E3F < item) {
				if (item <= 0x0E43) {
					setObjVar(usedon, "magictrappower", power);
					attachScript(usedon, "mgtp_use");
					success = 0x01;
				}
			}
		}
		report_loc_aggression(user, getLocation(usedon), 0x02, 0x00);
	}
	if (!success) {
		barkToHued(user, user, 0x22, "Hmmm...I can't trap that.");
	}
	schedule_cleanup(this);
	return(success);
}
