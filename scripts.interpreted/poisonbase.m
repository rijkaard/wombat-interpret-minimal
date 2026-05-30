inherits spelskil;

function int apply_poison_effect(obj user, obj usedon, int reverse) {
	int poison_applied = 0x00;
	if (is_targetable_mobile(usedon)) {
		int poison_level;
		int magery_skill;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x0205, 0x00);
		if (!hasScript(usedon, "poisoned")) {
			apply_damage_clamped(user, usedon, 0x00, reverse);
			receiveUnhealthyActionFrom(usedon, user);
			report_obj_aggression(user, usedon, 0x02, reverse);
			if (isValid(usedon) && (!test_magic_resist(user, usedon, 0x03))) {
				magery_skill = getSkillLevel(user, 0x19);
				if (random(0x01, 0x64) < magery_skill) {
					poison_level = 0x02;
				} else {
					poison_level = 0x04;
				}
				if ((!hasObjVar(usedon, "poison_strength")) && (!hasScript(usedon, "poisoned"))) {
					setObjVar(usedon, "poison_strength", poison_level);
					attachScript(usedon, "poisoned");
					poison_applied = 0x01;
					if (isValid(usedon)) {
						scriptTrig(usedon, 0x01, user);
					}
				}
			}
		}
	}
	schedule_cleanup(this);
	return(poison_applied);
}
