inherits spelskil;

function int do_mass_dispel(obj user, loc place) {
	int spell_success = 0x00;
	if (is_in_map(place)) {
		loc user_loc = getLocation(user);
		loc creature_loc;
		obj creature;
		int skill = getSkillLevelReal(user, 0x19);
		int difficulty = 0x00;
		faceHere(user, getDirectionInternal(user_loc, place));
		list mobs;
		getMobsInRange(mobs, place, 0x08);
		int mob_count;
		mob_count = numInList(mobs);
		for (int x = 0x00; x < numInList(mobs); x++) {
			int check = 0x00;
			creature = mobs[x];
			creature_loc = getLocation(mobs[x]);
			if (hasScript(creature, "destcrea")) {
				difficulty = getObjVar(creature, "summonDifficulty");
				check = (0x012C + difficulty);
				int success = testAndLearnSkill(user, 0x19, check, 0x28);
				if (success > 0x00) {
					doLocAnimation(creature_loc, 0x3728, 0x08, 0x14, 0x00, 0x00);
					sfx(creature_loc, 0x0201, 0x00);
					deleteObject(creature);
					spell_success = 0x01;
				} else {
					doMobAnimation(creature, 0x3779, 0x0A, 0x14, 0x00, 0x00);
					systemMessage(user, "The " + getName(creature) + " resisted the attempt to dispel it!");
				}
			}
		}
	}
	schedule_cleanup(this);
	return(spell_success);
}
