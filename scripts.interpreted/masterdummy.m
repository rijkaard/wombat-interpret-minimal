inherits sndfx;

trigger creation {
	int obj_type = getObjType(this);
	if ((obj_type > 0x1074) && (obj_type < 0x1078)) {
		setType(this, 0x1074);
	}
	if ((obj_type > 0x1070) && (obj_type < 0x1074)) {
		setType(this, 0x1070);
	}
	if ((obj_type > 0x1EC0) && (obj_type < 0x1EC3)) {
		setType(this, 0x1EC0);
	}
	if ((obj_type > 0x1EC3) && (obj_type < 0x1EC5)) {
		setType(this, 0x1EC3);
	}
	return(0x01);
}

trigger use {
	if (isDead(user)) {
		return(0x00);
	}
	if (hasObjVar(this, "isSwinging")) {
		int obj_type = getObjType(this);
		if ((obj_type == 0x1070) || (obj_type == 0x1074) || (obj_type == 0x1EC0) || (obj_type == 0x1EC3)) {
			removeObjVar(this, "isSwinging");
		}
	}
	if (hasObjVar(this, "isSwinging")) {
		ebarkTo(this, user, "You have to wait until it stops swinging.");
		return(0x00);
	}
	setObjVar(this, "isSwinging", 0x01);
	callback(this, 0x03, 0x42);
	if (getDistanceInTiles(getLocation(this), getLocation(user)) > 0x01) {
		ebarkTo(this, user, "You are too far away to do that.");
		return(0x01);
	}
	faceHere(user, getDirectionInternal(getLocation(user), getLocation(this)));
	obj_type = getObjType(this);
	if ((obj_type == 0x1070) || (obj_type == 0x1074)) {
		int frame_count;
		int anim_id;
		list skills;
		int hands = 0x01;
		obj weapon = getWeapon(user);
		if (weapon == NULL()) {
			appendToList(skills, 0x2B);
			frame_count = 0x07;
			anim_id = 0x09;
		}
		if (getWeaponHandedness(weapon) == 0x04) {
			hands = 0x02;
		}
		if (isPiercing(weapon)) {
			appendToList(skills, 0x2A);
			if (hands == 0x01) {
				frame_count = 0x07;
				anim_id = 0x0A;
			} else {
				frame_count = 0x07;
				anim_id = 0x0E;
			}
		}
		if (isBashing(weapon)) {
			appendToList(skills, 0x29);
			if (hands == 0x01) {
				frame_count = 0x07;
				anim_id = 0x0B;
			} else {
				frame_count = 0x07;
				anim_id = 0x0C;
			}
		}
		if (isSlashing(weapon)) {
			appendToList(skills, 0x28);
			if (hands == 0x01) {
				frame_count = 0x07;
				anim_id = 0x09;
			} else {
				frame_count = 0x07;
				anim_id = 0x0D;
			}
		}
		if (getItemAtSlot(user, 0x19) != NULL()) {
			frame_count = 0x05;
			if (hands == 0x01) {
				anim_id = 0x1A;
			} else {
				anim_id = 0x1D;
			}
		}
		if (isRanged(weapon)) {
			ebarkTo(this, user, "You can't practice ranged weapons on this.");
			return(0x01);
		}
		if (!isHuman(user)) {
			frame_count = 0x04;
			anim_id = random(0x04, 0x06);
		}
		animateMobile(user, anim_id, frame_count, 0x01, 0x00, 0x00);
		int obj_type2 = getObjType(this);
		if (obj_type2 == 0x1070) {
			setType(this, 0x1071);
		}
		if (obj_type2 == 0x1074) {
			setType(this, 0x1075);
		}
		list hit_sfx = 0x013A, 0x013C, 0x013F, 0x0141, 0x0144, 0x0148;
		sfx(getLocation(this), hit_sfx[random(0x00, 0x05)], 0x00);
		int skill_result;
		string debug;
		if (numInList(skills) < 0x01) {
			return(0x01);
		}
		for (int i = 0x00; i < numInList(skills); i++) {
			if (getSkillSuccessChance(user, skills[i], 0x00, 0x32) >= 0x03E8) {
				ebarkTo(this, user, "Your skill cannot improve any further by simply practicing with a dummy.");
				callback(this, 0x03, 0x42);
				return(0x01);
			}
			skill_result = testAndLearnSkill(user, skills[i], 0x00, 0x32);
			if (!random(0x00, 0x09)) {
				skill_result = testAndLearnSkill(user, 0x1B, 0x00, 0x32);
			}
		}
	}
	if ((obj_type == 0x1EC0) || (obj_type == 0x1EC3)) {
		if (getItemAtSlot(user, 0x19) != NULL()) {
			ebarkTo(this, user, "You can't practice on this while on horseback.");
			return(0x01);
		}
		if (!isHuman(user)) {
			return(0x01);
		}
		obj_type2 = getObjType(this);
		sfx(getLocation(this), 0x4F, 0x00);
		if (getSkillSuccessChance(user, 0x21, 0x00, 0x32) >= 0x03E8) {
			ebarkTo(this, user, "Your ability to steal cannot improve any further by simply practicing on a dummy.");
			callback(this, 0x03, 0x42);
			return(0x01);
		}
		if (testAndLearnSkill(user, 0x21, 0x00, 0x32) <= 0x00) {
			ebarkTo(this, user, "You carelessly bump the dip and start it swinging.");
			sfx(getLocation(this), 0x41, 0x00);
			sfx(getLocation(this), 0x41, 0x00);
			if (obj_type2 == 0x1EC0) {
				setType(this, 0x1EC1);
			}
			if (obj_type2 == 0x1EC3) {
				setType(this, 0x1EC4);
			}
		} else {
			ebarkTo(this, user, "You successfully avoid disturbing the dip while searching it.");
		}
	}
	loseFatigue(user, 0x02);
	return(0x01);
}

trigger callback(0x42) {
	removeObjVar(this, "isSwinging");
	int obj_type = getObjType(this);
	if ((obj_type > 0x1074) && (obj_type < 0x1078)) {
		setType(this, 0x1074);
	}
	if ((obj_type > 0x1070) && (obj_type < 0x1074)) {
		setType(this, 0x1070);
	}
	if ((obj_type > 0x1EC0) && (obj_type < 0x1EC3)) {
		setType(this, 0x1EC0);
	}
	if ((obj_type > 0x1EC3) && (obj_type < 0x1EC5)) {
		setType(this, 0x1EC3);
	}
	return(0x01);
}

trigger time("hour:**") {
	shortcallback(this, 0x01, 0x42);
	return(0x01);
}
