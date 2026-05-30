inherits spelskil;

member list hit_targets;

member obj caster;

member int strike_count;

function int apply_chain_lightning(obj user, loc place) {
	int hit = 0x00;
	loc caster_loc = getLocation(user);
	faceHere(user, getDirectionInternal(caster_loc, place));
	clearList(hit_targets);
	list nearby_mobs;
	getMobsInRange(nearby_mobs, place, 0x02);
	int mob_count = numInList(nearby_mobs);
	beginSequence();
	caster = user;
	strike_count = 0x00;
	int crime_reported = 0x00;
	for (int x = 0x00; x < mob_count; x++) {
		obj mob = nearby_mobs[x];
		if (is_targetable_mobile(mob)) {
			if (hasScript(mob, "reflctor")) {
				doLightning(user);
				detachScript(mob, "reflctor");
				int damage = apply_spell_damage(this, caster, caster, 0x02, 0x01);
				if (!crime_reported) {
					crime_reported = 0x01;
					report_obj_aggression(user, mob, 0x02, 0x00);
				}
			} else {
				hit = 0x01;
				doLightning(mob);
				if (!crime_reported) {
					crime_reported = 0x01;
					report_obj_aggression(user, mob, 0x02, 0x00);
				}
				callback(this, 0x01, 0x19);
				appendToList(hit_targets, mob);
			}
		}
	}
	endSequence(0x01);
	sfx(place, 0x29, 0x00);
	schedule_cleanup_if_miss(this, hit);
	return(hit);
}

trigger callback(0x19) {
	int dmg = apply_circle_damage(0x02, this, caster, hit_targets, 0x02);
	schedule_cleanup(this);
	return(0x00);
}
