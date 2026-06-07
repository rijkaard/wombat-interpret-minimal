inherits spelskil;

function int apply_area_cure(obj user, loc place, int skill_override) {
	list mobs_in_range;
	loc user_loc = getLocation(user);
	int cure_power;
	int poison_power;
	int poison;
	int success = 0x00;
	if (skill_override != 0x00) {
		cure_power = (skill_override * 0x4B);
	} else {
		cure_power = (getSkillLevel(user, SKILL_MAGERY) * 0x4B);
	}
	faceHere(user, getDirectionInternal(user_loc, place));
	getMobsInRange(mobs_in_range, place, 0x02);
	obj mob;
	for (int x = 0x00; x < numInList(mobs_in_range); x++) {
		mob = mobs_in_range[x];
		poison = getObjVar(mob, "poison_strength");
		poison_power = (poison * 0x06D6);
		doMobAnimation(mob, 0x373A, 0x0A, 0x0F, 0x00, 0x00);
		if (is_targetable_mobile(mob)) {
			if ((hasScript(mob, "poisoned")) || (hasObjVar(mob, "poison_strength"))) {
				if (((0x2710 + (cure_power - poison_power)) / 0x64) > random(0x01, 0x64)) {
					cure_poison(mob);
					int not_delta = apply_spell_notoriety(user, mob, 0x00, this);
					systemMessage(mob, " " + getName(user) + " has cured you of all poisons!");
				} else {
					systemMessage(mob, " " + getName(user) + " has failed to cure you!");
				}
				success = 0x01;
			}
		}
	}
	sfx(place, 0x01E8, 0x00);
	schedule_cleanup(this);
	return(success);
}
