inherits spelskil;

function int apply_invisibility(obj user, obj usedon) {
	int success = 0x00;
	if (!is_targetable_mobile(usedon)) {
		barkToHued(user, user, 0x22, "You cannot make an inanimate object invisible.");
	} else {
		int duration;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		if (hasScript(usedon, "reminvis")) {
			if (isInvisible(usedon)) {
				fizzle_spell(user);
				callback(this, 0x00, 0x48);
				return(success);
			} else {
				detachScript(usedon, "reminvis");
			}
		}
		doMobAnimation(usedon, 0x376A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x0203, 0x00);
		if (hasObjVar(this, "magicItemModifier")) {
			int magic_modifier = getObjVar(this, "magicItemModifier");
			duration = 0x06 * magic_modifier;
		} else {
			if (getSkillLevel(user, SKILL_MAGERY) < 0x0A) {
				duration = 0x06;
			} else {
				duration = 0x06 * getSkillLevel(user, SKILL_MAGERY) / 0x05;
			}
		}
		attachScript(usedon, "reminvis");
		setInvisible(usedon, 0x01);
		int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
		callback(usedon, duration, 0x1F);
		success = 0x01;
	}
	schedule_cleanup(this);
	return(success);
}
