inherits spelskil;

member int reflected;

member obj caster;

member obj m_target;

function int cast_lightning(obj user, obj usedon, int refl_param) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int damage;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doLightning(usedon);
		sfx(there, 0x29, 0x00);
		m_target = usedon;
		caster = user;
		report_obj_aggression(user, usedon, 0x02, refl_param);
		callback(this, 0x01, 0x19);
		reflected = refl_param;
		success = 0x01;
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	if (!isValid(m_target)) {
		return(0x00);
	}
	int dmg = apply_spell_damage(this, caster, m_target, 0x02, reflected);
	schedule_cleanup(this);
	return(0x00);
}
