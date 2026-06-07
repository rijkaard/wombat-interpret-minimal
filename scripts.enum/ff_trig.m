inherits spelskil;

member int caster_hit;

trigger message("hitsomething") {
	obj caster = get_caster_1(this);
	obj hitter = args[0x00];
	if (caster == hitter) {
		caster_hit = 0x01;
	}
	return(0x01);
}

trigger creation {
	shortCallback(this, 0x01, 0x2F);
	return(0x01);
}

function void apply_fire_field_hit(obj field, obj target, int circle) {
	if (target_in_z_range(field, target)) {
		sfx(getLocation(target), 0x0208, 0x00);
		obj caster = get_caster_1(field);
		if ((caster_hit) || (target == caster)) {
			caster = NULL();
		} else {
			list msg_args;
			appendToList(msg_args, caster);
			messageToRange(getLocation(this), 0x04, "hitsomething", msg_args);
		}
		scatter_npc(target);
		int damage = apply_spell_damage_by_circle(NULL(), circle, this, target, 0x04, 0x00);
	}
	return();
}

trigger enterrange(0x00) {
	apply_fire_field_hit(this, target, 0x04);
	callback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	loc here = getLocation(this);
	list mobs;
	getMobsInRange(mobs, here, 0x00);
	for (int i = 0x00; i < numInList(mobs); i++) {
		obj target = mobs[i];
		apply_fire_field_hit(this, target, 0x02);
	}
	if (numInList(mobs) > 0x00) {
		callback(this, 0x01, 0x2F);
	} else {
		setObjVar(this, "defensive", 0x01);
	}
	return(0x01);
}
