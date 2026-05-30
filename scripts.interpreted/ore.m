inherits itemmanip;

trigger use {
	if (isAtHome(this)) {
		systemMessage(user, "That ore belongs to someone else.");
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone is using that ore.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x01);
		attachscript(this, "removeinuse");
		callback(this, 0x1E, 0x1B);
	}
	int rc;
	int metal_amt;
	rc = getResource(metal_amt, this, "metal", 0x03, 0x02);
	if (metal_amt > 0x04) {
		systemMessage(user, "Select the forge on which to smelt the ore, or another pile of ore with which to combine it.");
	} else {
		systemMessage(user, "Select another pile of ore with which to combine this.");
	}
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	removeObjVar(this, "inUse");
	if (usedon == NULL()) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(user), getLocation(usedon)) > 0x03) {
		systemMessage(user, "That is too far away.");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(this), getLocation(usedon)) > 0x03) {
		systemMessage(user, "The ore is too far away.");
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "You can't see that.");
		return(0x00);
	}
	int res;
	int metal_amt;
	res = getResource(metal_amt, this, "metal", 0x03, 0x02);
	int is_forge = 0x00;
	int is_ore = 0x00;
	obj ore = this;
	int ore_type = getObjType(this);
	int target_type = getObjType(usedon);
	if (target_type == 0x0FB1) {
		is_forge = 0x01;
	}
	if (target_type >= 0x197A) {
		if (target_type <= 0x19A9) {
			is_forge = 0x01;
		}
	}
	if (target_type > 0x19B6) {
		if (target_type < 0x19BB) {
			is_ore = 0x01;
			if (isInContainer(this)) {
				obj this_container = getTopmostContainer(this);
				int this_cont_weight = getWeight(this_container) + getWeight(usedon);
			}
			if (isInContainer(usedon)) {
				obj target_container = getTopmostContainer(usedon);
				int target_cont_weight = getWeight(target_container) + getWeight(this);
			}
			if ((this_cont_weight > 0x03E8) || (target_cont_weight > 0x03E8)) {
				ebarkTo(user, user, "The weight is too great to combine in a container.");
				return(0x00);
			}
		}
	}
	if (is_ore) {
		ore = this;
		if (ore_type == 0x19B9) {
			res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
			transferResources(usedon, ore, metal_amt, "metal");
		}
		if (ore_type == 0x19B8) {
			switch(target_type) {
			case 0x19B9
			case 0x19B8
				res = getResource(metal_amt, usedon, "metal", 0x03, 0x02);
				transferResources(ore, usedon, metal_amt, "metal");
				break;
			case 0x19B7
			case 0x19BA
				res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
				transferResources(usedon, ore, metal_amt, "metal");
				break;
			default
				return(0x00);
				break;
			}
		}
		if (ore_type == 0x19BA) {
			switch(target_type) {
			case 0x19B9
			case 0x19B8
				res = getResource(metal_amt, usedon, "metal", 0x03, 0x02);
				transferResources(ore, usedon, metal_amt, "metal");
				break;
			case 0x19B7
			case 0x19BA
				res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
				transferResources(usedon, ore, metal_amt, "metal");
				break;
			default
				return(0x00);
				break;
			}
		}
		if (ore_type == 0x19B7) {
			switch(target_type) {
			case 0x19B9
			case 0x19B8
			case 0x19BA
				res = getResource(metal_amt, usedon, "metal", 0x03, 0x02);
				transferResources(ore, usedon, metal_amt, "metal");
				break;
			case 0x19B7
				res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
				transferResources(usedon, ore, metal_amt, "metal");
				break;
			default
				return(0x00);
				break;
			}
		}
		res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
		if (metal_amt < 0x01) {
			deleteObject(ore);
		}
		res = getResource(metal_amt, usedon, "metal", 0x03, 0x02);
		if (metal_amt < 0x01) {
			deleteObject(usedon);
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	if (is_forge) {
		obj backpack = getBackpack(user);
		ore = this;
		int smelt_ore_type = getObjType(ore);
		int ingot_type = 0x1BF2;
		res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
		int count = metal_amt / 0x02;
		if (count < 0x01) {
			systemMessage(user, "There is not enough metal-bearing ore in this pile to make an ingot.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		if (testSkill(user, 0x2D)) {
			obj ingot = createNoResObjectIn(ingot_type, backpack);
			transferResources(ingot, ore, count, "metal");
			returnResourcesToBank(ore, count, "metal");
			res = putObjContainer(ingot, backpack);
			res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
			if (metal_amt < 0x01) {
				deleteObject(ore);
			}
			systemMessage(user, "You smelt the ore removing the impurities and put the metal in your backpack.");
		} else {
			if (count == 0x01) {
				systemMessage(user, "You burn away the impurities but are left with no useable metal.");
				deleteObject(ore);
				return(0x01);
			}
			returnResourcesToBank(ore, count, "metal");
			systemMessage(user, "You burn away the impurities but are left with less useable metal.");
			res = getResource(metal_amt, ore, "metal", 0x03, 0x02);
			if (metal_amt < 0x01) {
				deleteObject(ore);
			}
		}
	}
	return(0x01);
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x01);
}
