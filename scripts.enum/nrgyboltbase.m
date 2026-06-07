inherits spelskil;

member int m_was_reflected;

member obj caster;

member obj m_target;

function int launch_energy_bolt(obj user, obj usedon, int is_reflected) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doMissile_Mob2Mob(user, usedon, 0x379F, 0x07, 0x00, 0x01);
		sfx(user_loc, 0x020A, 0x00);
		m_target = usedon;
		caster = user;
		callback(this, 0x01, 0x19);
		report_obj_aggression(user, usedon, 0x02, is_reflected);
		m_was_reflected = is_reflected;
		success = 0x01;
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	int dmg = apply_spell_damage(this, caster, m_target, 0x02, m_was_reflected);
	if (isValid(m_target)) {
		scriptTrig(m_target, 0x01, caster);
	}
	schedule_cleanup(this);
	return(0x00);
}
