inherits globals;

trigger objectloaded {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger callback(0x20) {
	string create_type = getObjVar(this, "CREATE_THIS");
	int hue = getObjVar(this, "HUE");
	obj user = getObjVar(this, "USER");
	int orig_type = getObjVar(this, "ORIGINAL_TYPE");
	obj source = getObjVar(this, "SOURCE");
	int spin_amount = getObjVar(this, "SPINVALUE");
	int put_result;
	int n;
	obj created_obj;
	string desc;
	string pronoun;
	obj backpack = getBackpack(user);
	int item_type;
	int qty;
	setType(this, orig_type);
	if (create_type == "yarn") {
		item_type = 0x0E1D;
	}
	if (create_type == "thread") {
		item_type = 0x0FA0;
	}
	created_obj = createNoResObjectAt(item_type, getLocation(user));
	if (!isValid(created_obj)) {
		return(0x01);
	}
	transferResources(created_obj, this, spin_amount, "cloth");
	qty = getQuantity(created_obj);
	switch(qty) {
	case 0x01
		if (create_type == "yarn") {
			desc = " a ball of yarn";
		} else {
			desc = " a spool of thread";
		}
		pronoun = "it";
		break;
	default
		if (create_type == "yarn") {
			desc = " " + qty + "  balls of yarn";
		} else {
			desc = " " + qty + "  spools of thread";
		}
		pronoun = "them";
		break;
	}
	if (canHold(backpack, created_obj)) {
		put_result = putObjContainer(created_obj, backpack);
		systemMessage(user, "You create" + desc + " and put " + pronoun + " in your backpack.");
	} else {
		systemMessage(user, "You create the" + desc + " and put it at your feet.");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	setHue(created_obj, hue);
	removeObjVar(this, "SOURCE");
	removeObjVar(this, "CREATE_THIS");
	removeObjVar(this, "HUE");
	removeObjVar(this, "USERLOC");
	removeObjVar(this, "ORIGINAL_TYPE");
	removeObjVar(this, "SPINVALUE");
	string script_name = item_type;
	attachScript(created_obj, script_name);
	return(0x01);
}
