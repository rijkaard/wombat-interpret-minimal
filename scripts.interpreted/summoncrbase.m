inherits spelskil;

function int summon_creature(obj user) {
	int success = 0x00;
	int duration;
	loc user_loc = getLocation(user);
	list creature_types = 0x029E, 0x028C, 0x028D, 0x028E, 0x028F, 0x0290, 0x0291, 0x0292, 0x0293, 0x0294, 0x0295, 0x0296, 0x0297, 0x0298, 0x0299, 0x029B, 0x029C, 0x029D;
	loc there = find_summon_location(user);
	if (!isInMap(there)) {
		fizzle_spell(user);
		systemMessage(user, "There is no room to summon that here.");
	} else {
		faceHere(user, getDirectionInternal(user_loc, there));
		if (hasObjVar(this, "magicItemModifier")) {
			int item_modifier = getObjVar(this, "magicItemModifier");
			duration = 0x06 * item_modifier;
		} else {
			if (getSkillLevel(user, 0x19) < 0x0A) {
				duration = 0x14;
			} else {
				duration = 0x14 * getSkillLevel(user, 0x19) / 0x05;
			}
		}
		int rand_idx = random(0x00, 0x11);
		obj creature = createGlobalNPCAt(creature_types[rand_idx], there, 0x00);
		if (creature != NULL()) {
			doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
			sfx(there, 0x0215, 0x00);
			attachScript(creature, "destcrea");
			setObjVar(creature, "summonDifficulty", 0x00);
			int pet_init_result = setup_follower(creature, user, 0x64, 0x01);
			callback(creature, duration, 0x08);
			success = 0x01;
		} else {
			barkTo(user, user, "Whoops...something got in the way.");
		}
	}
	schedule_cleanup(this);
	return(success);
}
