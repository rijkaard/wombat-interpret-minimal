inherits globals;

member obj weaver;

trigger use {
	if (isAtHome(this)) {
		systemMessage(user, "You can't use that, it belongs to someone else.");
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		barkTo(this, user, "That is being used by someone else");
		return(0x01);
	} else {
		setObjVar(this, "inUse", 0x01);
		attachscript(this, "removeinuse");
		callback(this, 0x1E, 0x1B);
	}
	weaver = user;
	systemMessage(user, "Select a loom to use that on.");
	targetObj(user, this);
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	int target_type = getObjType(usedon);
	loc location = getLocation(user);
	obj cloth_obj;
	loc target_loc = getLocation(usedon);
	obj loom;
	loc adj_loc;
	int hue = getHue(this);
	int result;
	switch(target_type) {
	case 0x105F
		loom = usedon;
		break;
	case 0x1060
		adj_loc = target_loc;
		changeLoc(adj_loc, 0x00, 0x01, 0x00);
		loom = getFirstObjectOfType(adj_loc, 0x105F);
		break;
	case 0x1061
		adj_loc = target_loc;
		changeLoc(adj_loc, 0x01, 0x00, 0x00);
		loom = getFirstObjectOfType(adj_loc, 0x1062);
		break;
	case 0x1062
		loom = usedon;
		break;
	case 0x1063
		loom = usedon;
		break;
	case 0x1064
		adj_loc = target_loc;
		changeLoc(adj_loc, 0x00, 0x01, 0x00);
		loom = getFirstObjectOfType(adj_loc, 0x1063);
		break;
	case 0x1065
		adj_loc = target_loc;
		changeLoc(adj_loc, 0x01, 0x00, 0x00);
		loom = getFirstObjectOfType(adj_loc, 0x1066);
		break;
	case 0x1066
		loom = usedon;
		break;
	default
		systemMessage(user, "Try using that on a loom.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	transferResources(loom, this, 0x0A, "cloth");
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	int cloth_amt;
	result = getResource(cloth_amt, loom, "cloth", 0x03, 0x02);
	if (cloth_amt > 0x31) {
		int cloth_type = 0x0F95;
		obj backpack = getBackpack(user);
		cloth_obj = createNoResObjectIn(cloth_type, backpack);
		systemMessage(user, "You create some cloth and put it in your backpack.");
		transferAllResources(cloth_obj, loom);
		setHue(cloth_obj, hue);
	} else {
		string progress_msg;
		if (cloth_amt > 0x00) {
			progress_msg = "The bolt of cloth has just been started.";
		}
		if (cloth_amt > 0x0A) {
			progress_msg = "The bolt of cloth needs quite a bit more.";
		}
		if (cloth_amt > 0x14) {
			progress_msg = "The bolt of cloth needs a little more.";
		}
		if (cloth_amt > 0x1E) {
			progress_msg = "The bolt of cloth is almost finished.";
		}
		barkTo(loom, weaver, progress_msg);
	}
	int qty = getQuantity(this);
	int yarn_cloth_amt;
	result = getResource(yarn_cloth_amt, this, "cloth", 0x03, 0x02);
	if ((qty == 0x01) && (yarn_cloth_amt < 0x01)) {
		deleteObject(this);
	}
	return(0x00);
}

trigger callback(0x2F) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}
