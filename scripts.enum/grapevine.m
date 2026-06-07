inherits globals;

trigger use {
	int obj_type = getObjType(this);
	obj backpack = getBackpack(user);
	obj grapes;
	obj item;
	obj vine;
	int is_ew;
	int res_result;
	int fruit_qty;
	loc location = getLocation(this);
	switch(obj_type) {
	case 0x0D1E
	case 0x0D1F
	case 0x0D23
	case 0x0D24
		res_result = getResource(fruit_qty, this, "fruit", 0x03, 0x02);
		if (fruit_qty > 0x00) {
			grapes = createNoResObjectIn(0x0D1A, backpack);
			returnResourcesToBank(this, 0x01, "fruit");
			systemMessage(user, "You pick some grapes and put them in your backpack.");
		} else {
			systemMessage(user, "None of the grapes are ripe enough.");
		}
		return(0x00);
		break;
	case 0x0D1B
		is_ew = 0x00;
		changeLoc(location, 0x00, 0x00 - 0x02, 0x00);
		break;
	case 0x0D1C
		is_ew = 0x00;
		changeLoc(location, 0x00, 0x02, 0x00);
		break;
	case 0x0D1D
		is_ew = 0x00;
		changeLoc(location, 0x00, 0x02, 0x00);
		break;
	case 0x0D20
		is_ew = 0x01;
		changeLoc(location, 0x00 - 0x02, 0x00, 0x00);
		break;
	case 0x0D21
		is_ew = 0x01;
		changeLoc(location, 0x02, 0x00, 0x00);
		break;
	case 0x0D22
		is_ew = 0x01;
		changeLoc(location, 0x02, 0x00, 0x00);
		break;
	}
	if (is_ew) {
		vine = getFirstObjectOfType(location, 0x0D23);
		if (vine == NULL()) {
			vine = getFirstObjectOfType(location, 0x0D24);
		}
	} else {
		vine = getFirstObjectOfType(location, 0x0D1E);
		if (vine == NULL()) {
			vine = getFirstObjectOfType(location, 0x0D1F);
		}
	}
	if (vine == NULL()) {
		return(0x00);
	}
	res_result = getResource(fruit_qty, vine, "fruit", 0x03, 0x02);
	if (fruit_qty > 0x00) {
		grapes = createNoResObjectIn(0x0D1A, backpack);
		returnResourcesToBank(vine, 0x01, "fruit");
		systemMessage(user, "You pick some grapes and put them in your backpack.");
	} else {
		systemMessage(user, "None of the grapes are ripe enough.");
	}
	return(0x00);
}
