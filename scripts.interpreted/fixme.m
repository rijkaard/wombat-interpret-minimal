inherits sk_table;

function int is_movable(obj item) {
	int obj_type = getObjType(item);
	if ((obj_type == 0x1E5E) || (obj_type == 0x1E5F)) {
		return(0x00);
	}
	if (isMobile(item)) {
		return(0x00);
	}
	return(0x01);
}

trigger creation {
	int i;
	list contents;
	getContents(contents, this);
	if (numInList(contents) > 0x00) {
		obj backpack = getBackpack(this);
		if (backpack != NULL()) {
			for (i = 0x00; i < numInList(contents); i++) {
				if (is_movable(contents[i])) {
					bark(this, "Found: " + getName(contents[i]) + "(" + getObjType(contents[i]) + ")");
					int put_result = putObjContainer(contents[i], backpack);
				}
			}
		} else {
			loc here = getLocation(this);
			for (i = 0x00; i < numInList(contents); i++) {
				if (is_movable(contents[i])) {
					bark(this, "Found: " + getName(contents[i]) + "(" + getObjType(contents[i]) + ")");
					int bar = teleport(contents[i], here);
				}
			}
		}
	}
	recalcWeight(this);
	int skill_total = 0x00;
	for (i = 0x00; i < 0x2E; i++) {
		skill_total = skill_total + getSkillLevelNoStat(this, i);
	}
	if (skill_total > 0x1B58) {
		int skill_scale = 0x1B58 * 0x64 / skill_total;
		bark(this, "Skill total was:" + skill_total + ", keeping " + skill_scale + "");
		for (i = 0x00; i < 0x2E; i++) {
			setSkillLevel(this, i, getSkillLevelNoStat(this, i) * skill_scale / 0x64);
		}
	}
	detachScript(this, "fixme");
	return(0x00);
}
