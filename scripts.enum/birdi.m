inherits spelskil;

function void apply_birdeye(obj user, obj usedon) {
	int duration;
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	faceHere(user, getDirectionInternal(user_loc, there));
	if (hasObjVar(this, "magicItemModifier")) {
		int modifier = getObjVar(this, "magicItemModifier");
		duration = 0x06 * modifier;
	} else {
		duration = 0x01 + (0x05 * (getSkillLevel(user, SKILL_MAGERY)));
	}
	sfx(there, 0x01E9, 0x00);
	openGump(usedon, 0x1392);
	attachScript(usedon, "rembirdi");
	callback(usedon, duration, 0x2B);
	int item_type = getObjType(this);
	callback(this, 0x00, 0x48);
	return();
}

trigger use {
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (check_visible_range(user, usedon, 0x0C)) {
		if (!check_and_consume_reagents(user, this)) {
			return(0x00);
		}
		if (try_cast_spell(user, getLocation(usedon), this)) {
			apply_birdeye(user, usedon);
		} else {
			fizzle_spell(user);
		}
	}
	return(0x00);
}

trigger creation {
	return(0x00);
}
