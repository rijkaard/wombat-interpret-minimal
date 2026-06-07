inherits bldsprtsbase;

member list target_list;

member list target_score_list;

member list nearby_mob_list;

member list nearby_score_list;

member int prev_target_count;

member obj trackee;

forward void select_and_pursue();

forward void pursue_victim(obj victim);

forward void apply_spirit_attack(obj victim, int damage);

forward void Q5GP();

forward void prune_corpses(int mode);

forward void remove_players();

trigger creation {
	loc my_loc = getLocation(this);
	sfx(my_loc, 0x0212, 0x00);
	setMaxFatigue(this, 0x03E7);
	setCurFatigue(this, 0x03E7);
	enableBehaviors(this);
	getMobsInRange(target_list, my_loc, 0x06);
	for (int i; i < numInList(target_list); i++) {
		setItem(target_score_list, 0x01, i);
	}
	remove_players();
	int mode = 0x00;
	prune_corpses(mode);
	if (0x00 < numInList(target_list)) {
		shortcallback(this, 0x03, 0x2F);
		select_and_pursue();
	} else {
		shortcallback(this, 0x03, 0x2F);
		shortcallback(this, 0x01, 0x35);
	}
	return(0x00);
}

function void prune_corpses(int list_flag) {
	if (list_flag == 0x00) {
		if (0x00 < numInList(target_list)) {
			for (int i = 0x00; i < numInList(target_list); i++) {
				int obj_type = getObjType(target_list[i]);
				if (isValid(target_list[i])) {
					if (obj_type == 0x0336) {
						removeItem(target_list, i);
						removeItem(target_score_list, i);
					}
				}
			}
		}
	} else {
		if (0x00 < numInList(nearby_mob_list)) {
			for (i = 0x00; i < numInList(nearby_mob_list); i++) {
				if (!isValid(target_list[i])) {
					obj_type = getObjType(nearby_mob_list[i]);
					if (obj_type == 0x0336) {
						removeItem(nearby_mob_list, i);
						removeItem(nearby_score_list, i);
					}
				}
			}
		}
	}
	return();
}

function void select_and_pursue() {
	loc my_loc = getLocation(this);
	int dist;
	loc there;
	remove_players();
	if (0x00 == numInList(target_list)) {
		shortcallback(this, 0x01, 0x35);
	}
	for (int i = 0x00; i < numInList(target_list); i++) {
		if (isValid(target_list[i])) {
			there = getLocation(target_list[i]);
			dist = getDistanceInTiles(my_loc, there);
			if (dist == 0x00) {
				dist = 0x01;
			}
			int strength = getStrength(target_list[i]);
			int skill = (getSkillLevel(target_list[i], SKILL_TACTICS) + getSkillLevel(target_list[i], SKILL_ARCHERY));
			int score = (strength + skill) / dist;
			setItem(target_score_list, score, i);
		} else {
			removeItem(target_score_list, i);
			removeItem(target_list, i);
		}
	}
	obj swap_mob;
	int swap_score;
	int tmp_int_a;
	int tmp_int_b;
	obj swap_mob_b;
	int swap_score_b;
	int tmp_int_c;
	int count = numInList(target_score_list);
	string count_str = count;
	for (int outer; outer < numInList(target_score_list); outer++) {
		for (int inner = 0x00; inner < count; inner++) {
			if (outer < inner) {
				if ((target_score_list[outer]) < (target_score_list[inner])) {
					if (isValid(target_list[outer])) {
						swap_score = target_score_list[outer];
						swap_mob = target_list[outer];
						swap_score_b = target_score_list[inner];
						swap_mob_b = target_list[inner];
						setItem(target_score_list, swap_score_b, outer);
						setItem(target_list, swap_mob_b, outer);
						setItem(target_score_list, swap_score, inner);
						setItem(target_list, swap_mob, inner);
					}
				}
				if ((target_score_list[outer]) == (target_score_list[inner])) {
					if (isValid(target_list[outer])) {
						loc loc_a = getLocation(target_list[outer]);
						loc loc_b = getLocation(target_list[inner]);
						int dist_a = getDistance(my_loc, loc_a);
						int dist_b = getDistance(my_loc, loc_b);
						if (dist_a > dist_b) {
							swap_score = target_score_list[outer];
							swap_mob = target_list[outer];
							swap_score_b = target_score_list[inner];
							swap_mob_b = target_list[inner];
							setItem(target_score_list, swap_score_b, outer);
							setItem(target_list, swap_mob_b, outer);
							setItem(target_score_list, swap_score, inner);
							setItem(target_list, swap_mob, inner);
						}
					}
				}
			}
		}
	}
	prev_target_count = numInList(target_list);
	obj best_target = target_list[0x00];
	pursue_victim(best_target);
	return();
}

function void pursue_victim(obj victim) {
	loc my_loc = getLocation(this);
	loc there = getLocation(victim);
	trackee = victim;
	int dist = getDistanceInTiles(my_loc, there);
	if (dist < 0x01) {
		dist = 0x01;
		if (!isValid(victim)) {
			return();
		}
		apply_spirit_attack(victim, 0x14);
	} else {
		walkTo(this, there, 0x0F);
		shortcallback(this, dist, 0x34);
	}
	return();
}

function void apply_spirit_attack(obj victim, int damage) {
	if (!isValid(victim)) {
		return();
	}
	apply_typed_damage_clamped(this, victim, damage, 0x01, 0x00);
	sfx(getLocation(this), 0x023B, 0x00);
	if (is_targetable_mobile(victim)) {
		attachScript(victim, "poisoned");
		setObjVar(victim, "poison_strength", 0x02);
	}
	return();
}

function void remove_players() {
	for (int i = 0x00; i < numInList(target_list); i++) {
		if (isValid(target_list[i])) {
			int obj_type = getObjType(target_list[i]);
			if ((obj_type == 0x0192) || (obj_type == 0x0193)) {
				removeItem(target_list, i);
				removeItem(target_score_list, i);
			}
		}
	}
	return();
}

trigger callback(0x34) {
	loc my_loc = getLocation(this);
	loc there = getLocation(trackee);
	int dist = getDistanceInTiles(my_loc, there);
	if (dist <= 0x01) {
		if (!isValid(trackee)) {
			return(0x00);
		}
		apply_spirit_attack(trackee, 0x07);
		select_and_pursue();
	} else {
		getMobsInRange(nearby_mob_list, my_loc, 0x06);
		for (int i; i < numInList(nearby_mob_list); i++) {
			setItem(nearby_score_list, 0x01, i);
		}
		int mode = 0x01;
		prune_corpses(mode);
		if (0x00 < numInList(nearby_mob_list)) {
			for (int j; j < numInList(nearby_mob_list); j++) {
				int obj_type = getObjType(nearby_mob_list[j]);
				if ((obj_type == 0x0192) || (obj_type == 0x0193)) {
					removeItem(nearby_mob_list, j);
					removeItem(nearby_score_list, j);
					return(0x00);
				}
				obj mob = nearby_mob_list[j];
				if (isInList(target_list, mob)) {
					removeItem(nearby_mob_list, j);
					removeItem(nearby_score_list, j);
				} else {
					appendToList(target_list, mob);
					appendToList(target_score_list, 0x01);
				}
			}
		}
		if (prev_target_count == numInList(target_list)) {
			walkTo(this, there, 0x0F);
			sfx(my_loc, 0x023A, 0x00);
			shortcallback(this, dist, 0x34);
			return(0x00);
		}
		if (numInList(target_list) < 0x01) {
			sfx(my_loc, 0x023A, 0x00);
			shortcallback(this, dist, 0x35);
			return(0x00);
		}
		select_and_pursue();
	}
	sfx(my_loc, 0x023A, 0x00);
	return(0x00);
}

trigger callback(0x35) {
	loc my_loc = getLocation(this);
	getMobsInRange(nearby_mob_list, my_loc, 0x06);
	for (int i; i < numInList(nearby_mob_list); i++) {
		setItem(nearby_score_list, 0x01, i);
	}
	int mode = 0x01;
	prune_corpses(mode);
	if (0x00 < numInList(nearby_mob_list)) {
		for (int j; j < numInList(nearby_mob_list); j++) {
			int obj_type = getObjType(nearby_mob_list[j]);
			if ((obj_type == 0x0192) || (obj_type == 0x0193)) {
				removeItem(nearby_mob_list, j);
				removeItem(nearby_score_list, j);
				return(0x00);
			}
			obj mob = nearby_mob_list[j];
			if (isInList(target_list, mob)) {
				removeItem(nearby_mob_list, j);
				removeItem(nearby_score_list, j);
			} else {
				appendToList(target_list, mob);
				appendToList(target_score_list, 0x01);
			}
		}
		select_and_pursue();
	} else {
		shortcallback(this, 0x02, 0x35);
	}
	sfx(my_loc, 0x023A, 0x00);
	return(0x00);
}

trigger enterrange(0x04) {
	if (!(isInList(target_list, target))) {
		appendToList(target_list, target);
		appendToList(target_score_list, 0x00);
	}
	select_and_pursue();
	return(0x01);
}

trigger enterrange(0x00) {
	if (!isValid(target)) {
		return(0x01);
	}
	apply_spirit_attack(target, 0x14)select_and_pursue();
	return(0x01);
}

trigger callback(0x2F) {
	loc my_loc = getLocation(this);
	sfx(my_loc, 0x023A, 0x00);
	shortcallback(this, 0x03, 0x2F);
	return(0x00);
}
