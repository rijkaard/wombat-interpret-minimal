inherits itemmanip;

trigger use {
	if (isAtHome(this)) {
		systemMessage(user, "That flour belongs to someone else.");
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone is using that flour.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x01);
		callback(this, 0x1E, 0x1B);
	}
	barkTo(this, user, "Mix the flour with water to make dough");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	int rc;
	int water_amt;
	int used_type = getObjType(usedon);
	loc location = getLocation(usedon);
	obj backpack = getBackpack(user);
	obj dough;
	if (hasObjVar(usedon, "drinkType")) {
		string drinkType;
		drinkType = getObjVar(usedon, "drinkType");
		if (drinkType == "water") {
			returnResourcesToBank(usedon, 0x01, "water");
			returnResourcesToBank(this, 0x01, "flour");
			dough = createNoResObjectIn(0x103D, backpack);
			systemMessage(user, "You make some dough and put it in your backpack");
		}
		rc = getResource(water_amt, usedon, "water", 0x03, 0x02);
		if (water_amt < 0x01) {
			if (hasObjVar(usedon, "emptyVersion")) {
				removeObjVar(usedon, "drinkType");
				int emptyVersion = getObjVar(usedon, "emptyVersion");
				setType(usedon, emptyVersion);
			} else {
				deleteObject(usedon);
			}
		}
	} else {
		switch(used_type) {
		case 0x103D
			string name;
			name = getObjVar(usedon, "NAME");
			if (name == "sweet dough") {
				setType(usedon, 0x103F);
				attachScript(usedon, "4159");
				removeObjVar(usedon, "NAME");
				setObjVar(usedon, "NAME", "cake mix");
				detachScript(usedon, "4157");
			}
			break;
		case 0x0FFA
		case 0x154D
		case 0x0E7B
			rc = getResource(water_amt, usedon, "water", 0x03, 0x02);
			if (water_amt > 0x00) {
				returnResourcesToBank(usedon, 0x01, "water");
			}
			rc = getResource(water_amt, usedon, "water", 0x03, 0x02);
			if (water_amt < 0x01) {
				if (used_type == 0x0FFA) {
					change_type(usedon, 0x14E0);
				}
				if (used_type == 0x154D) {
					change_type(usedon, 0x0E77);
				}
				if (used_type == 0x0E7B) {
					change_type(usedon, 0x0E83);
				}
			}
			returnResourcesToBank(this, 0x01, "flour");
			dough = createNoResObjectIn(0x103D, backpack);
			systemMessage(user, "You make some dough and put it in your backpack");
			break;
		case 0x15F8
			setType(usedon, 0x0A1E);
			attachScript(usedon, "2590");
			transferResources(usedon, this, 0x01, "flour");
			break;
		default
			systemMessage(user, "Can't use flour on that.");
			break;
		}
	}
	int flour_amt;
	rc = getResource(flour_amt, this, "flour", 0x03, 0x02);
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	if (flour_amt < 0x01) {
		int this_type = getObjType(this);
		if (this_type == 0x0A1E) {
			setType(this, 0x15F8);
			detachScript(this, "2590");
			return(0x01);
		} else {
			deleteObject(this);
		}
	}
	return(0x00);
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x01);
}
