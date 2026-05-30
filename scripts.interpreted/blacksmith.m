inherits itemmanip;

forward void Q555();

forward void cleanup();

forward void craft_item();

member obj crafter;

member list recipe_indices;

function void collect_metals(list metal, obj container) {
	clearList(metal);
	for (int type_id = 0x1BEF; type_id <= 0x1BF4; type_id++) {
		getObjectsOfTypeIn(metal, container, type_id);
	}
	return();
}

function int count_metal(obj container) {
	int total = 0x00;
	list metal;
	clearList(metal);
	collect_metals(metal, container);
	for (int num = numInList(metal); num > 0x00; num--) {
		int amount;
		int result = getResource(amount, metal[0x00], "metal", 0x03, 0x02);
		total = total + amount;
		removeItem(metal, 0x00);
	}
	return(total);
}

function void transfer_metal_to_item(obj item, obj source, int amount) {
	int total;
	list metal;
	clearList(metal);
	collect_metals(metal, source);
	for (int num = numInList(metal); num > 0x00; num--) {
		int metal_qty;
		obj metal_obj = metal[0x00];
		int result = getResource(metal_qty, metal_obj, "metal", 0x03, 0x02);
		if (amount >= metal_qty) {
			transferResources(item, metal_obj, metal_qty, "metal");
			deleteObject(metal_obj);
			removeItem(metal, 0x00);
			amount = amount - metal_qty;
		} else {
			transferResources(item, metal_obj, amount, "metal");
			result = getResource(metal_qty, metal_obj, "metal", 0x03, 0x02);
			if (metal_qty < 0x01) {
				deleteObject(metal_obj);
			}
			break;
		}
	}
	clearList(metal);
	return();
}

function int can_craft(int row, int metal, int skill) {
	if (getArrayIntElem(0x00, 0x04, row) > metal) {
		return(0x00);
	}
	if (getArrayIntElem(0x00, 0x05, row) > skill) {
		return(0x00);
	}
	return(0x01);
}

function void show_craft_menu(obj user, string title) {
	list options;
	clearList(options);
	for (int i = 0x00; i < numInList(recipe_indices); i++) {
		int row = recipe_indices[i];
		append(options, getArrayIntElem(0x00, 0x00, row));
		append(options, getArrayIntElem(0x00, 0x01, row));
		append(options, getArrayStrElem(0x00, 0x02, row));
	}
	selectTypeAndHue(user, this, 0x00, title, options);
	return();
}

function int collect_recipes(int metal, int skill, int start_idx, int depth) {
	int idx = start_idx;
	while (idx < 0x3D) {
		int entry_depth = getArrayIntElem(0x00, 0x03, idx);
		if (entry_depth > depth) {
			int prev_count = numInList(recipe_indices);
			int next_idx = collect_recipes(metal, skill, idx + 0x01, depth + 0x01);
			int added_count = numInList(recipe_indices) - prev_count;
			if (added_count > 0x01) {
				truncateList(recipe_indices, prev_count);
				append(recipe_indices, idx);
			}
			idx = next_idx;
		} else {
			if ((entry_depth < depth) || (getArrayIntElem(0x00, 0x01, idx) == 0x36)) {
				break;
			}
			if (can_craft(idx, metal, skill)) {
				append(recipe_indices, idx);
			}
			idx++;
		}
	}
	return(idx);
}

function int register_item_recipes(int row, int category, list types) {
	int debug = hasObjVar(this, "debugSkillInfo");
	while (numInList(types)) {
		setArrayIntElem(0x00, 0x00, row, types[0x00]);
		setArrayIntElem(0x00, 0x03, row, category);
		obj temp_obj = createNoResObjectAt(types[0x00], getLocation(this));
		int metal_cost = 0x00;
		int result = getResource(metal_cost, temp_obj, "metal", 0x03, 0x00);
		setArrayIntElem(0x00, 0x04, row, metal_cost);
		int val;
		if (isReallyWeapon(temp_obj)) {
			val = metal_cost + (getWeaponSpeed(temp_obj) * getAverageDamage(temp_obj) / 0x0C);
		} else {
			val = metal_cost + (getMaxArmorClass(temp_obj) * 0x02);
		}
		setArrayIntElem(0x00, 0x05, row, val);
		string description = getNameByType(types[0x00]);
		toUpper(description, 0x00, 0x01);
		if (debug) {
			description = description + ". $" + val + ", " + metal_cost + " metal";
		} else {
			description = "Build " + description + ", " + metal_cost + " metal.";
		}
		setArrayStrElem(0x00, 0x02, row, description);
		deleteObject(temp_obj);
		removeItem(types, 0x00);
		row++;
	}
	return(row);
}

function void init_recipe_table() {
	if (hasObjVar(this, "debugSkillInfo")) {
		deleteArray(0x00);
	}
	if (isArrayInit(0x00)) {
		return();
	}
	list row = 0x00, 0x01, "COL_NAME", 0x03, 0x04, 0x05;
	initArray(0x00, 0x06, 0x3D, row);
	int idx = 0x00;
	row = 0x0FAF, 0x00, "Repair an Item", 0x00;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x13ED, 0x36, "Build Armor", 0x01;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x13EC, 0x36, "Build Ring Armor", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x13EB, 0x13EF, 0x13F0, 0x13EC;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x13BF, 0x36, "Build Chain Armor", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x13BB, 0x13BE, 0x13BF;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x1415, 0x36, "Build Plate Armor", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x1408, 0x36, "Build Helmets", 0x03;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x140A, 0x140C, 0x140E, 0x1408, 0x1412;
	idx = register_item_recipes(idx, 0x03, row);
	row = 0x1413, 0x1414, 0x1410, 0x1411, 0x1415, 0x1C04;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x1B74, 0x36, "Build Shields", 0x01;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x1B73, 0x1B72, 0x1B7B, 0x1B78, 0x1B74, 0x1B76;
	idx = register_item_recipes(idx, 0x01, row);
	row = 0x0F45, 0x36, "Build Weapons", 0x01;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x0F61, 0x36, "Build Blades", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x0F51, 0x1441, 0x13FF, 0x1401, 0x13B6, 0x0F5E, 0x0F61, 0x13B9;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x13FB, 0x36, "Build Axes", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x0F47, 0x0F49, 0x0F45, 0x1443, 0x0F4B, 0x13FB, 0x13B0;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x0F4D, 0x36, "Build Pole Arms", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x1403, 0x0F62, 0x1405, 0x0F4D, 0x143F;
	idx = register_item_recipes(idx, 0x02, row);
	row = 0x1407, 0x36, "Build Bludgeoning Weapons", 0x02;
	setArrayElems(0x00, 0x00, idx, row);
	idx++;
	row = 0x0F5C, 0x143B, 0x1407, 0x1439, 0x143D;
	idx = register_item_recipes(idx, 0x02, row);
	debugMessage("BlackSmithing Loaded:  Allocated Rows= " + 0x3D + " Computed Rows:" + idx);
	int min_val = 0x000F4240;
	int max_val = 0x00;
	int i;
	int val;
	int min_type;
	int max_type;
	for (i = 0x01; i < idx; i++) {
		if (getArrayIntElem(0x00, 0x01, i) != 0x36) {
			val = getArrayIntElem(0x00, 0x05, i);
			if (max_val < val) {
				max_val = val;
				max_type = getArrayIntElem(0x00, 0x00, i);
			}
			if (min_val > val) {
				min_val = val;
				min_type = getArrayIntElem(0x00, 0x00, i);
			}
		}
	}
	debugMessage("Min Value=" + min_val + " (" + min_type + ") Max Value=" + max_val + " (" + max_type + ")");
	int range = max_val - min_val;
	for (i = 0x01; i < idx; i++) {
		if (getArrayIntElem(0x00, 0x01, i) != 0x36) {
			val = getArrayIntElem(0x00, 0x05, i);
			int norm_val = (val - min_val) * 0x03E8 / range;
			setArrayIntElem(0x00, 0x05, i, norm_val);
		}
	}
	return();
}

trigger creation {
	init_recipe_table();
	return(0x01);
}

trigger objectloaded {
	init_recipe_table();
	return(0x01);
}

function int has_anvil_and_forge(obj user) {
	int has_anvil = 0x00;
	int has_forge = 0x00;
	list nearby;
	clearList(nearby);
	getObjectsInRange(nearby, getLocation(user), 0x03);
	int count = numInList(nearby);
	for (int i = 0x00; i < count; i++) {
		int obj_type = getObjType(nearby[i]);
		switch(obj_type) {
		case 0x0FAF
		case 0x0FB0
			has_anvil = 0x01;
			break;
		case 0x0FB1
			has_forge = 0x01;
			break;
		}
		if (obj_type >= 0x197A) {
			if (obj_type <= 0x19A9) {
				has_forge = 0x01;
			}
		}
	}
	if (!has_anvil) {
		string msg = "You are not near an anvil";
		if (!has_forge) {
			msg = msg + " or a forge.";
		} else {
			msg = msg + ".";
		}
		systemMessage(user, msg);
	} else {
		if (!has_forge) {
			systemMessage(user, "You are not near a forge.");
		}
	}
	return(has_anvil && has_forge);
}

trigger targetobj {
	cleanup();
	if (check_disabled(user, "The blacksmith skill", 0x00)) {
		return(0x00);
	}
	if (!has_anvil_and_forge(user)) {
		return(0x00);
	}
	if (isWeapon(usedon) && hasResource(usedon, resourceTypeToId("metal"))) {
		if (isInContainer(usedon)) {
			obj container = getTopmostContainer(usedon);
			if (isMobile(container)) {
				if (container != user) {
					systemMessage(user, "You can't work on that item.");
					return(0x00);
				}
			}
		}
		int cur_hp = getWeaponCurHP(usedon);
		int max_hp = getWeaponMaxHP(usedon);
		if ((max_hp == 0x00) || (cur_hp >= max_hp)) {
			systemMessage(user, "That is already in full repair.");
			return(0x00);
		}
		int difficulty = (max_hp - cur_hp) * 0x04E2 / max_hp - 0xFA;
		int result;
		int success = testAndLearnSkill(user, 0x07, difficulty, 0x32);
		max_hp--;
		cur_hp--;
		if (cur_hp < 0x01) {
			systemMessage(user, "You destroyed the item.");
			deleteObject(usedon);
		} else {
			if (success > 0x00) {
				cur_hp = max_hp;
				systemMessage(user, "You repair the item.");
			}
			result = setWeaponMaxHP(usedon, max_hp);
			result = setWeaponCurHP(usedon, cur_hp);
		}
		if (drain_tool_life(user, this)) {
			deleteObject(this);
		}
		return(0x00);
	}
	systemMessage(user, "You can't repair that.");
	return(0x00);
}

trigger use {
	if (check_disabled(user, "The blacksmith skill", 0x00)) {
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "That is being used by someone else.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x00);
		callBack(this, 0x3C, 0x1B);
	}
	crafter = user;
	systemMessage(user, "What would you like to do?");
	loc user_loc = getLocation(user);
	int ret;
	list recipe_list;
	int count;
	int result;
	int i;
	if (has_anvil_and_forge(user)) {
		int skill_level = getSkillLevelReal(user, 0x07);
		int metal_count = count_metal(user);
		clearList(recipe_indices);
		int end_idx = collect_recipes(metal_count, skill_level + 0xFA, 0x00, 0x00);
		show_craft_menu(user, "What would you like to do?");
	} else {
		cleanup();
	}
	return(0x00);
}

trigger typeselected(0x00) {
	if (check_disabled(user, "The blacksmith skill", 0x00)) {
		return(0x00);
	}
	removeCallback(this, 0x4A);
	if (listindex == 0x00) {
		cleanup();
		return(0x00);
	}
	listindex--;
	if (listindex >= numInList(recipe_indices)) {
		cleanup();
		return(0x00);
	}
	int recipe_idx = recipe_indices[listindex];
	if (recipe_idx == 0x00) {
		systemMessage(user, "Select item to repair.");
		targetObj(user, this);
		return(0x00);
	}
	clearList(recipe_indices);
	if (getArrayIntElem(0x00, 0x01, recipe_idx) != 0x36) {
		append(recipe_indices, recipe_idx);
		shortCallback(this, 0x01, 0x4A);
		return(0x00);
	}
	int depth = getArrayIntElem(0x00, 0x03, recipe_idx);
	int metal_count = count_metal(user);
	int skill_level = getSkillLevelReal(user, 0x07);
	int next_idx = collect_recipes(metal_count, skill_level + 0xFA, recipe_idx + 0x01, depth);
	show_craft_menu(user, getArrayStrElem(0x00, 0x02, recipe_idx));
	return(0x00);
}

trigger callback(0x1B) {
	cleanup();
	return(0x00);
}

trigger callback(0x4A) {
	int result;
	sfx(getLocation(this), 0x2A, 0x00);
	int delay = random(0x00, 0x05);
	if (delay) {
		shortCallback(this, delay, 0x4A);
	} else {
		craft_item();
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
	}
	return(0x00);
}

function void craft_item() {
	int result;
	int metal_count = count_metal(crafter);
	int recipe_index = recipe_indices[0x00];
	int required_metal = getArrayIntElem(0x00, 0x04, recipe_index);
	if (required_metal > metal_count) {
		systemMessage(crafter, "The amount of metal changed since you started smithing the ingots.");
		cleanup();
		return();
	}
	int newType = getArrayIntElem(0x00, 0x00, recipe_index);
	int success = testAndLearnSkill(crafter, 0x07, getArrayIntElem(0x00, 0x05, recipe_index), 0x32);
	obj new_item;
	if (success <= 0x00) {
		int metal_lost = required_metal * (0x00 - success) / 0x03E8 + 0x01;
		metal_count = metal_count - metal_lost;
		new_item = createNoResObjectIn(newType, crafter);
		transfer_metal_to_item(new_item, crafter, metal_lost);
		deleteObject(new_item);
		systemMessage(crafter, "You lost some metal.");
		cleanup();
		return();
	}
	new_item = createNoResObjectAt(newType, getLocation(crafter));
	transfer_metal_to_item(new_item, crafter, required_metal);
	obj backpack = getBackpack(crafter);
	if (canHold(backpack, new_item)) {
		int put_result = putObjContainer(new_item, backpack);
		systemMessage(crafter, "You create the item and put it in your backpack.");
	} else {
		systemMessage(crafter, "You create the item and put it at your feet.");
	}
	int quality_pct = 0x64;
	if (success >= 0x0258) {
		systemMessage(crafter, "Due to your exceptional skill, it's quality is higher than average.");
		quality_pct = 0x78;
	} else {
		if (success < 0x012C) {
			systemMessage(crafter, "You were barely able to make this item.  It's quality is below average.");
			quality_pct = 0x50;
		}
	}
	if (quality_pct != 0x64) {
		result = setWeaponMaxHP(new_item, getWeaponMaxHP(new_item) * quality_pct / 0x64);
		result = setWeaponCurHP(new_item, getWeaponCurHP(new_item) * quality_pct / 0x64);
		result = setMaxArmorClass(new_item, getMaxArmorClass(new_item) * quality_pct / 0x64);
		int avg_damage = getAverageDamage(new_item);
		if (avg_damage > 0x00) {
			int damage_modifier = avg_damage * (quality_pct - 0x64) / 0x64;
			adjust_weapon_class(this, 0x00, 0x00, damage_modifier, 0x00);
		}
	}
	cleanup();
	if (drain_tool_life(crafter, this)) {
		deleteObject(this);
	}
	return();
}

function void cleanup() {
	clearList(recipe_indices);
	crafter = NULL();
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return();
}
