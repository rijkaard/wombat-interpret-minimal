inherits spelskil;

function int apply_strength_spell(obj user, obj usedon) {
	int notoriety_delta = 0x00;
	if (is_targetable_mobile(usedon)) {
		int delta;
		int duration;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		if (hasObjVar(this, "magicItemModifier")) {
			int magic_item_mod = getObjVar(this, "magicItemModifier");
			duration = 0x06 * magic_item_mod;
			delta = magic_item_mod;
		} else {
			duration = 0x06 * getSkillLevel(user, 0x19) / 0x05 + 0x01;
			delta = getSkillLevel(user, 0x19) / 0x0A + 0x01;
		}
		if (!apply_stat_effect_if_absent(usedon, 0x00, delta, duration)) {
			fizzle_spell(user);
		} else {
			doMobAnimation(usedon, 0x375A, 0x0A, 0x0F, 0x00, 0x00);
			sfx(there, 0x01EE, 0x00);
			notoriety_delta = apply_spell_notoriety(user, usedon, 0x00, this);
		}
	}
	schedule_cleanup(this);
	return(notoriety_delta);
}
