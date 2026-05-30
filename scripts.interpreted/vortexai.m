inherits nrgyvrtxbase;

member list target_list;

member list target_scores;

member list nearby_mobs;

member list nearby_scores;

member obj self_obj;

member int prev_target_count;

member obj trackee;

forward void select_and_pursue_target();

forward void pursue_and_strike(obj victim);

forward void strike_target(obj victim, int damage);

forward void Q5GP();

forward void filter_target_list(int use_secondary);

forward void remove_mounts_from_targets();

trigger creation {
	if (random(0x00, 0x01F4) == 0x2A) {
		setType(this, 0xDC);
	}
	self_obj = this;
	loc self_loc = getLocation(self_obj);
	setMaxFatigue(self_obj, 0x03E7);
	setCurFatigue(self_obj, 0x03E7);
	enableBehaviors(self_obj);
	getMobsInRange(target_list, self_loc, 0x06);
	for (int i; i < numInList(target_list); i++) {
		setItem(target_scores, 0x01, i);
	}
	remove_mounts_from_targets();
	int use_secondary = 0x00;
	filter_target_list(use_secondary);
	if (0x00 < numInList(target_list)) {
		callback(self_obj, 0x05, 0x2F);
		select_and_pursue_target();
	} else {
		callback(self_obj, 0x05, 0x2F);
		shortcallback(self_obj, 0x01, 0x35);
	}
	return(0x00);
}

function void filter_target_list(int which_list) {
	if (which_list == 0x00) {
		if (0x00 < numInList(target_list)) {
			for (int i = 0x00; i < numInList(target_list); i++) {
				int obj_type = getObjType(target_list[i]);
				if (obj_type == 0x0335) {
					removeItem(target_list, i);
					removeItem(target_scores, i);
				}
			}
		}
	} else {
		if (0x00 < numInList(nearby_mobs)) {
			for (i = 0x00; i < numInList(nearby_mobs); i++) {
				obj_type = getObjType(nearby_mobs[i]);
				if (obj_type == 0x0335) {
					removeItem(nearby_mobs, i);
					removeItem(nearby_scores, i);
				}
			}
		}
	}
	return();
}

function void select_and_pursue_target() {
	loc self_loc = getLocation(self_obj);
	int dist;
	loc there;
	remove_mounts_from_targets();
	if (0x00 == numInList(target_list)) {
		shortcallback(self_obj, 0x01, 0x35);
	}
	for (int i = 0x00; i < numInList(target_list); i++) {
		if (isValid(target_list[i])) {
			there = getLocation(target_list[i]);
			dist = getDistanceInTiles(self_loc, there);
			if (dist == 0x00) {
				dist = 0x01;
			}
			int intelligence = getIntelligence(target_list[i]);
			int skill = getSkillLevel(target_list[i], 0x19);
			int priority = (intelligence + skill) / dist;
			setItem(target_scores, priority, i);
		} else {
			removeItem(target_scores, i);
			removeItem(target_list, i);
		}
	}
	obj tmp_obj_a;
	int tmp_score_a;
	int unused_score;
	int unused_obj;
	obj tmp_obj_b;
	int tmp_score_b;
	int unused;
	int count = numInList(target_scores);
	string count_str = count;
	for (int outer; outer < numInList(target_scores); outer++) {
		for (int inner = 0x00; inner < count; inner++) {
			if (outer < inner) {
				if ((target_scores[outer]) < (target_scores[inner])) {
					if (isValid(target_list[outer])) {
						tmp_score_a = target_scores[outer];
						tmp_obj_a = target_list[outer];
						tmp_score_b = target_scores[inner];
						tmp_obj_b = target_list[inner];
						setItem(target_scores, tmp_score_b, outer);
						setItem(target_list, tmp_obj_b, outer);
						setItem(target_scores, tmp_score_a, inner);
						setItem(target_list, tmp_obj_a, inner);
					}
				}
				if ((target_scores[outer]) == (target_scores[inner])) {
					if (isValid(target_list[outer])) {
						loc loc_a = getLocation(target_list[outer]);
						loc loc_b = getLocation(target_list[inner]);
						int dist_a = getDistance(self_loc, loc_a);
						int dist_b = getDistance(self_loc, loc_b);
						if (dist_a > dist_b) {
							tmp_score_a = target_scores[outer];
							tmp_obj_a = target_list[outer];
							tmp_score_b = target_scores[inner];
							tmp_obj_b = target_list[inner];
							setItem(target_scores, tmp_score_b, outer);
							setItem(target_list, tmp_obj_b, outer);
							setItem(target_scores, tmp_score_a, inner);
							setItem(target_list, tmp_obj_a, inner);
						}
					}
				}
			}
		}
	}
	prev_target_count = numInList(target_list);
	obj best_target = target_list[0x00];
	pursue_and_strike(best_target);
	return();
}

function void pursue_and_strike(obj victim) {
	loc self_loc = getLocation(self_obj);
	loc there = getLocation(victim);
	trackee = victim;
	int dist = getDistanceInTiles(self_loc, there);
	if (dist < 0x01) {
		dist = 0x01;
		strike_target(victim, 0x1E);
	} else {
		walkTo(self_obj, there, 0x0E);
		shortcallback(self_obj, dist, 0x34);
	}
	return();
}

function void strike_target(obj victim, int damage) {
	loc self_loc = getLocation(self_obj);
	sfx(self_loc, 0x28, 0x00);
	if (!is_targetable_mobile(victim)) {
		return();
	}
	doDamageType(self_obj, victim, damage, 0x02);
	int stat_delta = 0x00 - 0x0A;
	int duration = 0xB4;
	for (int s = 0x00; s < 0x03; s++) {
		int effect_applied = apply_stat_effect_if_absent(victim, s, stat_delta, duration);
	}
	return();
}

function void remove_mounts_from_targets() {
	for (int i = 0x00; i < numInList(target_list); i++) {
		int obj_type = getObjType(target_list[i]);
		if ((obj_type == 0x0192) || (obj_type == 0x0193)) {
			removeItem(target_list, i);
			removeItem(target_scores, i);
		}
	}
	return();
}

trigger callback(0x34) {
	loc self_loc = getLocation(self_obj);
	loc there = getLocation(trackee);
	int dist = getDistanceInTiles(self_loc, there);
	if (dist <= 0x01) {
		strike_target(trackee, 0x0C);
		select_and_pursue_target();
	} else {
		getMobsInRange(nearby_mobs, self_loc, 0x06);
		for (int i; i < numInList(nearby_mobs); i++) {
			setItem(nearby_scores, 0x01, i);
		}
		int use_secondary = 0x01;
		filter_target_list(use_secondary);
		if (0x00 < numInList(nearby_mobs)) {
			for (int j; j < numInList(nearby_mobs); j++) {
				int mob_type = getObjType(nearby_mobs[j]);
				if ((mob_type == 0x0192) || (mob_type == 0x0193)) {
					removeItem(nearby_mobs, j);
					removeItem(nearby_scores, j);
					return(0x00);
				}
				obj mob = nearby_mobs[j];
				if (isInList(target_list, mob)) {
					removeItem(nearby_mobs, j);
					removeItem(nearby_scores, j);
				} else {
					appendToList(target_list, mob);
					appendToList(target_scores, 0x01);
				}
			}
		}
		if (prev_target_count == numInList(target_list)) {
			walkTo(self_obj, there, 0x0E);
			shortcallback(self_obj, dist, 0x34);
			return(0x00);
		}
		if (numInList(target_list) < 0x01) {
			shortcallback(self_obj, dist, 0x35);
			return(0x00);
		}
		select_and_pursue_target();
	}
	return(0x00);
}

trigger callback(0x35) {
	loc self_loc = getLocation(self_obj);
	getMobsInRange(nearby_mobs, self_loc, 0x06);
	for (int i; i < numInList(nearby_mobs); i++) {
		setItem(nearby_scores, 0x01, i);
	}
	int use_secondary = 0x01;
	filter_target_list(use_secondary);
	if (0x00 < numInList(nearby_mobs)) {
		for (int j; j < numInList(nearby_mobs); j++) {
			int mob_type = getObjType(nearby_mobs[j]);
			if ((mob_type == 0x0192) || (mob_type == 0x0193)) {
				removeItem(nearby_mobs, j);
				removeItem(nearby_scores, j);
				return(0x00);
			}
			obj mob = nearby_mobs[j];
			if (isInList(target_list, mob)) {
				removeItem(nearby_mobs, j);
				removeItem(nearby_scores, j);
			} else {
				appendToList(target_list, mob);
				appendToList(target_scores, 0x01);
			}
		}
		select_and_pursue_target();
	} else {
		callback(self_obj, 0x02, 0x35);
	}
	return(0x00);
}

trigger enterrange(0x04) {
	if (!(isInList(target_list, target))) {
		appendToList(target_list, target);
		appendToList(target_scores, 0x00);
	}
	select_and_pursue_target();
	return(0x01);
}

trigger enterrange(0x00) {
	strike_target(target, 0x1E);
	select_and_pursue_target();
	return(0x01);
}

trigger callback(0x2F) {
	loc self_loc = getLocation(self_obj);
	sfx(self_loc, 0x15, 0x00);
	shortcallback(self_obj, 0x03, 0x2F);
	return(0x00);
}
