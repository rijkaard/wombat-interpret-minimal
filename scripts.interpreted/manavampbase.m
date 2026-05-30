inherits spelskil;

function int apply_mana_vampire(obj user, obj usedon, int is_reflected) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doMobAnimation(usedon, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x01F9, 0x00);
		if (!test_magic_resist(user, usedon, 0x07)) {
			int target_mana = getCurMana(usedon);
			int user_mana = getCurMana(user);
			setCurMana(user, target_mana + user_mana);
			setCurMana(usedon, 0x00);
			scriptTrig(usedon, 0x01, user);
		}
		apply_damage_clamped(user, usedon, 0x00, is_reflected);
		report_obj_aggression(user, usedon, 0x02, is_reflected);
		success = 0x01;
	}
	schedule_cleanup(this);
	return(success);
}
