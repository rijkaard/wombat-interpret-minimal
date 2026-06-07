inherits sk_table;

forward void cook_item(obj user, obj ingredient, int result_type, string name);

function void cook_item_default(obj user, obj ingredient, int result_type) {
	string name = "default";
	cook_item(user, ingredient, result_type, name);
	return();
}

function int is_cooking_surface(int obj_type) {
	int result = 0x00;
	switch(obj_type) {
	case 0x0DE9
	case 0x0FAC
	case 0x0FB1
	case 0x19AA
	case 0x19BB
		result = 0x01;
		break;
	}
	if ((obj_type >= 0x0461) && (obj_type <= 0x0466)) {
		result = 0x01;
	}
	if ((obj_type >= 0x046A) && (obj_type <= 0x046F)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0475) && (obj_type <= 0x0480)) {
		result = 0x01;
	}
	if ((obj_type >= 0x092B) && (obj_type <= 0x0933)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0937) && (obj_type <= 0x0942)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0945) && (obj_type <= 0x0950)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0953) && (obj_type <= 0x095E)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0961) && (obj_type <= 0x096C)) {
		result = 0x01;
	}
	if ((obj_type >= 0x0DE3) && (obj_type <= 0x0DE8)) {
		result = 0x01;
	}
	if ((obj_type >= 0x12EE) && (obj_type <= 0x134D)) {
		result = 0x01;
	}
	if ((obj_type >= 0x197A) && (obj_type <= 0x19A9)) {
		result = 0x01;
	}
	if ((obj_type >= 0x19AB) && (obj_type <= 0x19B6)) {
		result = 0x01;
	}
	if ((obj_type >= 0x1A19) && (obj_type <= 0x1A74)) {
		result = 0x01;
	}
	if ((obj_type >= 0x5D7E) && (obj_type <= 0x5D93)) {
		result = 0x01;
	}
	if ((obj_type >= 0x343B) && (obj_type <= 0x346C)) {
		result = 0x01;
	}
	if ((obj_type >= 0x3547) && (obj_type <= 0x354C)) {
		result = 0x01;
	}
	if ((obj_type >= 0x398C) && (obj_type <= 0x399F)) {
		result = 0x01;
	}
	return(result);
}

function void cook_item(obj user, obj ingredient, int result_type, string name) {
	if (isAtHome(this)) {
		systemMessage(user, "You can't use that, it belongs to someone else.");
		return();
	}
	int item_type = getObjType(ingredient);
	if (is_cooking_surface(item_type)) {
		if (!testSkill(user, SKILL_COOKING)) {
			systemMessage(user, "You burn the food to a crisp! It's ruined.");
			destroyOne(this);
			return();
		}
		if (name != "default") {
			if (hasObjVar(this, "NAME")) {
				removeObjVar(this, "NAME");
				setObjVar(this, "NAME", name);
			}
		}
		if (random(0x00, 0x01)) {
			barkTo(user, user, "Looks delicious.");
		} else {
			barkTo(user, user, "Mmmm, smells good.");
		}
		obj backpack = getBackpack(user);
		int place_result;
		obj cooked_item = createGlobalObjectOn(this, result_type);
		if (!isInContainer(this)) {
			if (canHold(backpack, cooked_item)) {
				place_result = putObjContainer(cooked_item, backpack);
				systemMessage(user, "You put the cooked food into your backpack.");
			} else {
				place_result = teleport(cooked_item, getLocation(user));
				systemMessage(user, "You put the cooked food on the ground.");
			}
		}
		destroyOne(this);
	} else {
		systemMessage(user, "You can't cook on that.");
	}
	return();
}
