inherits spelskil;

member int reflected;

member obj caster;

member obj m_target;

function int apply_fireball(obj user, obj usedon, int refl_param) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		success = 0x01;
		int damage;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		sfx(caster_loc, 0x015E, 0x00);
		doMissile_Mob2Mob(user, usedon, 0x36D4, 0x07, 0x00, 0x01);
		m_target = usedon;
		caster = user;
		callback(this, 0x01, 0x19);
		report_obj_aggression(user, usedon, 0x02, refl_param);
		reflected = refl_param;
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	int dmg = apply_spell_damage(this, caster, m_target, 0x04, reflected);
	schedule_cleanup(this);
	return(0x00);
}
