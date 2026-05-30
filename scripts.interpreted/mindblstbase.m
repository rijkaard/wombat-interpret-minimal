inherits spelskil;

member int m_was_reflected;

member obj damage_source;

member obj damage_target;

member int pending_damage;

function int apply_mind_blast(obj user, obj usedon, int reflected_flag) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int damage;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doMobAnimation(usedon, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x0213, 0x00);
		int int_diff = (getIntelligence(user) - getIntelligence(usedon));
		obj local_target = usedon;
		obj local_source = user;
		apply_damage_clamped(user, usedon, 0x00, reflected_flag);
		if (int_diff <= 0x00) {
			int_diff = (getIntelligence(usedon) - getIntelligence(user));
			doMobAnimation(user, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
			local_target = user;
			local_source = usedon;
		}
		damage = int_diff / 0x04;
		damage_target = local_target;
		pending_damage = damage;
		damage_source = local_source;
		callback(this, 0x01, 0x19);
		report_obj_aggression(user, usedon, 0x02, reflected_flag);
		m_was_reflected = reflected_flag;
		success = 0x01;
	} else {
		bark(user, "This spell won't work on that!");
		fizzle_spell(user);
	}
	schedule_cleanup_if_miss(this, success);
	return(success);
}

trigger callback(0x19) {
	int damage_dealt = apply_spell_damage_typed(this, pending_damage, damage_source, damage_target, 0x08, m_was_reflected);
	scriptTrig(damage_target, 0x01, damage_source);
	schedule_cleanup(this);
	return(0x00);
}
