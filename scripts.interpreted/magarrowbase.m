inherits spelskil;

member int reflected;

member obj caster;

member obj m_target;

function int cast_magic_arrow(obj user, obj usedon, int refl_param) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int damage;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		success = 0x01;
		doMissile_Mob2Mob(user, usedon, 0x36E4, 0x05, 0x00, 0x00);
		sfx(user_loc, 0x01E5, 0x00);
		m_target = usedon;
		caster = user;
		report_obj_aggression(user, usedon, 0x02, refl_param);
		callback(this, 0x01, 0x19);
		reflected = refl_param;
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	int dmg = apply_spell_damage(this, caster, m_target, 0x01, reflected);
	schedule_cleanup(this);
	return(0x00);
}
