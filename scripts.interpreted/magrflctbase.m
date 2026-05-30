inherits spelskil;

function int apply_magic_reflect(obj user, obj usedon) {
	int success = 0x00;
	if ((!is_targetable_mobile(usedon)) || (hasScript(usedon, "reflctor"))) {
		fizzle_spell(user);
	} else {
		int duration;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		success = 0x01;
		doMobAnimation(usedon, 0x375A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x01E9, 0x00);
		if (getSkillLevel(user, 0x19) < 0x0A) {
			duration = 0x0A;
		} else {
			duration = 0x0A * getSkillLevel(user, 0x19) / 0x05;
		}
		attachScript(usedon, "reflctor");
		callback(usedon, duration, 0x16);
	}
	schedule_cleanup(this);
	return(success);
}
