inherits spelskil;

member list meteor_targets;

member obj caster;

function int apply_meteor_swarm(obj user, loc place) {
	int hit = 0x00;
	int damage;
	loc caster_loc = getLocation(user);
	faceHere(user, getDirectionInternal(caster_loc, place));
	list nearby_mobs;
	clearList(meteor_targets);
	int crime_reported = 0x00;
	caster = user;
	getMobsInRange(nearby_mobs, place, 0x02);
	beginSequence();
	for (int x = 0x00; x < numInList(nearby_mobs); x++) {
		obj mob = nearby_mobs[x];
		if (is_targetable_mobile(mob)) {
			hit = 0x01;
			if (hasScript(mob, "reflctor")) {
				doMobAnimation(mob, 0x36B0, 0x0A, 0x0A, 0x00, 0x00);
				int applied_damage = apply_spell_damage(this, user, user, 0x04, 0x01);
			} else {
				int delay_ticks;
				sfx(caster_loc, 0x0160, 0x00);
				doMissile_Mob2Mob(user, mob, 0x36D4, 0x07, 0x00, 0x01);
				if ((getDistanceInTiles(caster_loc, place)) > 0x06) {
					delay_ticks = 0x02;
				} else {
					delay_ticks = 0x01;
				}
				callback(this, delay_ticks, 0x19);
				appendToList(meteor_targets, mob);
				if (!crime_reported) {
					crime_reported = 0x01;
					report_obj_aggression(caster, mob, 0x02, 0x00);
				}
			}
		}
	}
	endSequence(0x01);
	schedule_cleanup_if_miss(this, hit);
	return(hit);
}

trigger callback(0x19) {
	int hit = apply_circle_damage(0x02, this, caster, meteor_targets, 0x04);
	schedule_cleanup(this);
	return(0x00);
}
