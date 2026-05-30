function int isOnAnyMulti(obj m_target) {
	return(isAnyMultiBelow(getLocation(m_target)) != NULL());
}

function int is_multi_at(loc where) {
	return(isAnyMultiBelow(where) != NULL());
}

function int on_same_multi(obj a, obj b) {
	return(isAnyMultiBelow(getLocation(a)) == isAnyMultiBelow(getLocation(b)));
}

function int on_same_multi_as_loc(obj target_obj, loc where) {
	return(isAnyMultiBelow(getLocation(target_obj)) == isAnyMultiBelow(where));
}

function int is_on_multi(obj target_obj, obj multi) {
	return(isAnyMultiBelow(getLocation(target_obj)) == multi);
}

function obj get_multi_at(loc where) {
	return(isAnyMultiBelow(where));
}

function obj get_multi_of(obj it) {
	return(isAnyMultiBelow(getLocation(it)));
}

function int check_disabled(obj user, string feature_name, int disabled) {
	if (disabled) {
		string msg;
		msg = feature_name;
		concat(msg, " has been temporarily disabled.");
		systemMessage(user, msg);
		return(0x01);
	}
	return(0x00);
}

function int is_boss_of(obj pet, obj boss) {
	list boss_list;
	if (!hasObjListVar(pet, "myBoss")) {
		return(0x00);
	}
	getObjListVar(boss_list, pet, "myBoss");
	return(isInList(boss_list, boss));
}

function int can_resurrect_target(obj user, obj usedon) {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (user == usedon) {
		systemMessage(user, "Thou can not resurrect thyself.");
		return(0x00);
	}
	if (isDead(user)) {
		systemMessage(user, "The resurrecter must be alive.");
		return(0x00);
	}
	if (canSeeObj(user, usedon) == 0x01) {
		if (isPlayer(usedon)) {
			if (!isDead(usedon)) {
				systemMessage(user, "Target is not dead.");
				return(0x00);
			}
			loc target = getLocation(usedon);
			int target_height = getHeight(usedon);
			if (0x07 != canExistAt(target, target_height, 0x01)) {
				systemMessage(user, "Target can not be resurrected at that location.");
				return(0x00);
			}
			loc user_loc = getLocation(user);
			if ((getDistanceInTiles(user_loc, target) > 0x01) || (!on_same_multi(user, usedon))) {
				systemMessage(user, "Target is not close enough.");
				return(0x00);
			}
			return(0x01);
		} else {
			systemMessage(user, "Target is not a being.");
			return(0x00);
		}
	} else {
		systemMessage(user, "Target cannot be seen.");
		return(0x00);
	}
	return(0x00);
}

function void offer_resurrect(obj user, obj usedon, int res_type, string desc) {
	setObjVar(usedon, "resurrectLocation", getLocation(usedon));
	setObjVar(usedon, "resurrectCaster", user);
	setObjVar(usedon, "resurrectType", res_type);
	setObjVar(usedon, "resurrectDesc", desc);
	attachScript(usedon, "resmenu");
	return();
}

function int get_orig_notoriety(obj mob) {
	int notoriety;
	if (hasObjVar(mob, "origNotoriety")) {
		notoriety = getObjVar(mob, "origNotoriety");
	} else {
		notoriety = getNotoriety(mob);
	}
	return(notoriety);
}

function int get_notoriety_level(obj m_target) {
	return(getNotorietyLevelByNot(get_orig_notoriety(m_target)));
}

function int dedupe_list(list lst) {
	int dupes = 0x00;
	list orig;
	copyList(orig, lst);
	clearList(lst);
	obj it;
	int num = numInList(orig);
	for (int i = 0x00; i < num; i++) {
		it = orig[i];
		if (isInList(lst, it)) {
			dupes++;
		} else {
			appendToList(lst, it);
		}
	}
	return(dupes);
}

function void reveal_impl(obj mob, int remove_script) {
	if (isInvisible(mob)) {
		setInvisible(mob, 0x00);
	}
	if (remove_script) {
		if (hasScript(mob, "hidesk")) {
			detachScript(mob, "hidesk");
		}
	}
	return();
}

function void reveal(obj m_target) {
	reveal_impl(m_target, 0x01);
	return();
}

function void hide(obj m_target) {
	if (!isInvisible(m_target)) {
		setInvisible(m_target, 0x01);
	}
	return();
}

function void set_caster(obj effect, obj caster) {
	setObjVar(effect, "caster", caster);
	return();
}

function obj get_caster_1(obj effect) {
	obj caster = NULL();
	if (hasObjVar(effect, "caster")) {
		caster = getObjVar(effect, "caster");
	}
	return(caster);
}

function int roll_skill_check(obj mob, int skill, int min_val, int max_val) {
	return(getSkillSuccessChance(mob, skill, min_val, max_val) - random(0x00, 0x03E7));
}

function void trigger_teleport(obj m_target, loc where) {
	attachScript(m_target, "teleobj");
	list f_args;
	appendToList(f_args, where);
	message(m_target, "teleobj", f_args);
	return();
}

function void adjust_weapon_class(obj it, int da, int db, int dc, int dd) {
	int va;
	int vb;
	int vc;
	int vd;
	getWeaponClass(it, va, vb, vc, vd);
	va = va + da;
	vb = vb + db;
	vc = vc + dc;
	vd = vd + dd;
	setWeaponClass(it, va, vb, vc, vd);
	return();
}

function void relay_message(obj recipient, string msg, list args) {
	if (isValid(recipient)) {
		message(recipient, msg, args);
		return();
	}
	obj probe = createNoResObjectAt(0x01, getLocation(this));
	setObjVar(probe, "recipient", recipient);
	attachScript(probe, "comprobe");
	prependToList(args, msg);
	message(probe, "addMessage", args);
	int ok = teleport(probe, getRelayLoc(recipient));
	clearList(args);
	if (isValid(probe)) {
		message(probe, "teleported", args);
	}
	return();
}

function int isHumanBodyType(int body_type) {
	return((body_type == 0x0190) || (body_type == 0x0191));
}

function int is_human_corpse(obj it) {
	if (isCorpse(it)) {
		int body_type = getCorpseBodyType(it);
		if (isHumanBodyType(body_type)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int is_undead(obj victim) {
	if (!isMobile(victim)) {
		return(0x00);
	}
	int obj_type = getObjType(victim);
	switch(obj_type) {
	case 0x18
	case 0x1A
	case 0x32
	case 0x38
	case 0x03
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function void dissolve_corpse(obj corpse) {
	list contents;
	getContents(contents, corpse);
	int num = numInList(contents);
	for (int i = 0x00; i < num; i++) {
		obj item = contents[i];
		if (isHair(item)) {
			deleteObject(item);
		} else {
			int r = teleport(item, getLocation(corpse));
		}
	}
	deleteObject(corpse);
	return();
}

function loc get_forge_loc(loc where) {
	loc result;
	list fire_tiles = 0x0FE6, 0x0FE7, 0x0FE8, 0x0FE9, 0x0FEA, 0x0FEB, 0x0FEC, 0x0FED, 0x0FEE;
	loc blah = where;
	if (objectsNearby(fire_tiles, blah, 0x06, 0x0FEA)) {
		result = blah;
		return(result);
	}
	list forge_tiles = 0x120E, 0x120F, 0x1210, 0x1211, 0x1212, 0x1213, 0x1214, 0x1215, 0x1216;
	if (objectsNearby(forge_tiles, blah, 0x06, 0x1216)) {
		result = blah;
		return(result);
	}
	return(result);
}

function int count_forge_items(obj user, int do_use, loc where) {
	list forge_types = 0x0A26, 0x0A27, 0x0A28, 0x0A29, 0x142F, 0x1433, 0x1437, 0x1853, 0x1857, 0x1C16;
	list nearby;
	int count = 0x00;
	getObjectsInRange(nearby, where, 0x02);
	int nearby_count = numInList(nearby);
	int type_count = numInList(forge_types);
	for (int i = 0x00; i < nearby_count; i++) {
		int type = getObjType(nearby[i]);
		for (int j = 0x00; j < type_count; j++) {
			if (type == (forge_types[j])) {
				count++;
				if (do_use) {
					useItem(user, nearby[i]);
				}
			}
		}
	}
	return(count);
}

function void reveal_and_notify(obj m_target) {
	reveal_impl(m_target, 0x00);
	list f_args;
	message(m_target, "uninvis", f_args);
	return();
}

function void set_look_text(obj it, string desc) {
	setObjVar(it, "lookAtText", desc);
	return();
}

function void destroy_if_not_in_spellbook(obj it) {
	obj container = containedBy(it);
	if (container == NULL()) {
		destroyOne(it);
		return();
	}
	if (!isSpellbook(container)) {
		destroyOne(it);
	}
	return();
}

function int is_in_lost_lands(loc where) {
	return((getX(where) >= 0x1400) && (getY(where) >= 0x0900) && (getX(where) <= 0x17FF) && (getY(where) <= 0x0FFF));
}

function int is_leaving_britannia(loc origin, loc dest) {
	return(is_in_lost_lands(origin) && (!is_in_lost_lands(dest)));
}

function int is_entering_britannia(loc origin, loc dest) {
	return((!is_in_lost_lands(origin)) && is_in_lost_lands(dest));
}

function int is_crossing_britannia_boundary(loc origin, loc dest) {
	return(is_entering_britannia(origin, dest) || is_leaving_britannia(origin, dest));
}

function int is_restricted_npc_type(obj it) {
	if (isNPC(it)) {
		switch(getObjType(it)) {
		case 0x46
		case 0x47
		case 0x48
		case 0x4B
		case 0x4C
		case 0x50
		case 0x51
		case 0x55
		case 0x56
		case 0x57
		case 0x5F
		case 0xCE
		case 0x03E2
		case 0x023D
		case 0xD2
		case 0xDA
		case 0xDB
			return(0x01);
			break;
		}
	}
	return(0x00);
}

function int can_mobile_cross_boundary(obj mobile, loc origin, loc dest) {
	if (isPlayer(mobile)) {
		if (is_entering_britannia(origin, dest)) {
			if (isGoldAccount(mobile)) {
				return(0x01);
			} else {
				return(0x00);
			}
		} else {
			if (is_leaving_britannia(origin, dest)) {
				if (isRiding(mobile)) {
				}
			}
		}
		return(0x01);
	}
	if (isNPC(mobile)) {
		if (is_restricted_npc_type(mobile)) {
			if (is_leaving_britannia(origin, dest)) {
				return(0x00);
			} else {
				return(0x01);
			}
		}
		return(0x01);
	}
	return(0x01);
}

function int check_britannia_boundary_allowed(obj mobile, loc origin, loc dest, string action) {
	if (!can_mobile_cross_boundary(mobile, origin, dest)) {
		string msg = "You must be a registered UO Gold user to ";
		concat(msg, action);
		concat(msg, ".");
		systemMessage(mobile, msg);
		return(0x00);
	}
	return(0x01);
}

function void teleport_followers(obj boss, loc destination) {
	list mobs;
	list boss_list;
	obj it;
	int should_teleport = 0x00;
	getMobsInRange(mobs, getLocation(boss), 0x19);
	for (int i = 0x00; i < numInList(mobs); i++) {
		it = mobs[i];
		should_teleport = 0x00;
		if (hasObjListVar(it, "myBoss")) {
			getObjListVar(boss_list, it, "myBoss");
			if (isInList(boss_list, boss)) {
				if (getLeader(it) == boss) {
					should_teleport = 0x01;
				}
			}
		} else {
			if (isNPC(it)) {
				if (getLeader(it) == boss) {
					should_teleport = 0x01;
				}
			}
		}
		if (should_teleport) {
			if (check_britannia_boundary_allowed(it, getLocation(it), destination, "teleport there")) {
				int r = teleport(it, destination);
			}
		}
	}
	return();
}
