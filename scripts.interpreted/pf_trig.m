inherits spelskil;

function void apply_poison_field_to_target(obj caster, obj target) {
	if (!isValid(target)) {
		return();
	}
	if (isCounselor(target) || isDead(target)) {
		return();
	}
	if (target_in_z_range(caster, target)) {
		sfx(getLocation(target), 0x0205, 0x00);
		if (!hasScript(target, "poisoned")) {
			int resist = 0x00;
			resist = test_magic_resist(NULL(), target, 0x05);
			receiveUnhealthyActionFrom(target, caster);
			if (!resist) {
				setObjVar(target, "poison_strength", 0x02);
				attachScript(target, "poisoned");
				scatter_npc(target);
			}
		}
	}
	return();
}

trigger creation {
	shortCallback(this, 0x01, 0x2F);
	return(0x01);
}

trigger enterrange(0x00) {
	apply_poison_field_to_target(this, target);
	callback(this, 0x01, 0x2F);
	return(0x01);
}

trigger callback(0x2F) {
	loc field_loc = getLocation(this);
	list mobs;
	getMobsInRange(mobs, field_loc, 0x01);
	for (int i = 0x00; i < numInList(mobs); i++) {
		obj target = mobs[i];
		apply_poison_field_to_target(this, target);
	}
	if (numInList(mobs) > 0x00) {
		callback(this, 0x01, 0x2F);
	} else {
		setObjVar(this, "defensive", 0x01);
	}
	return(0x01);
}
