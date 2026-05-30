inherits spelskil;

member int count;

member list targets;

function void apply_effect(obj victim) {
	return();
}

function int is_valid_quake_target(obj caster, obj victim) {
	if (!can_target_victim(caster, victim)) {
		return(0x00);
	}
	if (isGuard(victim)) {
		return(0x00);
	}
	return(0x01);
}

function int cast_earthquake(obj user) {
	int success = 0x00;
	loc user_loc = getLocation(user);
	count = 0x00;
	sfx(user_loc, 0x020D, 0x00);
	clearList(targets);
	list mobs_nearby;
	getMobsInRange(mobs_nearby, user_loc, 0x0A);
	for (int i = 0x00; i < numInList(mobs_nearby); i++) {
		obj victim = mobs_nearby[i];
		if (is_targetable_mobile(victim)) {
			if (is_valid_quake_target(user, victim)) {
				appendToList(targets, victim);
			}
		}
	}
	obj target_mob;
	int damage;
	int dmg_result;
	for (i = 0x00; i < numInList(targets); i++) {
		success = 0x01;
		target_mob = targets[i];
		damage = getCurHP(target_mob) - (getMaxHP(target_mob) / 0x02);
		if (isNPC(target_mob)) {
			damage = damage / 0x04;
		}
		disableBehaviors(target_mob);
		apply_effect(target_mob);
		report_obj_aggression(user, target_mob, 0x01, 0x00);
		if (damage > 0x00) {
			dmg_result = apply_spell_damage_typed(this, damage, user, target_mob, 0x08, 0x00);
			success = 0x01;
		}
	}
	shortcallback(this, 0x02, 0x36);
	schedule_cleanup(this);
	return(0x01);
}

trigger callback(0x36) {
	obj m_target;
	if (count < 0x03) {
		for (int i = 0x00; i < numInList(targets); i++) {
			m_target = targets[i];
			if (isValid(m_target)) {
				apply_effect(m_target);
			}
		}
		shortcallback(this, 0x02, 0x36);
		count++;
		return(0x00);
	} else {
		for (i = 0x00; i < numInList(targets); i++) {
			m_target = targets[i];
			if (isValid(m_target)) {
				enableBehaviors(m_target);
			}
		}
	}
	schedule_cleanup(this);
	return(0x00);
}
