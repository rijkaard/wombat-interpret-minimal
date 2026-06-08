inherits spelskil;

member list potion_list;

member list reagent_data;

member int reagent_type;

member int grind_count;

member obj alchemist;

function int is_vowel(string ch) {
	if ((ch == "a") || (ch == "A") || (ch == "e") || (ch == "E") || (ch == "i") || (ch == "I") || (ch == "o") || (ch == "O") || (ch == "u") || (ch == "U")) {
		return(0x01);
	}
	return(0x00);
}

function void fill_bottle(obj bottle, obj user) {
	int result;
	grind_count = 0x00;
	obj backpack = getBackpack(user);
	int potion_type = potion_list[0x00];
	string potion_name = potion_list[0x01];
	string article;
	if (is_vowel(potion_name[0x00])) {
		article = "an ";
	} else {
		article = "a ";
	}
	concat(article, potion_name);
	concat(article, " potion");
	obj potion = createGlobalObjectOn(bottle, potion_type);
	if ((getQuantity(bottle) > 0x01) && (!isInContainer(bottle))) {
		if (canHold(backpack, bottle)) {
			result = putObjContainer(bottle, backpack);
			systemMessage(user, "You put the remaining empty bottles in to your backpack.");
		} else {
			result = teleport(bottle, getLocation(user));
			systemMessage(user, "You put the remaining empty bottles at your feet.");
		}
	}
	int power = reagent_data[0x02];
	setObjVar(potion, "power", power);
	set_look_text(potion, article);
	string script_name = reagent_data[0x03];
	if (script_name == "") {
		script_name = potion_type;
	}
	attachScript(potion, script_name);
	destroyOne(bottle);
	return();
}

function void consume_reagent_and_start_grinding() {
	int required_qty = reagent_data[0x00];
	if (required_qty > getGeneric(alchemist, reagent_type)) {
		systemMessage(alchemist, "You ran out of " + getNameByType(reagent_type) + ".");
		alchemist = NULL();
		return();
	}
	destroyGeneric(alchemist, reagent_type, required_qty);
	actionBark(alchemist, 0x22, "*You start grinding some " + getNameByType(reagent_type) + " in the mortar.*", "*" + getName(alchemist) + " starts grinding some " + getNameByType(reagent_type) + " in a mortar.*");
	sfx(getLocation(alchemist), 0x0242, 0x00);
	shortCallback(this, 0x0B, 0x5A);
	return();
}

trigger callback(0x5A) {
	grind_count++;
	if (grind_count < 0x03) {
		systemMessage(alchemist, "*You continue grinding.*");
		sfx(getLocation(alchemist), 0x42, 0x00);
		shortCallback(this, 0x0B, 0x5A);
		return(0x00);
	}
	int success = testAndLearnSkill(alchemist, SKILL_ALCHEMY, reagent_data[0x01], 0x32);
	if (success > 0x00) {
		obj bottle = mobileContainsObjType(alchemist, 0x0F0E);
		if (bottle == NULL()) {
			scriptTrig(this, 0x17, alchemist);
		} else {
			actionBark(alchemist, 0x22, "*You pour the completed potion into a bottle.*", "*" + getName(alchemist) + " pours the completed potion into a bottle.*");
			fill_bottle(bottle, alchemist);
			sfx(getLocation(alchemist), 0x0240, 0x00);
			grind_count = 0x00;
		}
	} else {
		actionBark(alchemist, 0x22, "*You toss the failed mixture from the mortar, unable to create a potion from it.*", "*" + getName(alchemist) + " tosses out the contents of the mortar.*");
		grind_count = 0x00;
	}
	alchemist = NULL();
	return(0x00);
}

trigger use {
	if (grind_count == 0x03) {
		obj bottle = mobileContainsObjType(user, 0x0F0E);
		if (bottle == NULL()) {
			systemMessage(user, "Where is an empty bottle for your potion?");
			targetObj(user, this);
		} else {
			actionBark(user, 0x22, "*You pour the mixture into an empty bottle.*", "* " + getName(user) + " pours the mixture into an empty bottle.*");
			fill_bottle(bottle, user);
		}
		return(0x00);
	}
	if (alchemist != NULL()) {
		if (alchemist == user) {
			actionBark(alchemist, 0x22, "*You stop mixing and empty the mortar.*", "*" + getName(alchemist) + " stops mixing and empties the mortar.*");
			grind_count = 0x00;
			alchemist = NULL();
			removeCallback(this, 0x5A);
			return(0x00);
		}
		systemMessage(user, "Someone else is using that.");
		return(0x00);
	}
	systemMessage(user, "What reagent would you like to make the potion out of?");
	targetObj(user, this);
	return(0x00);
}

trigger typeselected(0x2B) {
	if (listindex == 0x00) {
		return(0x00);
	}
	listindex--;
	int potion_type = potion_list[(listindex * 0x02)];
	string name = potion_list[(listindex * 0x02 + 0x01)];
	clearList(potion_list);
	potion_list = potion_type, name;
	int reagent_qty = reagent_data[(listindex * 0x04)];
	int skill_param = reagent_data[(listindex * 0x04 + 0x01)];
	int power = reagent_data[(listindex * 0x04 + 0x02)];
	string script_name = reagent_data[(listindex * 0x04 + 0x03)];
	clearList(reagent_data);
	reagent_data = reagent_qty, skill_param, power, script_name;
	alchemist = user;
	consume_reagent_and_start_grinding();
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(user), getLocation(usedon)) > 0x02) {
		systemMessage(user, "You are too far away to do that.");
		return(0x00);
	}
	if (grind_count < 0x03) {
		if (isMobile(usedon)) {
			systemMessage(user, "That's not something you can grind with a mortar and pestle!");
			return(0x00);
		}
		if ((usedon == this) && (numInList(potion_list) > 0x00)) {
			alchemist = user;
			consume_reagent_and_start_grinding();
			return(0x00);
		}
		reagent_type = getObjType(usedon);
		int potion_type = 0x00;
		clearList(potion_list);
		switch(reagent_type) {
		case 0x0F7A
			potion_list = 0x0F0B, "Refresh", 0x0F0B, "Total Refreshment";
			reagent_data = 0x01, 0x00, 0xFA, "", 0x05, 0x01F4, 0x03E8, "";
			break;
		case 0x0F7B
			potion_list = 0x0F08, "Agility", 0x0F08, "Greater Agility";
			reagent_data = 0x01, 0x0190, 0x0A, "", 0x03, 0x0258, 0x14, "";
			break;
		case 0x0F8D
			potion_list = 0x0F06, "Nightsight";
			reagent_data = 0x01, 0x00, 0x00, "";
			break;
		case 0x0F85
			potion_list = 0x0F0C, "Lesser Heal", 0x0F0C, "Heal", 0x0F0C, "Greater Heal";
			reagent_data = 0x01, 0x00, 0x64, "", 0x03, 0x0190, 0xC8, "", 0x07, 0x0320, 0x012C, "";
			break;
		case 0x0F86
			potion_list = 0x0F09, "Strength", 0x0F09, "Greater Strength";
			reagent_data = 0x02, 0x01F4, 0x0A, "", 0x05, 0x02BC, 0x14, "";
			break;
		case 0x0F88
			potion_list = 0x0F0A, "Lesser Poison", 0x0F0A, "Poison", 0x0F0A, "Greater Poison", 0x0F0A, "Deadly Poison";
			reagent_data = 0x01, 0xC8, 0x01, "", 0x02, 0x0190, 0x02, "", 0x04, 0x0320, 0x03, "", 0x08, 0x047E, 0x04, "";
			break;
		case 0x0F84
			potion_list = 0x0F07, "Lesser Cure", 0x0F07, "Cure", 0x0F07, "Greater Cure";
			reagent_data = 0x01, 0x96, 0x2D, "", 0x03, 0x01F4, 0x4B, "", 0x06, 0x0384, 0x64, "";
			break;
		case 0x0F8C
			potion_list = 0x0F0D, "Lesser Explosion", 0x0F0D, "Explosion", 0x0F0D, "Greater Explosion";
			reagent_data = 0x03, 0x012C, 0x0A, "", 0x05, 0x0258, 0x14, "", 0x0A, 0x0384, 0x28, "";
			break;
		default
			systemMessage(user, "That is not a magic reagent.");
			return(0x00);
		}
		int num_options = numInList(potion_list) / 0x02;
		int below_min = 0x00;
		for (int i = 0x00; i < num_options;) {
			int remove = 0x00;
			int min_reagent = reagent_data[(i * 0x04)];
			if (min_reagent > getGeneric(user, reagent_type)) {
				remove = 0x01;
				if (i == 0x00) {
					below_min = 0x01;
				}
			}
			int min_skill = reagent_data[(i * 0x04 + 0x01)];
			if (getSkillSuccessChance(user, SKILL_ALCHEMY, min_skill, 0x32) <= 0x00) {
				remove = 0x01;
			}
			if (remove) {
				removeItem(potion_list, i * 0x02);
				removeItem(potion_list, i * 0x02);
				removeItem(reagent_data, i * 0x04);
				removeItem(reagent_data, i * 0x04);
				removeItem(reagent_data, i * 0x04);
				removeItem(reagent_data, i * 0x04);
				num_options--;
			} else {
				i++;
			}
		}
		if (num_options == 0x00) {
			if (below_min) {
				systemMessage(user, "The weakest " + getNameByType(reagent_type) + " potion requires more than you have.");
			} else {
				systemMessage(user, "You are not good enough to make anything out of that.");
			}
			return(0x00);
		}
		if (num_options == 0x01) {
			alchemist = user;
			consume_reagent_and_start_grinding();
			return(0x00);
		}
		selectType(user, this, 0x2B, "Choose a formula.", potion_list);
		return(0x00);
	} else {
		if (getObjType(usedon) == 0x0F0E) {
			actionBark(user, 0x22, "*You pour the completed potion into the bottle.*", "*" + getName(user) + " pours the completed potion into a bottle.*");
			fill_bottle(usedon, user);
		} else {
			systemMessage(user, "That is not an empty bottle.");
		}
	}
	return(0x00);
}
