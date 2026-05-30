inherits sk_table;

function void append_list_as_natural_sentence(string sentence, list items) {
	int count;
	int num = numInList(items);
	for (count = 0x00; count < num; count++) {
		string item = items[count];
		if (count == (num - 0x01)) {
			sentence = sentence + item;
		}
		if (count == (num - 0x02)) {
			sentence = sentence + item + " and ";
		}
		if (count < (num - 0x02)) {
			sentence = sentence + item + ", ";
		}
	}
	return();
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "animlore");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "What animal should I look at?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isMobile(usedon)) {
		barkTo(this, this, "That's not an animal!");
		return(0x00);
	}
	if (isHuman(usedon)) {
		barkTo(this, this, "That's not an animal!");
		return(0x00);
	}
	loc my_loc = getLocation(this);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(my_loc, there) > 0x10) {
		barkTo(usedon, this, "I am too far away to do that.");
		return(0x00);
	}
	int skill_result = testSkillReal(this, 0x02);
	if (skill_result <= 0x00) {
		barkTo(usedon, this, "You can't think of anything you know offhand.");
		return(0x00);
	}
	int animal_type = getObjType(usedon);
	string name;
	name = getName(usedon);
	int res;
	int count;
	list food_res;
	list habitat_res;
	list product_res;
	list affinity_res;
	string res_key;
	string res_name;
	string extra_str;
	string desc;
	string spare_str;
	res = getResourcesOnObj(usedon, 0x01, habitat_res);
	removeSpecificItem(habitat_res, "spookiness");
	int habitat_count = numInList(habitat_res);
	for (count = 0x00; count < habitat_count; count++) {
		res_key = habitat_res[count];
		res_name = getResourceName(res_key, 0x01);
		setItem(habitat_res, res_name, count);
	}
	toUpper(name, 0x00, 0x01);
	desc = name + " lives in ";
	append_list_as_natural_sentence(desc, habitat_res);
	res = getResourcesOnObj(usedon, 0x00, food_res);
	removeSpecificItem(food_res, "spookiness");
	removeSpecificItem(food_res, "jungle");
	int food_count = numInList(food_res);
	for (count = 0x00; count < food_count; count++) {
		res_key = food_res[count];
		res_name = getResourceName(res_key, 0x00);
		setItem(food_res, res_name, count);
	}
	desc = desc + " and eats ";
	append_list_as_natural_sentence(desc, food_res);
	desc = desc + ".  ";
	res = getResourcesOnObj(usedon, 0x03, product_res);
	removeSpecificItem(product_res, "carnivoremeat");
	removeSpecificItem(product_res, "meat");
	removeSpecificItem(product_res, "spookiness");
	removeSpecificItem(product_res, "good");
	removeSpecificItem(product_res, "neutral");
	removeSpecificItem(product_res, "evil");
	removeSpecificItem(product_res, "orccamp");
	removeSpecificItem(product_res, "magic");
	int product_count = numInList(product_res);
	for (count = 0x00; count < product_count; count++) {
		res_key = product_res[count];
		res_name = getResourceName(res_key, 0x03);
		if (res_name == "cloth") {
			res_name = "wool";
		}
		if (res_name == "ridable") {
			res_name = "ability to carry";
		}
		if (res_name == "leather") {
			res_name = "hide");
		}
		setItem(product_res, res_name, count);
	}
	if (product_count > 0x00) {
		desc = desc + "They are sometimes used for their ";
		append_list_as_natural_sentence(desc, product_res);
		desc = desc + ".  ";
	}
	res = getResourcesOnObj(usedon, 0x02, affinity_res);
	int affinity_count = numInList(affinity_res);
	for (count = 0x00; count < affinity_count; count++) {
		res_key = affinity_res[count];
		res_name = getResourceName(res_key, 0x02);
		setItem(product_res, res_name, count);
	}
	for (count = 0x00; count < affinity_count; count++) {
		list near_list;
		list avoid_list;
		string affinity_key = affinity_res[count];
		int affinity_val;
		res = getResource(affinity_val, usedon, affinity_key, 0x02, 0x01);
		if (affinity_val < 0x00) {
			if (!(affinity_key == "danger")) {
				if (affinity_key == "meat") {
					appendToList(avoid_list, "carnivores");
				} else {
					appendToList(avoid_list, affinity_key);
				}
			}
		}
		if (affinity_val > 0x00) {
			if (affinity_key == "self") {
				appendToList(near_list, "others of their kind");
			} else {
				appendToList(near_list, affinity_key);
			}
		}
	}
	int near_count = numInList(near_list);
	if (near_count > 0x00) {
		desc = desc + "They are usually found near ";
		append_list_as_natural_sentence(desc, near_list);
	}
	int avoid_count = numInList(avoid_list);
	if (avoid_count > 0x00) {
		if (near_count > 0x00) {
			desc = desc + " but they will tend to avoid ";
		} else {
			desc = desc + "They will avoid ";
		}
		append_list_as_natural_sentence(desc, avoid_list);
	}
	string hunger_str;
	int hunger = getHungerLevel(usedon);
	if (!hasHome(usedon)) {
		desc = desc + "This one has the worn-down look of a creature that lacks a lair or home to call its own. ";
	} else {
		int home_dist = getDistanceInTiles(getHome(usedon), getLocation(usedon));
		if (home_dist < 0x10) {
			desc = desc + "This appears to be its home. ";
		} else {
			if (home_dist > 0x46) {
				desc = desc + "It seems to be far from its normal home. ";
			} else {
				desc = desc + "Its home is probably nearby. ";
			}
		}
	}
	hunger = hunger / 0x0A;
	switch(hunger) {
	case 0x00
		hunger_str = "like it is starving.";
		break;
	case 0x01
		hunger_str = "near starving.";
		break;
	case 0x02
		hunger_str = "pretty hungry.";
		break;
	case 0x03
		hunger_str = "hungry.";
		break;
	case 0x04
	case 0x05
	case 0x06
		hunger_str = "moderately well-fed.";
		break;
	case 0x07
		hunger_str = "well-fed.";
		break;
	case 0x08
		hunger_str = "plump.";
		break;
	case 0x09
		hunger_str = "like it gets plenty to eat.";
		break;
	case 0x0A
		hunger_str = "replete, as if it has just eaten.";
		break;
	default
		hunger_str = "moderately well-fed.";
		break;
	}
	if (!hasObjListVar(usedon, "myBoss")) {
		desc = desc + "It looks " + hunger_str;
	}
	barkTo(this, this, desc);
	setObjVar(usedon, "askedMyLoyalty", this);
	shortCallback(usedon, 0x01, 0x43);
	return(0x00);
}
