inherits spelskil;

function int apply_reactive_armor(obj user, obj usedon) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01F2, 0x00);
		if (!(hasScript(usedon, "reaction"))) {
			attachScript(usedon, "reaction");
			int duration = 0x19 + getSkillLevel(user, SKILL_MAGERY) / 0x02;
			callback(usedon, duration, 0x2F);
			int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
			success = 0x01;
		} else {
			barkToHued(user, user, 0x22, "This target already has Reactive Armor");
		}
	} else {
		barkToHued(user, user, 0x22, "This target is not valid. It must be a being or person.");
	}
	schedule_cleanup(this);
	return(success);
}
