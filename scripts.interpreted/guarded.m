inherits globals;

forward void detach_if_unguarded();

trigger objectloaded {
	if (!hasObjVar(this, "myGuards")) {
		return(0x01);
	}
	list myGuards;
	getObjListVar(myGuards, this, "myGuards");
	int num = dedupe_list(myGuards);
	setObjVar(this, "myGuards", myGuards);
	return(0x01);
}

function void debug_corpse_check(obj mob, obj corpse) {
	if (corpse == NULL()) {
		bark(mob, "CORPSE BAD (flobbitz)");
	} else {
		bark(mob, "CORPSE OK (flobbitz)");
	}
	return();
}

function void notify_guards(int complaint, obj user, obj secondary) {
	int i;
	obj guard;
	list myGuards;
	list valid_guards;
	if (!hasObjVar(this, "myGuards")) {
		return();
	}
	getObjListVar(myGuards, this, "myGuards");
	for (i = 0x00; i < numInList(myGuards); i++) {
		guard = myGuards[i];
		if (isValid(guard)) {
			appendToList(valid_guards, guard);
		}
	}
	setObjVar(this, "myGuards", valid_guards);
	if (inJusticeRegion(getLocation(this))) {
		return();
	}
	for (i = 0x00; i < numInList(valid_guards); i++) {
		guard = valid_guards[i];
		setObjVar(guard, "guardedObjectOffender", user);
		setObjVar(guard, "guardedObjectComplaint", complaint);
		setObjVar(guard, "guardedObjectSecond", secondary);
		setObjVar(guard, "guardedObjectSender", this);
		shortCallback(guard, 0x01, 0x52);
	}
	return();
}

trigger ooruse {
	detach_if_unguarded();
	if (isMobile(this)) {
		return(0x01);
	}
	notify_guards(0x00, user, NULL());
	return(0x01);
}

function int has_guard_nearby() {
	list nearby_mobs;
	obj x;
	obj y;
	if (!hasObjVar(this, "myGuards")) {
		return(0x00);
	}
	getMobsInRange(nearby_mobs, getLocation(this), 0x0A);
	for (int i = 0x00; i < numInList(nearby_mobs); i++) {
		obj mob = nearby_mobs[i];
		if (isInObjVarListSet(this, "myGuards", mob)) {
			return(0x01);
		}
	}
	return(0x00);
}

trigger enterrange(0x05) {
	detach_if_unguarded();
	if (!inJusticeRegion(getLocation(this))) {
		if (isMobile(this)) {
			if (has_guard_nearby()) {
				if (!isHidden(this)) {
					ebarkTo(this, target, "[guarded]");
				}
			}
		} else {
			if (getObjType(this) != 0x01) {
				if (has_guard_nearby()) {
					if (!isHidden(this)) {
						ebarkTo(this, target, getName(this) + " looks like it is being guarded.");
					}
				}
			}
		}
	}
	notify_guards(0x01, target, NULL());
	return(0x01);
}

trigger gotattacked {
	detach_if_unguarded();
	notify_guards(0x02, attacker, NULL());
	return(0x01);
}

trigger washit {
	detach_if_unguarded();
	notify_guards(0x02, attacker, NULL());
	return(0x01);
}

trigger wasgotten {
	detach_if_unguarded();
	notify_guards(0x02, getter, NULL());
	return(0x01);
}

trigger death {
	detach_if_unguarded();
	notify_guards(0x03, attacker, corpse);
	return(0x01);
}

trigger lookedat {
	detach_if_unguarded();
	if (!inJusticeRegion(getLocation(this))) {
		if (!isHidden(this)) {
			ebarkTo(this, looker, "[guarded]");
		}
	}
	return(0x01);
}

function void detach_if_unguarded() {
	setDefaultReturn(0x01);
	if (has_guard_nearby()) {
		return();
	}
	removeObjVar(this, "myGuards");
	detachScript(this, "guarded");
	return();
}
