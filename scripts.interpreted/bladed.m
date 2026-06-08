inherits itemmanip;

function void place_in_pack_or_drop(obj user_obj, obj item, string msg) {
	obj backpack = getBackpack(user_obj);
	string full_msg = msg;
	if (isValid(backpack) && canHold(backpack, item)) {
		concat(full_msg, " in your backpack.");
		int result = putObjContainer(item, backpack);
	} else {
		concat(full_msg, " at your feet.");
	}
	systemMessage(user_obj, full_msg);
	return();
}

function void init_fletching_table() {
	deleteArray(0x01);
	if (isArrayInit(0x01)) {
		return();
	}
	list cols = 0x00, "COL_NAME", 0x02, 0x03, "COL_ACTION";
	initArray(0x01, 0x05, 0x05, cols);
	setArrayIntElem(0x01, 0x00, 0x00, 0x0DE1);
	setArrayIntElem(0x01, 0x02, 0x00, 0x00 - 0x03E8);
	setArrayIntElem(0x01, 0x00, 0x01, 0x1BD4);
	setArrayIntElem(0x01, 0x02, 0x01, 0x00);
	setArrayStrElem(0x01, 0x01, 0x01, "Arrow shafts using all wood");
	setArrayStrElem(0x01, 0x04, 0x01, "shafts");
	setArrayIntElem(0x01, 0x00, 0x02, 0x13B2);
	setArrayIntElem(0x01, 0x02, 0x02, 0x012C);
	setArrayIntElem(0x01, 0x00, 0x03, 0x0F4F);
	setArrayIntElem(0x01, 0x02, 0x03, 0x0258);
	setArrayIntElem(0x01, 0x00, 0x04, 0x13FD);
	setArrayIntElem(0x01, 0x02, 0x04, 0x0384);
	for (int i = 0x00; i < 0x05; i++) {
		int item_type = getArrayIntElem(0x01, 0x00, i);
		obj temp_obj = createNoResObjectAt(item_type, getLocation(this));
		int wood = 0x00;
		int result = getResource(wood, temp_obj, "wood", 0x03, 0x00);
		setArrayIntElem(0x01, 0x03, i, wood);
		deleteObject(temp_obj);
	}
	return();
}

trigger creation {
	init_fletching_table();
	return(0x01);
}

trigger objectloaded {
	init_fletching_table();
	return(0x01);
}

forward int is_axe(obj );

function void animate_if_alive(obj mobile, int anim) {
	if (getItemAtSlot(mobile, 0x19) != NULL()) {
		return();
	}
	if (getObjType(mobile) >= 0x0190) {
		animateMobile(mobile, anim, 0x14, 0x01, 0x00, 0x00);
	}
	return();
}

function obj spawn_blood_effect(loc pos) {
	obj effect = createNoResObjectAt(random(0x122A, 0x122F), pos);
	attachScript(effect, "deletethis");
	callback(effect, 0x01A4, 0x1B);
	return(effect);
}

function obj create_body_part(loc pos, int obj_type, string part_name, string body_name) {
	obj part = createNoResObjectAt(obj_type, pos);
	setObjVar(part, "nameVar", body_name);
	setObjVar(part, "lookAtText", part_name + " of " + body_name);
	int result = makeValueless(part);
	callbackAdvanced(part, 0x04 * 0x3C * 0x1E, 0x01, 0x00);
	return(part);
}

function void carve_named_corpse(obj user, obj usedon) {
	list contents;
	loc target_loc;
	string name;
	int teleport_result;
	obj part;
	obj weapon;
	target_loc = getLocation(usedon);
	name = getObjVar(usedon, "nameVar");
	int result;
	switch(getObjType(usedon)) {
	case 0x2006
		if (!getCompileFlag(0x01)) {
			if (getNotorietyLevel(user) >= (0x00 - 0x02)) {
				addNotoriety(user, 0x00 - 0x0A);
			}
		} else {
			if (canBeFreelyAggressedBy(usedon, user)) {
				changeKarma(user, 0x00 - 0x1B58);
			} else {
				changeKarma(user, 0x00 - 0x07D0);
			}
			receiveUnhealthyActionFrom(usedon, user);
		}
		getContents(contents, usedon);
		for (int x = 0x00; x < numInList(contents); x++) {
			obj item = contents[x];
			int slot = getEquipSlot(item);
			if ((slot != 0x0B) && (slot != 0x10)) {
				teleport_result = teleport(item, target_loc);
			}
		}
		weapon = spawn_blood_effect(target_loc);
		part = create_body_part(target_loc, 0x1DA0, "head", name);
		copyObjVar(part, usedon, "controller");
		deleteObject(usedon);
		part = create_body_part(target_loc, 0x1DA1, "left arm", name);
		part = create_body_part(target_loc, 0x1DA2, "right arm", name);
		part = create_body_part(target_loc, 0x1DA3, "left leg", name);
		part = create_body_part(target_loc, 0x1DA4, "right leg", name);
		part = create_body_part(target_loc, 0x1D9F, "torso", name);
		break;
	case 0x1DA0
		deleteObject(usedon);
		weapon = spawn_blood_effect(target_loc);
		part = create_body_part(target_loc, 0x1CF0, "brain", name);
		part = create_body_part(target_loc, 0x1AE2, "skull", name);
		break;
	case 0x1D9F
		deleteObject(usedon);
		weapon = spawn_blood_effect(target_loc);
		part = create_body_part(target_loc, 0x1B17, "ribcage", name);
		part = create_body_part(target_loc, 0x1CEE, "liver", name);
		part = create_body_part(target_loc, 0x1CED, "heart", name);
		part = create_body_part(target_loc, 0x1CEC, "entrails", name);
		break;
	case 0x1DA4
	case 0x1DA3
		deleteObject(usedon);
		weapon = spawn_blood_effect(target_loc);
		part = create_body_part(target_loc, 0x1B11, "femur", name);
		break;
	case 0x1DA1
	case 0x1DA2
		deleteObject(usedon);
		weapon = spawn_blood_effect(target_loc);
		part = create_body_part(target_loc, 0x1B12, "armbone", name);
		break;
	}
	return();
}

trigger use {
	string use_prompt = "What do you want to use " + getName(this) + " on?";
	systemMessage(user, use_prompt);
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(usedon), getLocation(user)) > 0x03) {
		systemMessage(user, "That is too far away.");
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "You can't see that.");
		return(0x00);
	}
	int ret;
	int carved;
	carved = 0x00;
	if (hasObjVar(usedon, "nameVar")) {
		carve_named_corpse(user, usedon);
		return(0x00);
	}
	if (isMobile(usedon)) {
		int obj_type = getObjType(usedon);
		if (obj_type != 0xCF) {
			if (obj_type == 0xDF) {
				ebarkTo(usedon, user, "This sheep is not yet ready to be shorn.");
			} else {
				ebarkTo(usedon, user, "But that's not dead!");
			}
			return(0x00);
		}
		int wool_amt;
		ret = getResource(wool_amt, usedon, "cloth", 0x03, 0x02);
		if (wool_amt > 0x1D) {
			setType(usedon, 0xDF);
			setObjVar(usedon, "woolOnSheep", 0x01);
			obj wool = createNoResObjectAt(0x0DF8, getLocation(user));
			transferResources(wool, usedon, wool_amt, "cloth");
			place_in_pack_or_drop(user, wool, "You place the wool");
		} else {
			ebarkTo(usedon, user, "The sheep nimbly escapes your attempts to sheer his wool.");
		}
		return(0x00);
	}
	int obj_type2 = getObjType(usedon);
	obj backpack = getBackpack(user);
	switch(obj_type2) {
	case 0x1BD7
	case 0x1BD8
	case 0x1BD9
	case 0x1BDA
	case 0x1BDB
	case 0x1BDC
	case 0x1BDD
	case 0x1BDE
	case 0x1BDF
	case 0x1BE0
	case 0x1BE1
	case 0x1BE2
		if (isAtHome(usedon)) {
			systemMessage(user, "That wood belongs to someone else.");
			return(0x00);
		}
		int wood_amt;
		ret = getResource(wood_amt, usedon, "wood", 0x03, 0x02);
		if (wood_amt <= 0x00) {
			systemMessage(user, "There isn't enough wood here");
			return(0x00);
		}
		list fletching;
		clearList(fletching);
		int skill_lvl = getSkillLevelReal(user, 0x08) + 0x0190;
		for (int i = 0x00; i < 0x05; i++) {
			if (getArrayIntElem(0x01, 0x02, i) < skill_lvl) {
				if (getArrayIntElem(0x01, 0x03, i) <= wood_amt) {
					appendToList(fletching, getArrayIntElem(0x01, 0x00, i));
					string name = getArrayStrElem(0x01, 0x01, i);
					if (name != "") {
						appendToList(fletching, name);
					}
				}
			}
		}
		setObjVar(this, "usedon", usedon);
		selectType(user, this, 0x28, "Choose an item to make.", fletching);
		return(0x00);
		break;
	case 0x09CC
	case 0x09CD
	case 0x09CE
	case 0x09CF
		int res;
		if (isAtHome(usedon)) {
			systemMessage(user, "You can't prepare that fish, it belongs to someone else.");
			return(0x00);
		}
		obj fish = createNoResObjectAt(0x097A, getLocation(user));
		transferResources(fish, usedon, 0x04, "fish");
		place_in_pack_or_drop(user, fish, "You cut the fish into steaks and put them");
		destroyOne(usedon);
		return(0x00);
		break;
	}
	if (hasObjVar(usedon, "chopable")) {
		if (is_axe(this)) {
			list objs_at;
			int is_multi = 0x00;
			int can_destroy = 0x00;
			obj multi_slave;
			getObjectsAt(objs_at, getLocation(usedon));
			for (int c = 0x00; c < numInList(objs_at); c++) {
				if (isMultiComp(objs_at[c])) {
					is_multi = 0x01;
					multi_slave = getMultiSlaveId(objs_at[c]);
				}
			}
			if (is_multi) {
				if (hasObjVar(multi_slave, "myhousedoor")) {
					obj house_door = getObjVar(multi_slave, "myhousedoor");
					obj key = mobileHasObjWithListObjOfObj(user, "whatIUnlock", house_door);
					if (!(key == NULL())) {
						systemMessage(user, "Since you are the owner of the house, you can destroy the movable furniture within.");
						can_destroy = 0x01;
					} else {
						debugMessage("You didn't have a key.");
					}
				} else {
					debugMessage("Slave doesn't have myhousedoor objVar.");
				}
			} else {
				can_destroy = 0x01;
			}
			if (hasObjVar(usedon, "trapLevel")) {
				list trap_args = user, usedon;
				message(usedon, "triggerTrap", trap_args);
			}
			if (can_destroy) {
				if (isContainer(usedon)) {
					list contents;
					getcontents(contents, usedon);
					for (c = 0x00; c < numInList(contents); c++) {
						ret = teleport(contents[c], getLocation(usedon));
					}
				}
				systemMessage(user, "You destroy the item.");
				sfx(getLocation(usedon), 0x0139, 0x00);
				deleteObject(usedon);
				return(0x00);
			} else {
				systemMessage(user, "You can't destroy that while it is here.");
				return(0x00);
			}
		} else {
			systemMessage(user, "You will need an axe of some sort to destroy this.");
			return(0x00);
		}
	}
	if (obj_type2 != 0x2006) {
		ebarkTo(usedon, user, "Use this on corpses to carve away meat and hide.");
		return(0x00);
	}
	loc corpse_loc = getLocation(usedon);
	int value;
	obj resource_obj;
	int sfx_type = random(0x122A, 0x122F);
	obj sfx_obj = createNoResObjectAt(sfx_type, corpse_loc);
	attachScript(sfx_obj, "deletethis");
	callback(sfx_obj, 0x01A4, 0x1B);
	if (getResource(value, usedon, "meat", 0x03, 0x02)) {
		if (value > 0x00) {
			animate_if_alive(user, 0x20);
			resource_obj = createNoResObjectAt(0x09F1, corpse_loc);
			transferResources(resource_obj, usedon, value, "meat");
			carved = 0x01;
			if ((giveItem(user, resource_obj) == NULL()) || (!canHold(user, resource_obj))) {
				systemMessage(user, "You don't have anywhere to carry the meat.");
				ret = teleport(resource_obj, getLocation(user));
			} else {
				systemMessage(user, "You carve away some meat.");
			}
		} else {
		}
	}
	if (getResource(value, usedon, "leather", 0x03, 0x02)) {
		if (value > 0x00) {
			animate_if_alive(user, 0x20);
			resource_obj = createNoResObjectAt(random(0x1078, 0x1079), corpse_loc);
			transferResources(resource_obj, usedon, value, "leather");
			carved = 0x01;
			if ((giveItem(user, resource_obj) == NULL()) || (!canHold(user, resource_obj))) {
				systemMessage(user, "You don't have anywhere to carry the hides.");
				ret = teleport(resource_obj, getLocation(user));
			} else {
				systemMessage(user, "You skin the corpse and get the hide.");
			}
		} else {
		}
	}
	if (getResource(value, usedon, "fur", 0x03, 0x02)) {
		if (value > 0x00) {
			animate_if_alive(user, 0x20);
			resource_obj = createNoResObjectAt(random(0x11F4, 0x11FB), corpse_loc);
			transferResources(resource_obj, usedon, value, "fur");
			carved = 0x01;
			if ((giveItem(user, resource_obj) == NULL()) || (!canHold(user, resource_obj))) {
				systemMessage(user, "You don't have anywhere to carry the furs.");
				ret = teleport(resource_obj, getLocation(user));
			} else {
				systemMessage(user, "You skin the corpse and get the fur.");
			}
		} else {
		}
	}
	if (getResource(value, usedon, "feathers", 0x03, 0x02)) {
		if (value > 0x00) {
			animate_if_alive(user, 0x20);
			resource_obj = createNoResObjectAt(0x1BD1, corpse_loc);
			transferResources(resource_obj, usedon, value, "feathers");
			carved = 0x01;
			if ((giveItem(user, resource_obj) == NULL()) || (!canHold(user, resource_obj))) {
				systemMessage(user, "You don't have anywhere to carry the feathers.");
				ret = teleport(resource_obj, getLocation(user));
			} else {
				systemMessage(user, "You pluck the bird and get the feathers.");
			}
		} else {
		}
	}
	if (getResource(value, usedon, "cloth", 0x03, 0x02)) {
		if (value > 0x00) {
			animate_if_alive(user, 0x20);
			resource_obj = createNoResObjectAt(0x101F, corpse_loc);
			transferResources(resource_obj, usedon, value, "cloth");
			carved = 0x01;
			if ((giveItem(user, resource_obj) == NULL()) || (!canHold(user, resource_obj))) {
				systemMessage(user, "You don't have anywhere to carry the wool.");
				ret = teleport(resource_obj, getLocation(user));
			} else {
				systemMessage(user, "You shear the corpse and get the wool.");
			}
		} else {
		}
	}
	if (!carved) {
		ebarkTo(usedon, user, "You see nothing useful to carve from the corpse.");
	}
	return(0x00);
}

function void swing_axe(obj user) {
	animate_if_alive(user, 0x0D);
	shortCallback(this, 0x03, 0x6F);
	return();
}

trigger targetloc {
	if (getDistanceInTiles(getLocation(user), place) > 0x02) {
		systemMessage(user, "That is too far away.");
		return(0x00);
	}
	if (!isInMap(place)) {
		return(0x00);
	}
	int obj_type = getObjType(this);
	obj chunk;
	int result;
	int wood_amt;
	obj backpack = getBackpack(user);
	if (is_axe(this)) {
		if (is_tree_type(objtype)) {
			if (!isEquipped(this)) {
				systemMessage(user, "The axe must me equipped for any serious wood chopping.");
				return(0x00);
			}
			chunk = getChunkEgg(place);
			result = getResource(wood_amt, chunk, "wood", 0x03, 0x02);
			if (wood_amt > 0x09) {
				setObjVar(this, "user", user);
				setObjVar(this, "logLoc", place);
				swing_axe(user);
				return(0x00);
			} else {
				systemMessage(user, "There's not enough wood here to harvest.");
				return(0x00);
			}
		} else {
			systemMessage(user, "You can't use an axe on that.");
		}
	} else {
		if (is_tree_type(objtype)) {
			chunk = getChunkEgg(place);
			result = getResource(wood_amt, chunk, "wood", 0x03, 0x02);
			if (wood_amt > 0x00) {
				obj kindling = createNoResObjectAt(0x0DE1, getLocation(user));
				transferResources(kindling, chunk, 0x01, "wood");
				if (canHold(user, kindling)) {
					systemMessage(user, "You were able to knock some kindling off the tree and put it in your backpack.");
					result = teleport(kindling, getLocation(user));
				} else {
					systemMessage(user, "You were able to knock some kindling off the tree.");
				}
				systemMessage(user, "An axe would probably get you more wood.");
			} else {
				systemMessage(user, "There's not enough wood here to harvest.");
				return(0x00);
			}
		} else {
			systemMessage(user, "You can't use a bladed item on that.");
		}
	}
	return(0x00);
}

trigger callback(0x6F) {
	obj user = getObjVar(this, "user");
	sfx(getLocation(user), 0x013E, 0x00);
	if (getDistanceInTiles(getLocation(user), getObjVar(this, "logLoc")) <= 0x02) {
		shortCallback(this, 0x02, 0x6E);
	}
	return(0x00);
}

trigger callback(0x6E) {
	obj user = getObjVar(this, "user");
	if (random(0x00, 0x02)) {
		swing_axe(user);
		return(0x00);
	}
	loc place = getObjVar(this, "logLoc");
	removeObjVar(this, "user");
	removeObjVar(this, "logLoc");
	obj chunk_egg = getChunkEgg(place);
	int wood_amt = 0x00;
	int result = getResource(wood_amt, chunk_egg, "wood", 0x03, 0x02);
	if (wood_amt < 0x0A) {
		systemMessage(user, "You hack at the tree for a while, but fail to produce any useable wood.");
		return(0x00);
	}
	if (!testSkill(user, 0x2C)) {
		systemMessage(user, "You hack at the tree for a while, but fail to produce any useable wood.");
		returnResourcesToBank(chunk_egg, 0x0A, "wood");
		return(0x00);
	}
	obj log = createNoResObjectAt(0x1BDD, getLocation(user));
	transferResources(log, chunk_egg, 0x0A, "wood");
	place_in_pack_or_drop(user, log, "You put some logs");
	returnResourcesToBank(chunk_egg, 0x14, "wood");
	return(0x00);
}

function void swing_carve(obj user) {
	sfx(getLocation(user), 0x55, 0x00);
	animate_if_alive(user, 0x21);
	callback(this, 0x02, 0x6D);
	return();
}

trigger typeselected(0x28) {
	debugMessage("Typeselected: Fletching");
	if (listindex == 0x00) {
		removeObjVar(this, "usedon");
		return(0x00);
	}
	if (!hasObjVar(this, "usedon")) {
		return(0x00);
	}
	listindex--;
	obj usedon = getObjVar(this, "usedon");
	setObjVar(this, "arrayIndex", listindex);
	setObjVar(this, "user", user);
	setObjVar(this, "actionCount", 0x01 + (getArrayIntElem(0x01, 0x02, listindex) / 0xC8));
	string item_name = getArrayStrElem(0x01, 0x04, listindex);
	if (item_name == "") {
		item_name = getNameByType(getArrayIntElem(0x01, 0x00, listindex));
	}
	actionBark(user, 0x0602, "*You start carving " + item_name + ".*", "*" + getName(user) + " starts carving " + item_name + ".*");
	swing_carve(user);
	return(0x00);
}

function void cleanup() {
	removeObjVar(this, "usedon");
	removeObjVar(this, "arrayIndex");
	removeObjVar(this, "user");
	removeObjVar(this, "actionCount");
	return();
}

trigger callback(0x6D) {
	int actionCount = getObjVar(this, "actionCount");
	debugMessage("ActionCount=" + actionCount);
	actionCount--;
	obj user = getObjVar(this, "user");
	if (actionCount > 0x00) {
		setObjVar(this, "actionCount", actionCount);
		swing_carve(user);
		return(0x00);
	}
	obj usedon = getObjVar(this, "usedon");
	int arrayIndex = getObjVar(this, "arrayIndex");
	int wood_required = 0x00;
	int wood_amt = 0x00;
	if (isValid(usedon)) {
		obj container = getTopmostContainer(usedon);
		if ((container == NULL()) || (container == user)) {
			wood_required = getArrayIntElem(0x01, 0x03, arrayIndex);
			int res_ok = getResource(wood_amt, usedon, "wood", 0x03, 0x02);
			if (wood_amt < wood_required) {
				wood_required = 0x00;
			}
		}
	}
	if (wood_required <= 0x00) {
		actionBark(user, 0x0602, "*You can no longer find all of the wood you were working with.*", "*" + getName(user) + " has misplaced the wood he was working with.*");
		cleanup();
		return(0x00);
	}
	int item_type = getArrayIntElem(0x01, 0x00, arrayIndex);
	obj crafted = createNoResObjectAt(item_type, getLocation(user));
	string pronoun = "it";
	if (item_type == 0x1BD4) {
		wood_required = wood_amt;
		if (wood_required > 0x01) {
			pronoun = "them";
		}
	}
	transferResources(crafted, usedon, wood_required, "wood");
	if ((wood_amt - wood_required) <= 0x00) {
		deleteObject(usedon);
	}
	int success = testAndLearnSkill(user, 0x08, getArrayIntElem(0x01, 0x02, arrayIndex), 0x50);
	if (success <= 0x00) {
		actionBark(user, 0x0602, "*You carve the wood away but are left with nothing.*", "*" + getName(user) + " stops carving, but is left with nothing useful.*");
		deleteObject(crafted);
		cleanup();
		return(0x00);
	}
	place_in_pack_or_drop(user, crafted, "You make " + getName(crafted) + " and put " + pronoun);
	cleanup();
	return(0x00);
}

function int is_axe(obj weapon) {
	switch(getObjType(weapon)) {
	case 0x0F43
	case 0x0F44
	case 0x0F45
	case 0x0F46
	case 0x0F47
	case 0x0F48
	case 0x0F49
	case 0x0F4A
	case 0x0F4B
	case 0x0F4C
	case 0x0F4D
	case 0x0F4E
	case 0x13AF
	case 0x13B0
	case 0x13FA
	case 0x13FB
	case 0x143E
	case 0x143F
	case 0x1442
	case 0x1443
		return(0x01);
	}
	return(0x00);
}
