inherits itemmanip;

forward void attempt_tailoring();

forward void create_garment();

forward void fail_tailoring();

member obj crafter;

member obj material_obj;

member int garment_type;

member int material_amount;

member int material_cost;

member int is_cloth_bolt;

member int material_hue;

trigger use {
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone else is using that.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x00);
		callback(this, 0x3C, 0x1B);
	}
	systemMessage(user, "What cloth shall I use this sewing kit on?");
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "You can't see that.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	crafter = user;
	material_obj = usedon;
	int res_result;
	int obj_type = getObjType(usedon);
	switch(obj_type) {
	case 0x0F95
	case 0x0F96
	case 0x0F97
	case 0x0F98
	case 0x0F99
	case 0x0F9A
	case 0x0F9B
	case 0x0F9C
		if (isAtHome(usedon)) {
			systemMessage(user, "That cloth belongs to someone else.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		if (hasObjVar(material_obj, "inUse")) {
			systemMessage(user, "Someone else is using that cloth.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		} else {
			setObjVar(material_obj, "inUse", 0x01);
			attachscript(material_obj, "removeinuse");
			callback(material_obj, 0x3C, 0x1B);
		}
		res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
		if (material_amount > 0x00) {
			is_cloth_bolt = 0x01;
			material_hue = getHue(material_obj);
			list cloth_categories = 0x1517, "shirts", 0x1539, "pants", 0x153D, "misc";
			selectType(crafter, this, 0x11, "Choose a category.", cloth_categories);
		} else {
			bark(user, "There's no cloth on that");
			if (hasObjVar(material_obj, "inUse")) {
				removeObjVar(material_obj, "inUse");
			}
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		break;
	case 0x175D
	case 0x175E
	case 0x175F
	case 0x1760
	case 0x1761
	case 0x1762
	case 0x1763
	case 0x1764
	case 0x1765
	case 0x1766
	case 0x1767
	case 0x1768
		if (isAtHome(usedon)) {
			systemMessage(user, "That cloth belongs to someone else.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		if (hasObjVar(material_obj, "inUse")) {
			systemMessage(user, "Someone else is using that cloth.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		} else {
			setObjVar(material_obj, "inUse", 0x01);
			attachscript(material_obj, "removeinuse");
			callback(material_obj, 0x3C, 0x1B);
		}
		res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
		if (material_amount > 0x00) {
			is_cloth_bolt = 0x01;
			material_hue = getHue(material_obj);
			list cloth = 0x1517, "shirts", 0x1539, "pants", 0x153D, "misc", 0x0F95, "bolt of cloth";
			selectType(crafter, this, 0x11, "Choose a category.", cloth);
		} else {
			bark(user, "There's no cloth on that");
			if (hasObjVar(material_obj, "inUse")) {
				removeObjVar(material_obj, "inUse");
			}
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		break;
	case 0x1067
	case 0x1068
	case 0x1081
	case 0x1082
	case 0x1078
	case 0x1079
		if (isAtHome(usedon)) {
			systemMessage(user, "That leather belongs to someone else.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		if (hasObjVar(material_obj, "inUse")) {
			systemMessage(user, "Someone else is using that leather.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		} else {
			setObjVar(material_obj, "inUse", 0x01);
			attachscript(material_obj, "removeinuse");
			callback(material_obj, 0x3C, 0x1B);
		}
		res_result = getResource(material_amount, material_obj, "leather", 0x03, 0x02);
		if (material_amount > 0x00) {
			is_cloth_bolt = 0x00;
			list leather = 0x1710, "footwear", 0x13CC, "leather armor", 0x13DB, "studded armor", 0x1C02, "female armor";
			selectType(crafter, this, 0x12, "Choose a category.", leather);
		} else {
			bark(user, "There's no leather on that");
			if (hasObjVar(material_obj, "inUse")) {
				removeObjVar(material_obj, "inUse");
			}
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		break;
	default
		systemMessage(user, "Can't use a sewing kit on that.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		break;
	}
	return(0x00);
}

trigger typeselected(0x11) {
	switch(listindex) {
	case 0x01
		list shirts = 0x1517, "Shirt - takes 8 cloth.", 0x1515, "Cloak - takes 14 cloth.", 0x1EFD, "Fancy shirt - takes 8 cloth.", 0x1EFF, "Fancy dress - takes 12 cloth.", 0x1F01, "Plain dress - takes 10 cloth.", 0x1F03, "Robe - takes 16 cloth.";
		selectType(crafter, this, 0x13, "What kind of shirt?", shirts);
		break;
	case 0x02
		list pants = 0x1539, "Fancy pants - takes 8 cloth.", 0x1537, "Kilt - takes 8 cloth.", 0x1516, "Skirt - takes 10 cloth.";
		selectType(crafter, this, 0x14, "What kind of pants?", pants);
		break;
	case 0x03
		list misc = 0x1544, "Skullcap - takes 2 cloth.", 0x1540, "Bandana - takes 2 cloth.", 0x1541, "Body sash - takes 4 cloth.", 0x153B, "Half apron - takes 6 cloth.", 0x153D, "Full apron - takes 10 cloth.";
		selectType(crafter, this, 0x15, "What do you want to make?", misc);
		break;
	case 0x04
		list bolt = 0x0F95, "Bolt of cloth - takes 50 cloth.", 0x0F96, "Bolt of cloth - takes 50 cloth.", 0x0F97, "Bolt of cloth - takes 50 cloth.";
		selectType(crafter, this, 0x3B, "What do you want to make?", bolt);
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	return(0x00);
}

trigger typeselected(0x13) {
	garment_type = objtype;
	switch(objtype) {
	case 0x1517
	case 0x1EFD
		material_cost = 0x08;
		break;
	case 0x1F01
		material_cost = 0x0A;
		break;
	case 0x1EFF
		material_cost = 0x0C;
		break;
	case 0x1515
		material_cost = 0x0E;
		break;
	case 0x1F03
		material_cost = 0x10;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x14) {
	garment_type = objtype;
	switch(objtype) {
	case 0x1539
	case 0x1537
		material_cost = 0x08;
		break;
	case 0x1516
		material_cost = 0x0A;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x15) {
	garment_type = objtype;
	switch(objtype) {
	case 0x1544
	case 0x1540
		material_cost = 0x02;
		break;
	case 0x1541
		material_cost = 0x04;
		break;
	case 0x153B
		material_cost = 0x06;
		break;
	case 0x153D
		material_cost = 0x0A;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x3B) {
	garment_type = objtype;
	switch(objtype) {
	case 0x0F95
	case 0x0F96
	case 0x0F97
		material_cost = 0x32;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int res_result = getResource(material_amount, material_obj, "cloth", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x12) {
	switch(listindex) {
	case 0x01
		list footwear_list = 0x170B, "Boots - take 8 leather.", 0x170D, "Sandals - take 4 leather.", 0x1710, "Shoes - take 6 leather.", 0x1712, "Thigh boots - take 10 leather.";
		selectType(crafter, this, 0x26, "What kind of shoes?", footwear_list);
		break;
	case 0x02
		list leather_armor_list = 0x13C7, "Leather gorget - takes 4 leather.", 0x13C6, "Leather gloves - takes 6 leather.", 0x13C5, "Leather sleeves - takes 8 leather.", 0x13CB, "Leather leggings - takes 10 leather.", 0x13CC, "Leather tunic - takes 12 leather.";
		selectType(crafter, this, 0x16, "What kind of leather armor?", leather_armor_list);
		break;
	case 0x03
		list studded_armor_list = 0x13D6, "Studded gorget - takes 6 leather.", 0x13D5, "Studded gloves - takes 8 leather.", 0x13D4, "Studded sleeves - takes 10 leather.", 0x13DA, "Studded leggings - takes 12 leather.", 0x13DB, "Studded tunic - takes 14 leather.";
		selectType(crafter, this, 0x17, "What kind of studded armor?", studded_armor_list);
		break;
	case 0x04
		list female_armor_list = 0x1C00, "Shorts - take 4 leather.", 0x1C02, "One piece - takes 10 leather.", 0x1C06, "One Piece - takes 8 leather.", 0x1C08, "Skirt - takes 6 leather.", 0x1C0A, "Top - takes 4 leather.", 0x1C0C, "Top - takes 4 leather.";
		selectType(crafter, this, 0x2A, "What kind of female armor?", female_armor_list);
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	return(0x00);
}

trigger typeselected(0x26) {
	garment_type = objtype;
	switch(objtype) {
	case 0x170D
		material_cost = 0x04;
		break;
	case 0x1710
		material_cost = 0x06;
		break;
	case 0x170B
		material_cost = 0x08;
		break;
	case 0x1712
		material_cost = 0x0A;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int resource_result = getResource(material_amount, material_obj, "leather", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x16) {
	garment_type = objtype;
	switch(objtype) {
	case 0x13C7
		material_cost = 0x04;
		break;
	case 0x13C6
		material_cost = 0x06;
		break;
	case 0x13C5
		material_cost = 0x08;
		break;
	case 0x13CB
		material_cost = 0x0A;
		break;
	case 0x13CC
		material_cost = 0x0C;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int ok = getResource(material_amount, material_obj, "leather", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x17) {
	garment_type = objtype;
	switch(objtype) {
	case 0x13D6
		material_cost = 0x06;
		break;
	case 0x13D5
		material_cost = 0x08;
		break;
	case 0x13D4
		material_cost = 0x0A;
		break;
	case 0x13DA
		material_cost = 0x0C;
		break;
	case 0x13DB
		material_cost = 0x0E;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int resource_ok = getResource(material_amount, material_obj, "leather", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

trigger typeselected(0x2A) {
	garment_type = objtype;
	switch(objtype) {
	case 0x1C00
	case 0x1C0A
	case 0x1C0C
		material_cost = 0x04;
		break;
	case 0x1C08
		material_cost = 0x06;
		break;
	case 0x1C06
		material_cost = 0x08;
		break;
	case 0x1C02
		material_cost = 0x0A;
		break;
	default
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	int resource_ok = getResource(material_amount, material_obj, "leather", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough material to make this.");
		if (hasObjVar(material_obj, "inUse")) {
			removeObjVar(material_obj, "inUse");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	attempt_tailoring();
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

function void create_garment() {
	obj garment;
	int cloth_remainder = 0x32 - material_cost;
	obj leftover_cloth;
	list temp_list;
	int material_remaining = material_amount - material_cost;
	int result;
	obj backpack = getBackpack(crafter);
	loc location = getLocation(crafter);
	string name = getNameByType(garment_type);
	if (is_cloth_bolt) {
		is_cloth_bolt = 0x00;
		switch(getObjType(material_obj)) {
		case 0x0F95
		case 0x0F96
		case 0x0F97
		case 0x0F98
		case 0x0F99
		case 0x0F9A
		case 0x0F9B
		case 0x0F9C
			leftover_cloth = createNoResObjectAt(0x1766, getLocation(crafter));
			garment = createNoResObjectAt(garment_type, getLocation(crafter));
			sfx(location, 0x0248, 0x00);
			transferResources(leftover_cloth, material_obj, 0x32, "cloth");
			transferResources(garment, leftover_cloth, material_cost, "cloth");
			setHue(leftover_cloth, material_hue);
			setHue(garment, material_hue);
			if (canHold(backpack, leftover_cloth)) {
				int put_result = putObjContainer(leftover_cloth, backpack);
				systemMessage(crafter, "You place the left-over cloth pieces into your backpack");
			} else {
				systemMessage(crafter, "You place the left over cloth pieces at your feet.");
			}
			int src_cloth_amt;
			int leftover_cloth_amt;
			result = getResource(leftover_cloth_amt, leftover_cloth, "cloth", 0x03, 0x02);
			result = getResource(src_cloth_amt, material_obj, "cloth", 0x03, 0x02);
			if ((getQuantity(material_obj) == 0x01) && (src_cloth_amt < 0x32)) {
				deleteObject(material_obj);
			}
			if ((getQuantity(leftover_cloth) == 0x01) && (leftover_cloth_amt < 0x01)) {
				deleteObject(leftover_cloth);
			}
			break;
		default
			garment = createNoResObjectAt(garment_type, getLocation(crafter));
			sfx(location, 0x0248, 0x00);
			transferResources(garment, material_obj, material_cost, "cloth");
			setHue(garment, material_hue);
			if ((getQuantity(material_obj) == 0x01) && (material_remaining < 0x01)) {
				deleteObject(material_obj);
			}
			break;
		}
	} else {
		garment = createNoResObjectAt(garment_type, getLocation(crafter));
		sfx(location, 0x0248, 0x00);
		transferResources(garment, material_obj, material_cost, "leather");
		if ((getQuantity(material_obj) == 0x01) && (material_remaining < 0x01)) {
			deleteObject(material_obj);
		}
	}
	if (canHold(backpack, garment)) {
		put_result = putObjContainer(garment, backpack);
		systemMessage(crafter, "You create the " + name + " and put it in your backpack.");
	} else {
		systemMessage(crafter, "You create the " + name + " and put it at your feet.");
	}
	if (hasObjVar(material_obj, "inUse")) {
		removeObjVar(material_obj, "inUse");
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	if (drain_tool_life(crafter, this)) {
		deleteObject(this);
	}
	return();
}

function void fail_tailoring() {
	obj cloth_piece;
	int skill_tier;
	int waste_divisor;
	int ruined_amt;
	int transfer_amt;
	list items;
	int leftover = material_amount - material_cost;
	int fail_rc;
	obj backpack = getBackpack(crafter);
	loc location = getLocation(crafter);
	string material;
	material = "cloth";
	skill_tier = (getSkillLevelReal(crafter, 0x22) / 0x64);
	switch(skill_tier) {
	case 0x0A
	case 0x09
	case 0x08
		waste_divisor = 0x04;
		break;
	case 0x07
	case 0x06
	case 0x05
	case 0x04
		waste_divisor = 0x02;
		break;
	default
		waste_divisor = 0x01;
		break;
	}
	ruined_amt = (material_cost / waste_divisor) - (random(0x00, (material_cost / waste_divisor)));
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	switch(getObjType(material_obj)) {
	case 0x0F95
	case 0x0F96
	case 0x0F97
	case 0x0F98
	case 0x0F99
	case 0x0F9A
	case 0x0F9B
	case 0x0F9C
		transfer_amt = 0x32 - ruined_amt;
		cloth_piece = createNoResObjectAt(0x1766, getLocation(crafter));
		transferResources(cloth_piece, material_obj, transfer_amt, "cloth");
		setHue(cloth_piece, material_hue);
		if (canHold(backpack, cloth_piece)) {
			int rc = putObjContainer(cloth_piece, backpack);
			systemMessage(crafter, "You place the left-over cloth pieces into your backpack");
		} else {
			systemMessage(crafter, "You place the left over cloth pieces at your feet.");
		}
		systemMessage(crafter, "Tailoring failed. Some of the cloth is ruined.");
		int remaining;
		fail_rc = getResource(remaining, material_obj, "cloth", 0x03, 0x02);
		if ((getQuantity(material_obj) == 0x01) && (remaining < 0x32)) {
			deleteObject(material_obj);
		}
		break;
	case 0x175D
	case 0x175E
	case 0x175F
	case 0x1760
	case 0x1761
	case 0x1762
	case 0x1763
	case 0x1764
	case 0x1765
	case 0x1766
	case 0x1767
	case 0x1768
		systemMessage(crafter, "Tailoring failed. Some of the cloth is ruined.");
		returnResourcesToBank(material_obj, ruined_amt, "cloth");
		break;
	case 0x1067
	case 0x1068
	case 0x1081
	case 0x1082
	case 0x1078
	case 0x1079
		systemMessage(crafter, "Tailoring failed. Some of the leather is ruined.");
		returnResourcesToBank(material_obj, ruined_amt, "leather");
		break;
	}
	fail_rc = getResource(remaining, material_obj, material, 0x03, 0x02);
	if ((getQuantity(material_obj) == 0x01) && (remaining < 0x01)) {
		deleteObject(material_obj);
	}
	return();
}

function void attempt_tailoring() {
	int skill_check = testSkillReal(crafter, 0x22);
	if (skill_check < 0x01) {
		fail_tailoring();
	} else {
		create_garment();
	}
	return();
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}
