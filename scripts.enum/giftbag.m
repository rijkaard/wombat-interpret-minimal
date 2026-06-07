inherits globals;

function int random_holiday_hue() {
	int hue = 0x20;
	switch(random(0x00, 0x02)) {
	case 0x00
		hue = 0x40;
		break;
	case 0x01
		hue = 0x08FD;
		break;
	default
		break;
	}
	return(hue);
}

function obj create_gift_item(obj bag, int type_id, int hue, string lookAtText, string script) {
	obj item = requestCreateObjectIn(type_id, bag);
	if (hue) {
		setHue(item, hue);
	}
	if (lookAtText != "") {
		setObjVar(item, "lookAtText", lookAtText);
	}
	if (script != "") {
		attachScript(item, script);
	}
	setObjVar(item, "valueless", 0x01);
	return(item);
}

trigger creation {
	obj bag = requestCreateObjectIn(0x0E76, getBackpack(this));
	if (bag == NULL()) {
		return(0x00);
	}
	setHue(bag, random_holiday_hue());
	int is_nice = 0x01;
	if (!getCompileFlag(0x01)) {
		if (getNotorietyLevel(this) < 0x00) {
			is_nice = 0x00;
		}
	} else {
		if (getKarmaLevel(this) < 0x00) {
			is_nice = 0x00;
		}
	}
	obj item;
	if (is_nice) {
		setObjVar(bag, "lookAtText", "Happy Holidays!");
		item = create_gift_item(bag, 0x1086, 0x00, "a wrist watch", "clock");
		if (random(0x00, 0x01)) {
			item = create_gift_item(bag, 0x1044, 0x01B0, "fruit cake", "");
		} else {
			item = create_gift_item(bag, 0x1040, 0x00, "", "");
		}
		if (random(0x00, 0x01)) {
			item = create_gift_item(bag, 0x099B, 0x00, "", "");
			setObjVar(item, "drinkType", "champagne");
		} else {
			item = create_gift_item(bag, 0x099F, 0x00, "", "");
			setObjVar(item, "drinkType", "eggnog");
		}
		list fruit = 0x09D0, 0x09D1, 0x09D2, 0x1721, 0x1726, 0x1727, 0x172C, 0x172D;
		item = create_gift_item(bag, fruit[random(0x00, numInList(fruit) - 0x01)], 0x00, "", "");
		item = create_gift_item(bag, 0x099A, 0x47, "a champagne glass", "");
		item = create_gift_item(bag, 0x099A, 0x22, "a champagne glass", "");
		item = create_gift_item(bag, 0x0DF5, 0x00, "a fireworks wand", "sparkler");
		item = create_gift_item(bag, 0x14EF, random_holiday_hue(), "Seasons Greetings", "");
	} else {
		setObjVar(bag, "lookAtText", "You were naughty this year!");
		item = create_gift_item(bag, 0x1044, 0x00, "", "");
		item = create_gift_item(bag, 0x19B9, 0x0455, "coal", "");
		item = create_gift_item(bag, 0x0DE1, 0x00, "switches", "");
		item = create_gift_item(bag, 0x14EF, random_holiday_hue(), "Maybe next year you will get a nicer gift.", "");
	}
	return(0x00);
}
