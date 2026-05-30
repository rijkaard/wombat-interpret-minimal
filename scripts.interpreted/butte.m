inherits sndfx;

member int outer_hit_count;

member int mid_hit_count;

member int inner_hit_count;

member int bullseye_hit_count;

member obj shooter;

member int impact_sfx;

member int miss_sfx;

member obj ammo;

member int score;

trigger creation {
	outer_hit_count = 0x00;
	mid_hit_count = 0x00;
	inner_hit_count = 0x00;
	bullseye_hit_count = 0x00;
	shooter = NULL();
	score = 0x00;
	return(0x01);
}

trigger lookedat {
	if (score) {
		bark(this, "an archery butte (score:" + score + ")");
		return(0x00);
	}
	return(0x01);
}

trigger ooruse {
	if (isDead(user)) {
		barkTo(user, user, "You're a ghost, and can't do that.");
		return(0x01);
	}
	int butte_type = getObjType(this);
	loc there = getLocation(this);
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, there));
	if (shooter != NULL()) {
		barkTo(user, user, "Wait until it's clear!");
		return(0x01);
	}
	if (getDistanceInTiles(getLocation(user), getLocation(this)) == 0x01) {
		list objs_at_butte;
		getObjectsInRangeWithFlags(objs_at_butte, getLocation(this), 0x00, 0x0800);
		int gathered_count = 0x00;
		for (int i = 0x00; i < numInList(objs_at_butte); i++) {
			if (getZ(getLocation(objs_at_butte[i])) == getZ(getLocation(this))) {
				int result = putObjContainer(objs_at_butte[i], getBackpack(user));
				gathered_count++;
			}
		}
		outer_hit_count = 0x00;
		mid_hit_count = 0x00;
		inner_hit_count = 0x00;
		bullseye_hit_count = 0x00;
		score = 0x00;
		if (gathered_count > 0x00) {
			ebarkTo(user, user, "You gather the arrows and bolts.");
			return(0x01);
		}
	}
	int anim_frames;
	int anim_id;
	list ammo_list;
	obj weapon = getWeapon(user);
	if (!isRanged(weapon)) {
		barkTo(this, user, "You must practice with ranged weapons on this.");
		return(0x01);
	}
	int weapon_type = getObjType(weapon);
	int ammo_type;
	obj ammo_obj = NULL();
	impact_sfx = 0x0234;
	if (weapon_type == 0x13B1) {
		miss_sfx = 0x0238;
		ammo_type = 0x0F42;
		ammo_obj = mobileContainsObjType(user, 0x0F3F);
	}
	if (weapon_type == 0x13B2) {
		miss_sfx = 0x0238;
		ammo_type = 0x0F42;
		ammo_obj = mobileContainsObjType(user, 0x0F3F);
	}
	if (weapon_type == 0x0F4F) {
		miss_sfx = 0x0239;
		ammo_type = 0x1BFE;
		ammo_obj = mobileContainsObjType(user, 0x0F3F);
	}
	if (weapon_type == 0x0F50) {
		miss_sfx = 0x0239;
		ammo_type = 0x1BFE;
		ammo_obj = mobileContainsObjType(user, 0x1BFB);
	}
	if (weapon_type == 0x13FC) {
		miss_sfx = 0x023A;
		ammo_type = 0x1BFE;
		ammo_obj = mobileContainsObjType(user, 0x1BFB);
	}
	if (weapon_type == 0x13FD) {
		miss_sfx = 0x023A;
		ammo_type = 0x1BFE;
		ammo_obj = mobileContainsObjType(user, 0x1BFB);
	}
	if (ammo_obj == NULL()) {
		if (ammo_type == 0x0F42) {
			ebarkTo(user, user, "You do not have any arrows with which to practice.");
		} else {
			ebarkTo(user, user, "You do not have any crossbow bolts with which to practice.");
		}
		return(0x01);
	}
	string ammo_name;
	int user_x = getX(user_loc);
	int user_y = getY(user_loc);
	int butte_x = getX(there);
	int butte_y = getY(there);
	if (butte_type == 0x100A) {
		if (user_x < butte_x) {
			ebarkTo(user, user, "You would do better to stand in front of the archery butte.");
			return(0x01);
		}
		if (user_y != butte_y) {
			ebarkTo(user, user, "You aren't properly lined up with the archery butte to get an accurate shot.");
			return(0x01);
		}
		if ((user_x - butte_x) > 0x06) {
			ebarkTo(user, user, "You are too far away from the archery butte to get an accurate shot.");
			return(0x01);
		}
		if ((user_x - butte_x) < 0x05) {
			ebarkTo(user, user, "You are too close to the target.");
			return(0x01);
		}
	}
	if (butte_type == 0x100B) {
		if (user_y < butte_y) {
			ebarkTo(user, user, "You would do better to stand in front of the archery butte.");
			return(0x01);
		}
		if (user_x != butte_x) {
			ebarkTo(user, user, "You aren't properly lined up with the archery butte to get an accurate shot.");
			return(0x01);
		}
		if ((user_y - butte_y) > 0x06) {
			ebarkTo(user, user, "You are too far away from the archery butte to get an accurate shot.");
			return(0x01);
		}
		if ((user_y - butte_y) < 0x05) {
			ebarkTo(user, user, "You are too close to the target.");
			return(0x01);
		}
	}
	if (getItemAtSlot(user, 0x19) != NULL()) {
		anim_frames = 0x05;
		anim_id = 0x1B;
	} else {
		anim_id = 0x12;
	}
	if (!isHuman(user)) {
		anim_frames = 0x04;
		anim_id = random(0x04, 0x06);
	}
	animateMobile(user, anim_id, anim_frames, 0x01, 0x00, 0x00);
	doMissile_Mob2Loc(user, there, ammo_type, 0x05, 0x00, 0x00);
	shooter = user;
	callback(this, 0x01, 0x19);
	if (getQuantity(ammo_obj) > 0x01) {
		ammo = createNoResObjectAt(getObjType(ammo_obj), getLocation(this));
		transferGeneric(ammo, ammo_obj, 0x01);
	} else {
		result = teleport(ammo_obj, getLocation(this));
		ammo = ammo_obj;
	}
	return(0x00);
}

trigger callback(0x19) {
	obj user = shooter;
	shooter = NULL();
	int sfx_id = impact_sfx;
	int robinhood = 0x00;
	string ammo_name;
	if (getObjType(ammo) == 0x0F3F) {
		ammo_name = "arrow";
	} else {
		ammo_name = "bolt";
	}
	int success = testAndLearnSkill(user, 0x1F, 0x00, 0x32);
	if (success <= 0x00) {
		ebarkTo(this, user, "You miss the target altogether.");
		sfx_id = miss_sfx;
	} else {
		string ring_name;
		int zone = random(0x00, 0x09C4 - success) / 0xC8;
		switch(zone) {
		case 0x00
			ring_name = "bullseye!";
			if (random(0x00, 0x0A) < bullseye_hit_count) {
				robinhood = 0x01;
				score = score + 0x64;
			} else {
				bullseye_hit_count++;
				score = score + 0x32;
			}
			break;
		case 0x01
		case 0x02
		case 0x03
			ring_name = "inner ring!";
			if (random(0x00, 0x0A) < inner_hit_count) {
				robinhood = 0x01;
				score = score + 0x1E;
			} else {
				mid_hit_count++;
				score = score + 0x0A;
			}
			break;
		case 0x04
		case 0x05
		case 0x06
		case 0x07
		case 0x08
			ring_name = "middle ring.";
			if (random(0x00, 0x0A) < mid_hit_count) {
				robinhood = 0x01;
				score = score + 0x0F;
			} else {
				mid_hit_count++;
				score = score + 0x05;
			}
			break;
		default
			ring_name = "outer ring.";
			if (random(0x00, 0x0A) < outer_hit_count) {
				robinhood = 0x01;
				score = score + 0x05;
			} else {
				outer_hit_count++;
				score = score + 0x02;
			}
			break;
		}
		if (robinhood) {
			deleteObject(ammo);
			barkTo(this, user, "Your " + ammo_name + " robinhoods another in the " + ring_name);
		} else {
			barkTo(this, user, "You hit the " + ring_name);
		}
	}
	sfx(getLocation(this), sfx_id, 0x00);
	return(0x01);
}
