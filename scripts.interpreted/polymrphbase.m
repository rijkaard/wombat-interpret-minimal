inherits sumdaem;

member int picking;

member obj m_target;

forward void apply_polymorph(obj user, int duration);

function int set_polymorph_type(obj user, int newType) {
	int success = 0x00;
	if (is_targetable_mobile(user)) {
		if (newType >= 0x00) {
			if (isRiding(user)) {
				int unride_result = unRide(user);
			}
			if (!(hasObjVar(m_target, "oldBodyType"))) {
				setObjVar(m_target, "oldBodyType", getObjType(m_target));
			}
			if (!(hasObjVar(m_target, "oldHue"))) {
				setObjVar(m_target, "oldHue", getHue(m_target));
			}
			setType(user, newType);
			setHue(user, 0x00);
			int duration = (getSkillLevel(user, 0x19) / 0x05) * 0x05;
			if (isScroll()) {
				duration = 0x3C;
			}
			apply_polymorph(user, duration);
			success = 0x01;
		}
	}
	schedule_cleanup(this);
	return(success);
}

function void cast_polymorph(obj user, int newType) {
	set_polymorph_type(user, newType);
	return();
}

trigger typeselected(0x1B) {
	if (picking == 0x00) {
		return(0x00);
	}
	picking = 0x00;
	if (listindex == 0x00) {
		return(0x00);
	}
	int newType = 0x00 - 0x01;
	switch(objtype) {
	case 0x20D8
		newType = 0x12;
		break;
	case 0x20F5
		newType = 0x1D;
		break;
	case 0x20DE
		newType = 0x23;
		break;
	case 0x20DF
		newType = 0x01;
		break;
	case 0x20E9
		newType = 0x37;
		break;
	case 0x20CD
		newType = 0x0190;
		break;
	case 0x20CE
		newType = 0x0191;
		break;
	case 0x20CF
		newType = 0xD3;
		break;
	case 0x20DB
		newType = 0xD4;
		break;
	case 0x20E1
		newType = 0xD5;
		break;
	case 0x20D1
		newType = 0xD0;
		break;
	case 0x20D3
		newType = 0x09;
		break;
	case 0x20D5
		newType = 0xD9;
		break;
	case 0x20D9
		newType = 0x04;
		break;
	case 0x20E0
		newType = 0x11;
		break;
	case 0x20E8
		newType = 0x33;
		break;
	case 0x20EA
		newType = 0xE1;
		break;
	case 0x2119
		newType = 0xD6;
		break;
	default
		systemMessage(user, "Unknown body type");
		break;
	}
	cast_polymorph(m_target, newType);
	return(0x00);
}

function void select_polymorph_form(obj user) {
	list monsters = 0x20CF, "Bear, Black", 0x20DB, "Bear, Grizzly", 0x20E1, "Bear, Polar", 0x20D1, "Chicken", 0x20D3, "Daemon", 0x20D5, "Dog", 0x20D8, "Ettin", 0x20D9, "Gargoyle", 0x20F5, "Gorilla", 0x20CD, "Human, Male", 0x20CE, "Human, Female", 0x20DE, "Lizard Man", 0x20DF, "Ogre", 0x20E0, "Orc", 0x2119, "Panther", 0x20E8, "Slime", 0x20E9, "Troll", 0x20EA, "Wolf";
	m_target = user;
	picking = 0x01;
	selectType(user, this, 0x1B, "Choose a Creature", monsters);
	return();
}

function void apply_polymorph(obj user, int duration) {
	obj item;
	obj local_target;
	list removed_items;
	int success;
	if (hasScript(m_target, "remincognito")) {
		list f_args;
		message(m_target, "undoincognito", f_args);
	}
	for (int x = 0x01; x < 0x11; x++) {
		item = getItemAtSlot(m_target, x);
		if (isValid(item)) {
			debugMessage("removing items");
			success = putObjContainer(item, m_target);
			appendToList(removed_items, item);
			setObjVar(item, "objSlot", x);
			if (!success) {
				debugMessage("item stacker error");
			}
		}
	}
	setObjVar(user, "notMyItems", removed_items);
	attachScript(user, "polychec");
	callback(user, duration, 0x14)return();
}
