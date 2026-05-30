inherits globals;

member obj activating_user;

trigger creation {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x1922
	case 0x192E
		returnResourcesToBank(this, 0x14, "flour");
		break;
	}
	return(0x00);
}

trigger use {
	activating_user = user;
	int obj_type = getObjType(this);
	int res;
	loc this_loc = getLocation(this);
	loc adj_loc = this_loc;
	obj millstone;
	int stone_type;
	int flour_qty;
	switch(obj_type) {
	case 0x1EBD
		targetObj(user, this);
		return(0x00);
		break;
	case 0x1921
		changeLoc(adj_loc, 0x01, 0x00, 0x00);
		millstone = getFirstObjectOfType(adj_loc, 0x1923);
		break;
	case 0x1923
		millstone = this;
		break;
	case 0x1924
		changeLoc(adj_loc, 0x00 - 0x01, 0x00, 0x00);
		millstone = getFirstObjectOfType(adj_loc, 0x1923);
		break;
	case 0x192D
		changeLoc(adj_loc, 0x00, 0x01, 0x00);
		millstone = getFirstObjectOfType(adj_loc, 0x192F);
		break;
	case 0x192F
		millstone = this;
		break;
	case 0x1930
		changeLoc(adj_loc, 0x00, 0x00 - 0x01, 0x00);
		millstone = getFirstObjectOfType(adj_loc, 0x192F);
		break;
	default
		break;
	}
	res = getResource(flour_qty, millstone, "flour", 0x03, 0x02);
	if (flour_qty > 0x13) {
		stone_type = getObjType(millstone);
		loc work_loc = adj_loc;
		obj comp;
		if (stone_type == 0x1923) {
			setType(millstone, 0x1926);
			changeLoc(work_loc, 0x00 - 0x01, 0x00, 0x00);
			comp = getFirstObjectOfType(work_loc, 0x1921);
			setType(comp, 0x1925);
			changeLoc(work_loc, 0x02, 0x00, 0x00);
			comp = getFirstObjectOfType(work_loc, 0x1924);
			setType(comp, 0x1928);
		}
		if (stone_type == 0x192F) {
			setType(millstone, 0x1932);
			changeLoc(work_loc, 0x00, 0x00 - 0x01, 0x00);
			comp = getFirstObjectOfType(work_loc, 0x192D);
			setType(comp, 0x1931);
			changeLoc(work_loc, 0x00, 0x02, 0x00);
			comp = getFirstObjectOfType(work_loc, 0x1930);
			setType(comp, 0x1934);
		}
		callback(millstone, 0x05, 0x3B);
	} else {
		systemMessage(user, "You need more wheat to make a sack of flour.");
	}
	return(0x00);
}

trigger callback(0x3B) {
	int obj_type = getObjType(this);
	int rnd;
	int sack_type;
	obj mill = this;
	obj comp;
	loc self_loc = getLocation(this);
	loc loc2;
	loc spawn_loc;
	obj flour;
	if (obj_type == 0x1926) {
		setType(mill, 0x1922);
		changeLoc(self_loc, 0x00 - 0x01, 0x00, 0x00);
		comp = getFirstObjectOfType(self_loc, 0x1925);
		setType(comp, 0x1920);
		changeLoc(self_loc, 0x02, 0x00, 0x00);
		comp = getFirstObjectOfType(self_loc, 0x1928);
		spawn_loc = self_loc;
		setType(comp, 0x1924);
	}
	if (obj_type == 0x1932) {
		setType(mill, 0x192E);
		changeLoc(self_loc, 0x00, 0x00 - 0x01, 0x00);
		comp = getFirstObjectOfType(self_loc, 0x1931);
		setType(comp, 0x192C);
		changeLoc(self_loc, 0x00, 0x02, 0x00);
		comp = getFirstObjectOfType(self_loc, 0x1934);
		spawn_loc = self_loc;
		setType(comp, 0x1930);
	}
	rnd = random(0x00, 0x01);
	if (rnd) {
		sack_type = 0x1039;
	} else {
		sack_type = 0x1045;
	}
	if (findGoodSpotNearWithElev(spawn_loc, getZ(spawn_loc) - 0x08, getZ(spawn_loc) + 0x10, 0x02, getTileHeight(sack_type), 0x00)) {
		flour = createNoResObjectAt(sack_type, spawn_loc);
	} else {
		loc user_loc = getLocation(activating_user);
		flour = createNoResObjectAt(sack_type, user_loc);
	}
	transferResources(flour, this, 0x14, "flour");
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int used_type = getObjType(usedon);
	int mill_type;
	loc used_loc = getLocation(usedon);
	obj mill_obj;
	obj companion;
	loc search_loc = used_loc;
	loc adj_loc;
	switch(used_type) {
	case 0x1920
		changeLoc(search_loc, 0x01, 0x00, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x1922);
		break;
	case 0x1922
		mill_obj = usedon;
		break;
	case 0x192C
		changeLoc(search_loc, 0x00, 0x01, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x192E);
		break;
	case 0x192E
		mill_obj = usedon;
		break;
	case 0x1921
		changeLoc(search_loc, 0x01, 0x00, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x1923);
		break;
	case 0x1923
		mill_obj = usedon;
		break;
	case 0x192D
		changeLoc(search_loc, 0x00, 0x01, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x192F);
		break;
	case 0x192F
		mill_obj = usedon;
		break;
	case 0x1924
		changeLoc(search_loc, 0x00 - 0x01, 0x00, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x1922);
		if (mill_obj == NULL()) {
			mill_obj = getFirstObjectOfType(search_loc, 0x1923);
		}
		break;
	case 0x1930
		changeLoc(search_loc, 0x00, 0x00 - 0x01, 0x00);
		mill_obj = getFirstObjectOfType(search_loc, 0x192E);
		if (mill_obj == NULL()) {
			mill_obj = getFirstObjectOfType(search_loc, 0x192F);
		}
		break;
	default
		return(0x00);
		break;
	}
	adj_loc = search_loc;
	mill_type = getObjType(mill_obj);
	switch(mill_type) {
	case 0x1923
	case 0x192F
		transferResources(mill_obj, this, 0x0A, "flour");
		break;
	case 0x1922
		transferResources(mill_obj, this, 0x0A, "flour");
		setType(mill_obj, 0x1923);
		changeLoc(adj_loc, 0x00 - 0x01, 0x00, 0x00, );
		companion = getFirstObjectOfType(adj_loc, 0x1920);
		setType(companion, 0x1921);
		break;
	case 0x192E
		setType(mill_obj, 0x192F);
		changeLoc(adj_loc, 0x00, 0x00 - 0x01, 0x00, );
		companion = getFirstObjectOfType(adj_loc, 0x192C);
		setType(companion, 0x192D);
		transferResources(mill_obj, this, 0x0A, "flour");
		break;
	}
	int flour_amt;
	int res_result;
	res_result = getResource(flour_amt, this, "flour", 0x03, 0x02);
	if (flour_amt == 0x00) {
		deleteObject(this);
	}
	return(0x00);
}
