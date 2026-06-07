inherits itemmanip;

member int is_useless;

function string get_material_desc(obj item) {
	int rc;
	int bar;
	string count_str;
	int cloth;
	int leather;
	string desc;
	rc = getResource(cloth, item, "cloth", 0x03, 0x02);
	bar = getResource(leather, item, "leather", 0x03, 0x02);
	if (cloth > 0x00) {
		count_str = cloth;
		if (cloth > 0x01) {
			desc = count_str + " yards of cloth";
		} else {
			desc = count_str + " yard of cloth";
		}
		return(desc);
	}
	if (leather > 0x00) {
		count_str = leather;
		if (leather > 0x01) {
			desc = count_str + " yards of leather";
		} else {
			desc = count_str + " yard of leather";
		}
		return(desc);
	}
	desc = "useless scraps";
	is_useless = 0x01;
	return(desc);
}

function string get_item_name(obj item, int plural) {
	string name;
	int item_type = getObjType(item);
	switch(item_type) {
	case 0x0F95
	case 0x0F96
	case 0x0F97
	case 0x0F98
	case 0x0F99
	case 0x0F9A
	case 0x0F9B
	case 0x0F9C
		if (plural == 0x01) {
			name = "bolts of cloth";
		} else {
			name = "a bolt of cloth";
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
		if (plural == 0x01) {
			name = "piles of folded cloth";
		} else {
			name = "a pile of folded cloth";
		}
		break;
	case 0x1765
	case 0x1766
	case 0x1767
	case 0x1768
		if (plural == 0x01) {
			name = "pieces of cloth";
		} else {
			name = "a piece of cloth";
		}
		break;
	case 0x1067
	case 0x1068
	case 0x1081
	case 0x1082
		if (plural == 0x01) {
			name = "pieces of leather";
		} else {
			name = "a piece of leather";
		}
		break;
	case 0x1078
	case 0x1079
		if (plural == 0x01) {
			name = "piles of hides";
		} else {
			name = "a pile of hides";
		}
		break;
	}
	return(name);
}

trigger lookedat {
	string bark_str;
	string resource_str;
	string item_desc;
	is_useless = 0x00;
	int qty = getQuantity(this);
	string qty_str = qty;
	resource_str = get_material_desc(this);
	if (qty > 0x01) {
		item_desc = get_item_name(this, 0x01);
		bark_str = qty_str + " " + item_desc + " (" + resource_str + ") ";
	} else {
		item_desc = get_item_name(this, 0x00);
		bark_str = item_desc + " (" + resource_str + ") ";
	}
	barkTo(this, looker, bark_str);
	if (is_useless == 0x01) {
		systemMessage(looker, "You throw the useless pieces away.");
		is_useless = 0x00;
		deleteObject(this);
	}
	return(0x00);
}
