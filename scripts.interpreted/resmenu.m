inherits spelskil;

function int can_resurrect(int listindex, obj usedon) {
	if (listindex == 0x00) {
		return(0x00);
	}
	if (!isDead(usedon)) {
		return(0x00);
	}
	if ((!hasObjVar(usedon, "resurrectLocation")) || (!hasObjVar(usedon, "resurrectCaster"))) {
		return(0x00);
	}
	loc here = getLocation(usedon);
	loc there = getObjVar(usedon, "resurrectLocation");
	obj caster = getObjVar(usedon, "resurrectCaster");
	if (here != there) {
		systemMessage(usedon, "Thou hast wandered too far from the site of thy resurrection!");
		return(0x00);
	}
	loc target = getLocation(usedon);
	int height = getHeight(usedon);
	if (0x07 != canExistAt(target, height, 0x01)) {
		systemMessage(usedon, "Thou can not be resurrected there!");
		return(0x00);
	}
	return(0x01);
}

function void clear_resurrect_vars(obj usedon) {
	removeObjVar(usedon, "resurrectLocation");
	removeObjVar(usedon, "resurrectCaster");
	removeObjVar(usedon, "resurrectType");
	removeObjVar(usedon, "resurrectDesc");
	return();
}

function void cancel_resurrection_menu(obj usedon) {
	setMobFlag(usedon, 0x02, 0x00);
	clear_resurrect_vars(usedon);
	detachScript(usedon, "resmenu");
	return();
}

function void show_resurrect_menu(obj usedon) {
	string desc = getObjVar(usedon, "resurrectDesc");
	list options;
	appendToList(options, 0x00);
	appendToList(options, "YES - You choose to try to come back to life now.");
	appendToList(options, 0x01);
	appendToList(options, "NO - You prefer to remain a ghost for now.");
	selectType(usedon, this, 0x2D, desc, options);
	return();
}

trigger creation {
	callback(this, 0xB4, 0x7E);
	setMobFlag(this, 0x02, 0x01);
	show_resurrect_menu(this);
	return(0x01);
}

trigger logout {
	cancel_resurrection_menu(this);
	return(0x01);
}

trigger objectloaded {
	cancel_resurrection_menu(this);
	return(0x01);
}

trigger online {
	cancel_resurrection_menu(this);
	return(0x01);
}

trigger callback(0x7E) {
	cancel_resurrection_menu(this);
	return(0x01);
}

trigger typeselected(0x2D) {
	if (!can_resurrect(listindex, user)) {
		cancel_resurrection_menu(this);
		return(0x01);
	}
	int resurrect_type = getObjVar(this, "resurrectType");
	switch(objtype) {
	case 0x00
		sfx(getLocation(user), 0x0214, 0x00);
		int result = resurrect(user, 0x00);
		if (resurrect_type > 0x00) {
			setCurHP(user, 0x0A);
			if (resurrect_type > 0x01) {
				if (isInArea("heal", getLocation(this), 0x00)) {
					setCurHP(user, getMaxHP(user));
					setCurFatigue(user, getMaxFatigue(user));
				}
			}
		}
		callback(this, 0x00, 0x48);
		break;
	case 0x01
		default
		break;
	}
	cancel_resurrection_menu(this);
	return(0x01);
}
