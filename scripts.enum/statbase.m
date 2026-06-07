inherits spelskil;

function int apply_stat_spell(obj user, obj usedon, int stat_type, int is_up, int reverse) {
	int fizzled = 0x00;
	int delta;
	int duration;
	if (is_targetable_mobile(usedon)) {
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		if (hasObjVar(this, "magicItemModifier")) {
			int magic_item_mod = getObjVar(this, "magicItemModifier");
			duration = 0x06 * magic_item_mod;
			delta = magic_item_mod;
		} else {
			duration = 0x06 * getSkillLevel(user, SKILL_MAGERY) / 0x05 + 0x01;
			delta = getSkillLevel(user, SKILL_MAGERY) / 0x0A + 0x01;
		}
		if (!is_up) {
			delta = 0x00 - delta;
		}
		if (!apply_stat_effect_if_absent(usedon, stat_type, delta, duration)) {
			fizzled = 0x01;
			fizzle_spell(user);
		} else {
			doMobAnimation(usedon, get_stat_change_anim(stat_type, is_up), 0x0A, 0x0F, 0x00, 0x00);
			sfx(there, get_stat_effect_sfx_id(stat_type, is_up), 0x00);
		}
		if (!is_up) {
			apply_damage_clamped(user, usedon, 0x00, reverse);
			report_obj_aggression(user, usedon, 0x02, reverse);
			notify_spell_hit(user, usedon, reverse);
			receiveUnhealthyActionFrom(usedon, user);
		}
	}
	schedule_cleanup(this);
	return(fizzled);
}
