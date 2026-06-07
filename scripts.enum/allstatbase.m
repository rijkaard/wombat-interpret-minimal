inherits spelskil;

function int apply_all_stat_effect(obj user, obj usedon, int is_buff, int reverse) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int duration;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		int effect_power;
		faceHere(user, getDirectionInternal(user_loc, there));
		if (hasObjVar(this, "magicItemModifier")) {
			int magic_modifier = getObjVar(this, "magicItemModifier");
			duration = 0x06 * magic_modifier;
			effect_power = magic_modifier;
		} else {
			duration = 0x06 * getSkillLevel(user, SKILL_MAGERY) / 0x05;
			effect_power = (getSkillLevel(user, SKILL_MAGERY) / 0x0A) + 0x01;
		}
		int anim_id = 0x373A;
		int sfx_id = 0x01EA;
		if (!is_buff) {
			anim_id = 0x374A;
			sfx_id = 0x01E1;
			effect_power = 0x00 - effect_power;
		}
		sfx(there, 0x01EA, 0x00);
		doMobAnimation(usedon, anim_id, 0x0A, 0x0F, 0x00, 0x00);
		for (int s = 0x00; s < 0x03; s++) {
			if (apply_stat_effect_if_absent(usedon, s, effect_power, duration)) {
				success = 0x01;
			}
		}
		if (!is_buff) {
			apply_damage_clamped(user, usedon, 0x00, reverse);
			report_obj_aggression(user, usedon, 0x02, reverse);
			notify_spell_hit(user, usedon, reverse);
			receiveUnhealthyActionFrom(usedon, user);
		}
	}
	schedule_cleanup(this);
	return(success);
}
