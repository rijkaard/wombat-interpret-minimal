inherits globals;

forward void Q4N7();

trigger creation {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x0D96
	case 0x0D9A
	case 0x0D9E
	case 0x0DA2
	case 0x0DA6
	case 0x0DAA
	case 0x0CA8
	case 0x0CAA
	case 0x0CAB
	case 0x0C95
	case 0x0C96
		callback(this, 0x04B0, 0x40);
		break;
	}
	return(0x00);
}

trigger callback(0x40) {
	int res_ok;
	int fruit_count;
	res_ok = getResource(fruit_count, this, "fruit", 0x03, 0x02);
	if (fruit_count > 0x01) {
		loc tree_loc = getLocation(this);
		int tree_type = getObjType(this);
		int fruit;
		switch(tree_type) {
		case 0x0D96
		case 0x0D9A
			fruit = 0x09D0;
			break;
		case 0x0D9E
		case 0x0DA2
			fruit = 0x09D2;
			break;
		case 0x0DA6
		case 0x0DAA
			fruit = 0x172D;
			break;
		case 0x0CA8
		case 0x0CAA
		case 0x0CAB
			fruit = 0x171F;
			break;
		case 0x0C95
			fruit = 0x1726;
			break;
		case 0x0C96
			fruit = 0x1727;
			break;
		}
		loc destination = tree_loc;
		list fruit_nearby;
		getObjectsInRangeOfType(fruit_nearby, tree_loc, 0x03, fruit);
		int roll = random(0x01, 0x06);
		if (roll == 0x01) {
			if (numInList(fruit_nearby) < 0x05) {
				int dx = 0x02 - random(0x00, 0x04);
				int dy = 0x02 - random(0x00, 0x04);
				changeLoc(destination, dx, dy, 0x00);
				obj new_fruit = createNoResObjectAt(fruit, destination);
				transferResources(new_fruit, this, 0x02, "fruit");
			}
		}
	}
	callback(this, 0x04B0, 0x40);
	return(0x00);
}

trigger use {
	int tree_type = getObjType(this);
	int is_variant = 0x00;
	int fruit;
	switch(tree_type) {
	case 0x0D96
	case 0x0D9A
		is_variant = 0x00;
		fruit = 0x09D0;
		break;
	case 0x0D94
	case 0x0D95
	case 0x0D97
	case 0x0D98
	case 0x0D99
	case 0x0D9B
		is_variant = 0x01;
		fruit = 0x09D0;
		break;
	case 0x0D9E
	case 0x0DA2
		is_variant = 0x00;
		fruit = 0x09D2;
		break;
	case 0x0D9C
	case 0x0D9D
	case 0x0D9F
	case 0x0DA0
	case 0x0DA1
	case 0x0DA3
		is_variant = 0x01;
		fruit = 0x09D2;
		break;
	case 0x0DA6
	case 0x0DAA
		is_variant = 0x00;
		fruit = 0x172D;
		break;
	case 0x0DA4
	case 0x0DA5
	case 0x0DA7
	case 0x0DA8
	case 0x0DA9
	case 0x0DAB
		is_variant = 0x01;
		fruit = 0x172D;
		break;
	case 0x0CA8
	case 0x0CAA
	case 0x0CAB
		is_variant = 0x00;
		fruit = 0x171F;
		break;
	case 0x0C95
		is_variant = 0x00;
		fruit = 0x1726;
		break;
	case 0x0C96
		is_variant = 0x00;
		fruit = 0x1727;
		break;
	}
	obj tree;
	loc tree_loc = getLocation(this);
	if (is_variant == 0x01) {
		switch(fruit) {
		case 0x09D0
			tree = getFirstObjectOfType(tree_loc, 0x0D96);
			if (tree == NULL()) {
				tree = getFirstObjectOfType(tree_loc, 0x0D9A);
			}
			break;
		case 0x09D2
			tree = getFirstObjectOfType(tree_loc, 0x0D9E);
			if (tree == NULL()) {
				tree = getFirstObjectOfType(tree_loc, 0x0DA2);
			}
			break;
		case 0x172D
			tree = getFirstObjectOfType(tree_loc, 0x0DA6);
			if (tree == NULL()) {
				tree = getFirstObjectOfType(tree_loc, 0x0DAA);
			}
			break;
		}
	} else {
		tree = this;
	}
	if (tree == NULL()) {
		systemMessage(user, "couldn't find a tree");
		return(0x00);
	}
	int fruit_amt;
	int res = getResource(fruit_amt, tree, "fruit", 0x03, 0x02);
	if (fruit_amt > 0x01) {
		obj backpack = getBackpack(user);
		obj fruit_obj = createNoResObjectIn(fruit, backpack);
		transferResources(fruit_obj, tree, 0x02, "fruit");
		systemMessage(user, "You pick some fruit and put it in your backpack.");
	} else {
		systemMessage(user, "There is no more fruit on this tree");
	}
	return(0x00);
}
