inherits spelskil;

member int reflected;

member obj caster;

member obj m_target;

function int apply_explosion(obj user, obj usedon, int refl_param) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		success = 0x01;
		int damage;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x36BD, 0x14, 0x0A, 0x00, 0x00);
		sfx(there, 0x0207, 0x00);
		m_target = usedon;
		caster = user;
		callback(this, 0x03, 0x19);
		reflected = refl_param;
		report_obj_aggression(user, usedon, 0x02, refl_param);
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	int dmg = apply_spell_damage(this, caster, m_target, 0x04, reflected);
	schedule_cleanup(this);
	return(0x00);
}
