inherits spelskil;

function int summon_air_elemental(obj user) {
	int success = 0x00;
	int despawn_delay;
	loc user_loc = getLocation(user);
	loc there = find_summon_location(user);
	if (!isInMap(there)) {
		fizzle_spell(user);
		systemMessage(user, "There is no room to summon that here.");
	} else {
		faceHere(user, getDirectionInternal(user_loc, there));
		if (hasObjVar(this, "magicItemModifier")) {
			int item_modifier = getObjVar(this, "magicItemModifier");
			despawn_delay = 0x06 * item_modifier;
		} else {
			if (getSkillLevel(user, 0x19) < 0x0A) {
				despawn_delay = 0x14;
			} else {
				despawn_delay = 0x14 * getSkillLevel(user, 0x19) / 0x05;
			}
		}
		obj elemental = createGlobalNPCAt(0x0258, there, 0x00);
		if (elemental != NULL()) {
			sfx(there, 0x0217, 0x00);
			setType(elemental, 0x0D);
			doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
			animateMobile(elemental, 0x0C, 0x0F, 0x01, 0x00, 0x00);
			attachScript(elemental, "destcrea");
			setObjVar(elemental, "summonDifficulty", 0x02EE);
			int init_result = setup_follower(elemental, user, 0x64, 0x01);
			callback(elemental, despawn_delay, 0x08);
			success = 0x01;
		} else {
			bark(user, "Whoops...something got in the way.");
		}
	}
	schedule_cleanup(this);
	return(success);
}
