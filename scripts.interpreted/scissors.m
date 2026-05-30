inherits sndfx;

function void update_look_text(obj item) {
	int ok;
	string count_str;
	string look_text;
	int count;
	ok = getResource(count, item, "cloth", 0x03, 0x02);
	if (ok) {
		count_str = count;
		look_text = count_str + " yards of cloth";
		setObjVar(item, "lookAtText", look_text);
	} else {
		ok = getResource(count, item, "leather", 0x03, 0x02);
		if (ok) {
			count_str = count;
			look_text = count_str + " yards of leather";
			setObjVar(item, "lookAtText", look_text);
		}
	}
	return();
}

trigger use {
	systemMessage(user, "What cloth should I use these scissors on?");
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int obj_type = getObjType(usedon);
	loc location = getLocation(user);
	obj bandage;
	obj backpack;
	int cloth_hue = getHue(usedon);
	int ok;
	int cloth_amt;
	switch(obj_type) {
	case 0x0F95
	case 0x0F96
	case 0x0F97
	case 0x0F98
	case 0x0F99
	case 0x0F9A
	case 0x0F9B
	case 0x0F9C
	case 0x0F9C
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
			return(0x00);
		}
		ok = getResource(cloth_amt, usedon, "cloth", 0x03, 0x02);
		if (cloth_amt > 0x00) {
			backpack = getBackpack(user);
			int roll = random(0x01, 0x02);
			if (roll == 0x01) {
				bandage = createNoResObjectIn(0x0E21, backpack);
			} else {
				bandage = createNoResObjectIn(0x0EE9, backpack);
			}
			sfx(location, 0x0248, 0x00);
			setHue(bandage, cloth_hue);
			transferResources(bandage, usedon, 0x01, "cloth");
			update_look_text(usedon);
			systemMessage(user, "You cut some cloth into a bandage, and put it in your backpack");
			if (cloth_amt == 0x01) {
				deleteObject(usedon);
			}
		} else {
			systemMessage(user, "There is no cloth left on that.");
			deleteObject(usedon);
		}
		break;
	default
		systemMessage(user, "You can't use scissors on that.");
		break;
	}
	return(0x00);
}
