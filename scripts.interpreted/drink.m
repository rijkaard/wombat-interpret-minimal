inherits itemmanip;

forward void update_visual_type();

trigger use {
	int ok;
	int qty;
	ok = getResource(qty, this, "water", 0x03, 0x02);
	if (qty > 0x00) {
		string drinkType = "water";
		if (hasObjVar(this, "drinkType")) {
			drinkType = getObjVar(this, "drinkType");
		}
		systemMessage(user, "What do you want to use this " + drinkType + " on?");
		targetObj(user, this);
	} else {
		barkTo(this, user, "Fill from what?");
		if (hasObjVar(this, "drinkType")) {
			removeObjVar(this, "drinkType");
		}
		targetLoc(user, this);
	}
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	string drinkType = "water";
	if (hasObjVar(this, "drinkType")) {
		drinkType = getObjVar(this, "drinkType");
	}
	int alcohol_level = 0x00;
	if (drinkType == "water") {
		alcohol_level = 0x00;
	}
	if (drinkType == "milk") {
		alcohol_level = 0x00;
	}
	if (drinkType == "ale") {
		alcohol_level = 0x01;
	}
	if (drinkType == "wine") {
		alcohol_level = 0x02;
	}
	if (drinkType == "cider") {
		alcohol_level = 0x03;
	}
	if (drinkType == "liquor") {
		alcohol_level = 0x04;
	}
	int this_type = getObjType(this);
	int target_type = getObjType(usedon);
	loc target_loc = getLocation(usedon);
	int contents_count;
	list transfer_result;
	list contents;
	int drunk_level = 0x00;
	int res_ret;
	int water_amt;
	res_ret = getResource(water_amt, this, "water", 0x03, 0x02);
	if (water_amt > 0x00) {
		if (usedon == user) {
			returnResourcesToBank(this, 0x01, "water");
			int sfx_roll = random(0x01, 0x02);
			if (sfx_roll == 0x01) {
				sfx(target_loc, 0x30, 0x00);
			}
			if (sfx_roll == 0x02) {
				sfx(target_loc, 0x31, 0x00);
			}
			if (alcohol_level > 0x00) {
				if (hasObjVar(user, "drunk")) {
					drunk_level = getObjVar(user, "drunk");
				}
				drunk_level = drunk_level + alcohol_level;
				if (drunk_level + alcohol_level > 0x00) {
					setObjVar(user, "drunk", drunk_level);
					attachScript(user, "drunk");
				}
			}
		} else {
			int water_after;
			switch(target_type) {
			case 0x0995
			case 0x0996
			case 0x0997
			case 0x0998
			case 0x0999
			case 0x099A
			case 0x09B3
			case 0x09BF
			case 0x09CA
			case 0x09CB
			case 0x0FFB
			case 0x0FFC
			case 0x0FFD
			case 0x0FFE
			case 0x0FFF
			case 0x1000
			case 0x1001
			case 0x1002
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x1F81
				if (drinkType == "ale") {
					setType(usedon, 0x09EE);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F8D);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F7D);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F85);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x1F89);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F91);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x1F82
				if (drinkType == "ale") {
					setType(usedon, 0x09EE);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F8E);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F7E);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F86);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x1F8A);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F92);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x1F83
				if (drinkType == "ale") {
					setType(usedon, 0x09EF);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F8F);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F7F);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F87);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x1F8B);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F93);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x1F84
				if (drinkType == "ale") {
					setType(usedon, 0x09EF);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F90);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F80);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F88);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x1F8C);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F94);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x0FF6
				if (drinkType == "ale") {
					setType(usedon, 0x1F95);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F97);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F99);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F9B);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x09F0);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F9D);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x0FF7
				if (drinkType == "ale") {
					setType(usedon, 0x1F96);
				}
				if (drinkType == "cider") {
					setType(usedon, 0x1F98);
				}
				if (drinkType == "liquor") {
					setType(usedon, 0x1F9A);
				}
				if (drinkType == "wine") {
					setType(usedon, 0x1F9C);
				}
				if (drinkType == "milk") {
					setType(usedon, 0x09F0);
				}
				if (drinkType == "water") {
					setType(usedon, 0x1F9E);
				}
				setObjVar(usedon, "drinkType", drinkType);
				fill_container_4(transfer_result, this, usedon, "water");
				break;
			case 0x0FFA
			case 0x154D
			case 0x0E7B
				if (drinkType == "water") {
					fill_container_4(transfer_result, this, usedon, "water");
				} else {
					barkTo(this, user, "Can't pour that in there.");
				}
				break;
			case 0x14E0
			case 0x0E77
			case 0x0E83
				if (drinkType == "water") {
					getcontents(contents, usedon);
					contents_count = numInList(contents);
					if (contents_count < 0x01) {
						int filled_type;
						if (target_type == 0x14E0) {
							filled_type = 0x0FFA;
						}
						if (target_type == 0x0E77) {
							filled_type = 0x154D;
						}
						if (target_type == 0x0E83) {
							filled_type = 0x0E7B;
						}
						obj new_container;
						new_container = createNoResObjectAt(filled_type, target_loc);
						deleteObject(usedon);
						fill_container_4(transfer_result, this, new_container, "water");
					} else {
						barkTo(this, user, "That has something in it.");
					}
				} else {
					barkTo(this, user, "Can't pour that in there.");
				}
				break;
			case 0x103A
			case 0x1046
			case 0x0A1E
				obj backpack = getBackpack(user);
				if (drinkType == "water") {
					int flour;
					res_ret = getResource(flour, usedon, "flour", 0x03, 0x02);
					if (flour > 0x00) {
						loc location = getLocation(user);
						returnResourcesToBank(this, 0x01, "water");
						returnResourcesToBank(usedon, 0x01, "flour");
						systemMessage(user, "You make some dough and put it in your backpack");
						obj dough = createNoResObjectIn(0x103D, backpack);
						if (flour == 0x01) {
							if (target_type == 0x0A1E) {
								setType(usedon, 0x15F8);
								detachScript(usedon, "2590");
							} else {
								deleteObject(usedon);
							}
						}
					} else {
						systemMessage(user, "No flour left.");
						if (target_type == 0x0A1E) {
							setType(usedon, 0x15F8);
							detachScript(usedon, "2590");
						} else {
							deleteObject(usedon);
						}
					}
				} else {
					systemMessage(user, "Can't pour it there.");
					return(0x00);
				}
				break;
			default
				systemMessage(user, "Can't pour it there.");
				return(0x00);
				break;
			}
			res_ret = getResource(water_after, this, "water", 0x03, 0x02);
			if (water_after == water_amt) {
				systemMessage(user, "Couldn't pour it there.  It was already full.");
			} else {
				sfx(target_loc, 0x4E, 0x00);
			}
		}
		res_ret = getResource(water_after, this, "water", 0x03, 0x02);
		if (water_after < 0x01) {
			if (hasObjVar(this, "emptyVersion")) {
				removeObjVar(this, "drinkType");
				int emptyVersion = getObjVar(this, "emptyVersion");
				setType(this, emptyVersion);
			} else {
				deleteObject(this);
			}
		}
	} else {
		if (hasObjVar(this, "drinkType")) {
			removeObjVar(this, "drinkType");
		}
		int src_remainder;
		int dest;
		switch(target_type) {
		case 0x099B
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				deleteObject(usedon);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "liquor");
			}
			break;
		case 0x099F
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				deleteObject(usedon);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "ale");
			}
			break;
		case 0x09C7
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				deleteObject(usedon);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "wine");
			}
			break;
		case 0x09C8
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				deleteObject(usedon);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "cider");
			}
			break;
		case 0x0FFA
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				obj empty_barrel;
				empty_barrel = createNoResObjectAt(0x14E0, target_loc);
				deleteObject(usedon);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "water");
			}
			break;
		case 0x154D
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				change_type(usedon, 0x0E77);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "water");
			}
			break;
		case 0x0E7B
			fill_container_4(transfer_result, usedon, this, "water");
			src_remainder = transfer_result[0x00];
			dest = transfer_result[0x01];
			if (src_remainder < 0x01) {
				change_type(usedon, 0x0E83);
			}
			if (dest > 0x00) {
				setObjVar(this, "drinkType", "water");
			}
			break;
		default
			if (getObjectFlags(usedon, 0x80)) {
				addGlobalQuantity(this, 0x01);
				systemMessage(user, "You fill " + getName(this) + " with water.");
				setObjVar(this, "drinkType", "water");
			} else {
				return(0x00);
			}
			break;
		}
		update_visual_type();
	}
	return(0x00);
}

function void update_visual_type() {
	string drinkType = "water";
	if (hasObjVar(this, "drinkType")) {
		drinkType = getObjVar(this, "drinkType");
	}
	int type = getObjType(this);
	switch(type) {
	case 0x0FF6
		if (drinkType == "ale") {
			setType(this, 0x1F95);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F97);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F99);
		}
		if (drinkType == "milk") {
			setType(this, 0x09F0);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F9B);
		}
		if (drinkType == "water") {
			setType(this, 0x1F9D);
		}
		break;
	case 0x0FF7
		if (drinkType == "ale") {
			setType(this, 0x1F96);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F98);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F9A);
		}
		if (drinkType == "milk") {
			setType(this, 0x09F0);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F9C);
		}
		if (drinkType == "water") {
			setType(this, 0x1F9E);
		}
		break;
	case 0x1F81
		if (drinkType == "ale") {
			setType(this, 0x09EE);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F7D);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F85);
		}
		if (drinkType == "milk") {
			setType(this, 0x1F89);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F8D);
		}
		if (drinkType == "water") {
			setType(this, 0x1F91);
		}
		break;
	case 0x1F82
		if (drinkType == "ale") {
			setType(this, 0x09EE);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F7E);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F86);
		}
		if (drinkType == "milk") {
			setType(this, 0x1F8A);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F8E);
		}
		if (drinkType == "water") {
			setType(this, 0x1F92);
		}
		break;
	case 0x1F83
		if (drinkType == "ale") {
			setType(this, 0x09EF);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F7F);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F87);
		}
		if (drinkType == "milk") {
			setType(this, 0x1F8B);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F8F);
		}
		if (drinkType == "water") {
			setType(this, 0x1F93);
		}
		break;
	case 0x1F84
		if (drinkType == "ale") {
			setType(this, 0x09EF);
		}
		if (drinkType == "cider") {
			setType(this, 0x1F80);
		}
		if (drinkType == "liquor") {
			setType(this, 0x1F88);
		}
		if (drinkType == "milk") {
			setType(this, 0x1F8C);
		}
		if (drinkType == "wine") {
			setType(this, 0x1F90);
		}
		if (drinkType == "water") {
			setType(this, 0x1F94);
		}
		break;
	}
	return();
}

trigger targetloc {
	int tile = getTileAt(place);
	if (getTerrainFlags(tile, 0x80)) {
		addGlobalQuantity(this, 0x01);
		systemMessage(user, "You fill " + getName(this) + " with water.");
		setObjVar(this, "drinkType", "water");
		update_visual_type();
	}
	return(0x00);
}

trigger lookedat {
	int ret;
	int obj_type = getObjType(this);
	string container_label;
	string name;
	string drinkType;
	switch(obj_type) {
	case 0x0995
	case 0x0996
	case 0x0997
	case 0x0998
	case 0x0999
	case 0x099A
	case 0x09B3
	case 0x09BF
	case 0x09CA
	case 0x09CB
	case 0x0FFB
	case 0x0FFC
	case 0x0FFD
	case 0x0FFE
	case 0x0FFF
	case 0x1000
	case 0x1001
	case 0x1002
		name = getName(this);
		if (hasObjVar(this, "drinkType")) {
			drinkType = getObjVar(this, "drinkType");
			barkTo(this, looker, name + " of " + drinkType);
		} else {
			barkTo(this, looker, name);
		}
		return(0x00);
	case 0x099B
		container_label = " bottle of ";
		break;
	case 0x099F
		container_label = " bottle of ";
		break;
	case 0x09C7
		container_label = " bottle of ";
		break;
	case 0x09C8
		container_label = " jug of ";
		break;
	default
		name = getName(this);
		barkTo(this, looker, name);
		return(0x00);
		break;
	}
	name = getName(this);
	if (!hasObjVar(this, "drinkType")) {
		return(0x01);
	}
	drinkType = getObjVar(this, "drinkType");
	int capacity;
	int cur_water;
	string fill_desc;
	ret = getResource(capacity, this, "water", 0x03, 0x00);
	ret = getResource(cur_water, this, "water", 0x03, 0x02);
	if ((0x05 * cur_water) / capacity < 0x03) {
		fill_desc = "A nearly empty";
	}
	if ((0x05 * cur_water) / capacity == 0x03) {
		fill_desc = "A half full";
	}
	if ((0x05 * cur_water) / capacity > 0x03) {
		fill_desc = "A full";
	}
	barkTo(this, looker, fill_desc + container_label + drinkType + ".");
	return(0x00);
}
