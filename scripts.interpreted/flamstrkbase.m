inherits spelskil;

member int reflected;

member obj caster;

member obj m_target;

function int apply_flame_strike(obj user, obj usedon, int refl_param) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		success = 0x01;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x3709, 0x0A, 0x1E, 0x01, 0x00);
		sfx(there, 0x0208, 0x00);
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
	int dmg = apply_spell_damage(this, caster, m_target, 0x04, reflected);
	scriptTrig(m_target, 0x01, caster);
	schedule_cleanup(this);
	return(0x00);
}
