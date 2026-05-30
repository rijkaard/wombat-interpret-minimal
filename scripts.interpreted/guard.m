inherits housestuff;

trigger creation {

member int guardFromUse = 0x01;
	if (hasObjVar(this, "guardFromUse")) {
		guardFromUse = getObjVar(this, "guardFromUse");
		if (0x00) {
			bark(this, "Getting guard from use behavior.");
		}
	}

member int guardFromProximity = 0x01;
	if (hasObjVar(this, "guardFromProximity")) {
		guardFromProximity = getObjVar(this, "guardFromProximity");
		if (0x00) {
			bark(this, "Getting guard from proximity behavior.");
		}
	}

member int guardFromAttack = 0x01;
	if (hasObjVar(this, "guardFromAttack")) {
		guardFromAttack = getObjVar(this, "guardFromAttack");
		if (0x00) {
			bark(this, "Getting guard from attack behavior.");
		}
	}

member int myGuardReaction = 0x01;
	if (hasObjVar(this, "myGuardReaction")) {
		myGuardReaction = getObjVar(this, "myGuardReaction");
		if (0x00) {
			bark(this, "Getting guard reaction.");
		}
	}

member int myPatrolDistance = 0x1E;
	if (hasObjVar(this, "myPatrolDistance")) {
		myPatrolDistance = getObjVar(this, "myPatrolDistance");
		if (0x00) {
			bark(this, "Getting patrol distance.");
		}
	}

member list guardList;

member list patrol_list;

member int patrol_idx;
	return(0x01);
}

trigger objectloaded {
	int num = dedupe_list(guardList);
	return(0x01);
}

function void add_to_guard_list(obj m_target, obj guard) {
	if (!isValid(m_target)) {
		return();
	}
	if (isInContainer(m_target)) {
		bark(m_target, "This is in a container and cannot be guarded.");
		return();
	}
	list guards;
	if (!isInList(guardList, m_target)) {
		appendToList(guardList, m_target);
	}
	attachScript(m_target, "guarded");
	if (hasObjVar(m_target, "myGuards")) {
		getObjListVar(guards, m_target, "myGuards");
	}
	if (!isInList(guards, guard)) {
		appendToList(guards, guard);
	}
	setObjVar(m_target, "myGuards", guards);
	if (0x00) {
		bark(m_target, "I am now guarded.");
	}
	return;
}

function void remove_from_guard_list(obj m_target) {
	detachScript(m_target, "guarded");
	while (isInList(guardList, m_target)) {
		if (0x00) {
			bark(m_target, "I am not guarded anymore.");
		}
		removeSpecificItem(guardList, m_target);
	}
	return;
}

trigger callback(0x52) {
	int should_react = 0x00;
	if (!hasObjVar(this, "guardedObjectOffender")) {
		return(0x00);
	}
	if (!hasObjVar(this, "guardedObjectComplaint")) {
		return(0x00);
	}
	if (!hasObjVar(this, "guardedObjectSecond")) {
		return(0x00);
	}
	if (!hasObjVar(this, "guardedObjectSender")) {
		return(0x00);
	}
	obj offender = getObjVar(this, "guardedObjectOffender");
	int complaint_type = getObjVar(this, "guardedObjectComplaint");
	obj corpse = getObjVar(this, "guardedObjectSecond");
	obj sender = getObjVar(this, "guardedObjectSender");
	removeObjVar(this, "guardedObjectOffender");
	removeObjVar(this, "guardedObjectComplaint");
	removeObjVar(this, "guardedObjectSecond");
	removeObjVar(this, "guardedObjectSender");
	if (offender == this) {
		return(0x01);
	}
	if (hasObjListVar(this, "myBoss")) {
		list boss_list;
		getObjListVar(boss_list, this, "myBoss");
		obj boss;
		for (int i = 0x00; i < numInList(boss_list); i++) {
			boss = boss_list[i];
			if (boss == offender) {
				if (0x00) {
					bark(this, "My boss breached guard, so I don't care.");
				}
				return(0x01);
			}
		}
	}
	if (0x00) {
		string complaint_str = complaint_type;
		bark(this, complaint_str);
	}
	int hostile_act = 0x00;
	switch(complaint_type) {
	case 0x00
		if (0x00) {
			bark(this, "Guarding from use.");
		}
		if (guardFromUse == 0x01) {
			should_react = 0x01;
		}
		if (corpse != NULL()) {
			if (0x00) {
				bark(this, "Violated my owner's corpse!");
			}
			hostile_act = 0x01;
		}
		setCriminal(offender, 0x01E0);
		break;
	case 0x01
		if (0x00) {
			bark(this, "Guarding from proximity!");
		}
		if (guardFromProximity == 0x01) {
			should_react = 0x01;
		}
		break;
	case 0x02
		if (0x00) {
			bark(this, "Guarding from attack or theft!");
		}
		if (guardFromAttack == 0x01) {
			should_react = 0x01;
		}
		hostile_act = 0x01;
		break;
	case 0x03
		remove_from_guard_list(sender);
		stopFollowing(this);
		add_to_guard_list(corpse, this);
		if (0x00) {
			bark(this, "My guarded mobile died, so I am guarding its corpse!");
		}
		break;
	default
		if (0x00) {
			bark(this, "Fell through to default type!");
		}
		should_react = 0x00;
		break;
	}
	int force_attack;
	if (isMobile(sender) && hostile_act) {
		should_react = 0x01;
		force_attack = 0x01;
	}
	if (hostile_act) {
		should_react = 0x01;
		force_attack = 0x01;
	}
	if (!should_react) {
		return(0x00);
	}
	if (!canSeeObj(this, sender)) {
		if (0x00) {
			bark(this, "Cannot see the guarded object.");
		}
		return(0x00);
	}
	if (!isInList(guardList, sender)) {
		if (0x00) {
			bark(this, "Not an object in my guardList.");
		}
		return(0x00);
	}
	int reaction = myGuardReaction;
	if (force_attack) {
		if (0x00) {
			bark(this, "Attack override!");
		}
		reaction = 0x03;
	}
	switch(reaction) {
	case 0x01
		if (hasObjVar(this, "isPet")) {
			string msg;
			msg = getName(this) + " looks somewhat annoyed.");
			bark(this, msg);
		} else {
			bark(this, "Please leave that alone.");
		}
		break;
	case 0x02
		loc offender_loc = getLocation(offender);
		loc interpose_loc = interpose(offender_loc, getLocation(sender));
		if (0x00) {
			bark(this, "Interposing myself!");
		}
		walkTo(this, interpose_loc, 0x02);
		break;
	case 0x03
		if (0x00) {
			bark(this, "Attacking the interloper!");
		}
		attack(this, offender);
		break;
	default
		if (0x00) {
			bark(this, "Couldn't interpret a guard reaction.");
		}
		return(0x00);
	}
	return(0x00);
}

trigger pathfound(0x02) {
	if (0x00) {
		bark(this, "I am interposed!");
	}
	return(0x00);
}

trigger pathnotfound(0x02) {
	if (0x00) {
		bark(this, "Can't get a path to interpose.");
	}
	return(0x00);
}

function void guard_location(loc target_loc, obj this) {
	walkTo(this, target_loc, 0x03);
	obj placeholder = createNoResObjectAt(0x01, target_loc);
	add_to_guard_list(placeholder, this);
	return;
}

trigger pathfound(0x03) {
	if (0x00) {
		bark(this, "Moved to place to guard.");
	}
	return(0x00);
}

trigger pathnotfound(0x03) {
	if (0x00) {
		bark(this, "I can't get to that place to guard it effectively.");
	}
	return(0x00);
}

function void remove_guard_at_location(loc target_loc) {
	int found = 0x00;
	for (int i = 0x00; i < numInList(guardList); i = i + 0x01) {
		obj guarded_obj;
		guarded_obj = guardList[i];
		loc obj_loc = getLocation(guarded_obj);
		if (obj_loc == target_loc) {
			found = 0x01;
			break;
		}
	}
	if (!found) {
		return;
	}
	remove_from_guard_list(guarded_obj);
	deleteObject(guarded_obj);
	return;
}

function void purge_invalid_guards() {
	for (int i = 0x00; i < numInList(guardList); i = i + 0x01) {
		if (!isValid(guardList[i])) {
			remove_from_guard_list(guardList[i]);
		}
	}
	return;
}

function void update_patrol_list(obj this) {
	debugMessage("starting update of patrol path");
	list new_patrol_list;
	int in_range = 0x01;
	for (int i = 0x00; i < numInList(guardList); i = i + 0x01) {
		obj guarded_obj;
		loc obj_loc = getLocation(guarded_obj);
		guarded_obj = guardList[i];
		in_range = 0x01;
		int dist = getDistanceInTiles(getLocation(this), obj_loc);
		if (dist > myPatrolDistance) {
			if (!isMobile(guarded_obj)) {
				remove_from_guard_list(guarded_obj);
			}
			in_range = 0x00;
		}
		if (in_range) {
			appendToList(new_patrol_list, guarded_obj);
		}
	}
	copyList(patrol_list, new_patrol_list);
	return;
}

function void do_patrol_step(obj this) {
	int myPatrolDelay = 0x1E;
	if (hasObjVar(this, "myPatrolDelay")) {
		myPatrolDelay = getObjVar(this, "myPatrolDelay");
	}
	update_patrol_list(this);
	if (patrol_idx == numInList(patrol_list)) {
		patrol_idx = 0x00;
	}
	if (numInList(patrol_list) < 0x01) {
		debugMessage("I have nothing in my list of items to patrol.");
		return();
	}
	loc where = getLocation(patrol_list[patrol_idx]));
	if (0x00) {
		bark(this, "Walking to next patrol point.");
	}
	walkTo(this, where, 0x04);
	patrol_idx++;
	int continue_patrol = 0x01;
	if (hasObjVar(this, "continuePatrol")) {
		continue_patrol = getObjVar(this, "continuePatrol");
	}
	if (continue_patrol == 0x01) {
		callBack(this, myPatrolDelay, 0x17);
	}
	return;
}

trigger callback(0x17) {
	do_patrol_step(this);
	return(0x01);
}

function int is_patrol_active(obj m_target) {
	int continue_patrol = getObjVar(m_target, "continuePatrol");
	if (continue_patrol == 0x01) {
		return(0x01);
	}
	return(0x00);
}

trigger pathnotfound(0x04) {
	if (0x00) {
		bark(this, "COuld not reach next patrol point.");
	}
	return(0x00);
}

trigger pathfound(0x04) {
	if (0x00) {
		bark(this, "At next patrol point.");
	}
	return(0x00);
}

trigger foundfood {
	for (int i = 0x00; i < numInList(guardList); i = i + 0x01) {
		obj guard = guardList[i];
		if (target == guard) {
			if (0x00) {
				bark(target, "I'm guarded but my guard tried to eat me!");
			}
			return(0x00);
		}
	}
	return(0x01);
}

trigger callback(0x1A) {
	if (numInList(guardList) < 0x01) {
		return(0x00);
	}
	bark(this, "I am guarding the following:");
	string name;
	for (int i = 0x00; i < numInList(guardList); i++) {
		name = getName(guardList[i]);
		if (name != "unused") {
			bark(this, name);
		}
	}
	return(0x00);
}

function void clear_all_guard_protections(obj this) {
	obj guarded_obj;
	for (int i = 0x00; i < numInList(guardList); i++) {
		guarded_obj = guardList[i];
		remove_from_guard_list(guarded_obj);
	}
	return();
}
