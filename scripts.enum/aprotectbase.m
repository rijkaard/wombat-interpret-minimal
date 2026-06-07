inherits spelskil;

function int apply_area_protection(obj user, loc place) {
	list mobs_in_range;
	int defenseBonus;
	int success = 0x00;
	defenseBonus = (getSkillLevel(user, SKILL_MAGERY) / 0x0A);
	int duration = 0x06 * getSkillLevel(user, SKILL_MAGERY) / 0x05;
	getMobsInRange(mobs_in_range, place, 0x02);
	for (int x = 0x00; x < numInList(mobs_in_range); x++) {
		obj mob = mobs_in_range[x];
		if (is_targetable_mobile(mob)) {
			if (!(hasScript(mob, "reflctor"))) {
				if (!(hasScript(mob, "remprtct"))) {
					doMobAnimation(mob, 0x375A, 0x09, 0x14, 0x00, 0x00);
					setObjVar(mob, "defenseBonus", defenseBonus);
					int new_ac = getNaturalAC(mob) + defenseBonus;
					setNaturalAC(mob, new_ac);
					attachScript(mob, "remprtct");
					int not_delta = apply_spell_notoriety(user, mob, 0x00, this);
					callback(mob, duration, 0x13);
					sfx(place, 0x01F7, 0x00);
					success = 0x01;
				}
			}
		}
	}
	schedule_cleanup(this);
	return(success);
}
