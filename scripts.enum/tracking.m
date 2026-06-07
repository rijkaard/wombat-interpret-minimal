inherits sk_table;

member list tracked_targets;

forward void cleanup();

forward void append_direction(string , loc , loc );

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "tracking");
	return(0x00);
}

trigger message("useSkill") {
	clearList(tracked_targets);
	callback(this, 0x0A, 0x4D);
	int skill_result;
	skill_result = testSkill(this, SKILL_TRACKING);
	int skill_level = getSkillLevel(this, SKILL_TRACKING);
	if (skill_level == 0x00) {
		systemMessage(this, "Tracking failed.");
		return(0x00);
	}
	loc here = getLocation(this);
	loc target_loc;
	list nearby;
	int count;
	list type_menu = 0x2122, "Animals", 0x20D8, "Creatures", 0x2106, "People";
	selectType(this, this, 0x25, "What do you wish to track?", type_menu);
	cleanup();
	return(0x00);
}

trigger typeselected(0x25) {
	trackingTypeSelected(tracked_targets, this, listindex, objtype, getLocation(this));
	return(0x00);
}

trigger typeselected(0x29) {
	if (listindex == 0x00) {
		debugMessage("Selecttype aborted");
		cleanup();
		return(0x00);
	}
	if (0x00) {
		printList(tracked_targets);
		obj m_target;
		string target_str;
		for (int i = 0x00; i < numInList(tracked_targets); i++) {
			m_target = tracked_targets[i];
			target_str = objToStr(m_target);
			debugMessage("" + target_str + " " + getObjType(m_target) + " " + getName(m_target));
		}
		debugMessage("listindex = " + (listindex - 0x01));
		debugMessage("yes, I put it up after adding the clearlist");
	}
	obj trackee = tracked_targets[listindex - 0x01];
	attachscript(this, "useristracking");
	setObjVar(this, "trackee", trackee);
	callback(this, 0x01, 0x50);
	callback(this, 0x96, 0x51);
	return(0x00);
}

function void cleanup() {
	clearList(tracked_targets);
	if (hasScript(this, "useristracking")) {
		shortCallback(this, 0x01, 0x51);
	}
	return();
}

function void append_direction(string description, loc here, loc there) {
	int dir = getDirectionInternal(here, there);
	switch(dir) {
	case DIR_NORTH
		description = description + "to the North.";
		break;
	case DIR_NORTHEAST
		description = description + "to the Northeast.";
		break;
	case DIR_EAST
		description = description + "to the East.";
		break;
	case DIR_SOUTHEAST
		description = description + "to the Southeast.";
		break;
	case DIR_SOUTH
		description = description + "to the South.";
		break;
	case DIR_SOUTHWEST
		description = description + "to the Southwest.";
		break;
	case DIR_WEST
		description = description + "to the West.";
		break;
	case DIR_NORTHWEST
		description = description + "to the Northwest.";
		break;
	default
		debugMessage("getDirection: invalid direction returned.");
		description = description + " in some direction.";
		break;
	}
	return();
}
