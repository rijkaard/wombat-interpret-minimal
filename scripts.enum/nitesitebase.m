inherits spelskil;

function int apply_night_sight(obj user, obj usedon) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		int light_level = 0x01 + (getSkillLevel(usedon, SKILL_MAGERY) / 0x04);
		doMobAnimation(usedon, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01E3, 0x00);
		setLight(usedon, light_level, 0x01);
		success = 0x01;
		int notoriety_delta = apply_spell_notoriety(user, usedon, 0x00, this);
	}
	schedule_cleanup(this);
	return(success);
}
