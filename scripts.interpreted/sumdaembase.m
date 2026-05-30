inherits spelskil;

function int summon_daemon(obj user) {
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
		obj daemon = createGlobalNPCAt(0x0255, there, 0x00);
		if (daemon != NULL()) {
			doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
			doLocAnimation(there, 0x3728, 0x08, 0x14, 0x00, 0x00);
			sfx(there, 0x0216, 0x00);
			setType(daemon, 0x0A);
			attachScript(daemon, "destcrea");
			setObjVar(daemon, "summonDifficulty", 0x03B6);
			int init_result = setup_follower(daemon, user, 0x64, 0x01);
			callback(daemon, despawn_delay, 0x08);
			changeKarma(user, (0x00 - 0x1B58));
			success = 0x01;
		} else {
			barkTo(user, user, "Whoops...something got in the way.");
		}
	}
	schedule_cleanup(this);
	return(success);
}
