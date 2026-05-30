inherits spelskil;

function int apply_paralyze(obj user, obj usedon, int reverse) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		if (!getMobFlag(usedon, 0x02)) {
			int duration;
			loc user_loc = getLocation(user);
			loc there = getLocation(usedon);
			faceHere(user, getDirectionInternal(user_loc, there));
			if (hasObjVar(this, "magicItemModifier")) {
				duration = 0x02 * (getObjVar(this, "magicItemModifier")) + 0x05;
			} else {
				duration = (getSkillLevel(user, 0x19) / 0x0A + 0x01) * 0x02 + 0x05;
			}
			if (test_magic_resist(NULL(), usedon, 0x05)) {
				duration = duration / 0x02;
			}
			doMobAnimation(usedon, 0x376A, 0x06, duration, 0x00, 0x00);
			sfx(there, 0x0204, 0x00);
			setWaitState(usedon, duration);
			int wait_state = waitState(usedon);
			setMobFlag(usedon, 0x02, 0x01);
			scriptTrig(usedon, 0x01, user);
			if (isValid(usedon)) {
				apply_damage_clamped(user, usedon, 0x00, reverse);
				if (isValid(usedon)) {
					report_obj_aggression(user, usedon, 0x02, reverse);
					if (isValid(usedon)) {
						attachScript(usedon, "rempara");
						callback(usedon, duration, 0x0D);
					}
				}
			}
		}
	}
	schedule_cleanup(this);
	return(success);
}
