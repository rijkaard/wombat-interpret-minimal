inherits itemmanip;

forward void burn_out();

forward void toggle_light(obj user);

function int init_light_state() {
	int type = getObjType(this);
	switch(type) {
	case 0x0A28
	case 0x0F64
	case 0x0F6B
		setObjVar(this, "burning", 0x00);
		break;
	case 0x0A18
	case 0x0A1D
	case 0x0A25
		setObjVar(this, "fuel", 0x64);
		setObjVar(this, "burning", 0x00);
		break;
	case 0x0B1A
	case 0x0A0F
	case 0x0A15
	case 0x0A1A
	case 0x0A22
	case 0x0A12
		setObjVar(this, "fuel", 0x64);
		setObjVar(this, "burning", 0x01);
		callback(this, 0x1E, 0x39);
		break;
	case 0x0A26
	case 0x0A27
	case 0x0A29
	case 0x1853
	case 0x1857
	case 0x1849
	case 0x184D
		setObjVar(this, "burning", 0x00);
		break;
	case 0x0B1A
	case 0x0B1D
	case 0x0B26
	case 0x1854
	case 0x1858
	case 0x184A
	case 0x184E
		setObjVar(this, "burning", 0x01);
		break;
	}
	return(0x01);
}

function int ignite(obj user) {
	int obj_type = getObjType(this);
	if (hasObjVar(this, "fuel")) {
		int fuel = getObjVar(this, "fuel");
	}
	switch(obj_type) {
	case 0x0A26
		setObjVar(this, "burning", 0x01);
		setType(this, 0x0B1A);
		break;
	case 0x0A27
		setObjVar(this, "burning", 0x01);
		setType(this, 0x0B1D);
		break;
	case 0x0A29
		setObjVar(this, "burning", 0x01);
		setType(this, 0x0B26);
		break;
	case 0x1853
		setObjVar(this, "burning", 0x01);
		setType(this, 0x1854);
		break;
	case 0x1857
		setObjVar(this, "burning", 0x01);
		setType(this, 0x1858);
		break;
	case 0x1849
		setObjVar(this, "burning", 0x01);
		setType(this, 0x184A);
		break;
	case 0x184D
		setObjVar(this, "burning", 0x01);
		setType(this, 0x184E);
		break;
	case 0x0A28
		int result;
		obj backpack = getBackpack(user);
		obj lit_candle = requestCreateObjectAt(0x0A0F, getLocation(user));
		setObjVar(this, "fuel", 0x64);
		setObjVar(lit_candle, "burning", 0x01);
		attachscript(lit_candle, "torch");
		callback(lit_candle, 0x1E, 0x39);
		if (!isInContainer(this)) {
			result = teleport(lit_candle, getLocation(this));
			if (getQuantity(this) > 0x01) {
				destroyOne(this);
				if (canHold(backpack, this)) {
					systemMessage(user, "You put the remaining unlit candles into your backpack.");
					result = putObjContainer(this, backpack);
				} else {
					systemMessage(user, "You put the remaining unlit candles at your feet.");
					result = teleport(this, getLocation(user));
				}
			}
		} else {
			destroyOne(this);
			if (getItemAtSlot(user, 0x02) != NULL()) {
				systemMessage(user, "You cannot hold the candle, so it has been placed at your feet.");
			} else {
				result = equipObj(lit_candle, user, 0x02);
				systemMessage(user, "You put the candle in your left hand.");
			}
		}
		if (getQuantity(this) == 0x01) {
			destroyOne(this);
		}
		break;
	case 0x0F64
	case 0x0F6B
		backpack = getBackpack(user);
		obj lit_torch = requestCreateObjectAt(0x0A12, getLocation(user));
		setObjVar(this, "fuel", 0x64);
		setObjVar(lit_torch, "burning", 0x01);
		attachscript(lit_torch, "torch");
		callback(lit_torch, 0x1E, 0x39);
		if (!isInContainer(this)) {
			result = teleport(lit_torch, getLocation(this));
			if (getQuantity(this) > 0x01) {
				destroyOne(this);
				if (canHold(backpack, this)) {
					systemMessage(user, "You put the remaining unlit torches into your backpack.");
					result = putObjContainer(this, backpack);
				} else {
					systemMessage(user, "You put the remaining unlit torches at your feet.");
					result = teleport(this, getLocation(user));
				}
			}
		} else {
			destroyOne(this);
			if (getItemAtSlot(user, 0x02) != NULL()) {
				systemMessage(user, "You cannot hold the torch, so it has been placed at your feet.");
			} else {
				result = equipObj(lit_torch, user, 0x02);
				systemMessage(user, "You put the torch in your left hand.");
			}
		}
		if (getQuantity(this) == 0x01) {
			destroyOne(this);
		}
		break;
	case 0x0A18
	case 0x0A1D
	case 0x0A25
		if (fuel > 0x00) {
			setObjVar(this, "burning", 0x01);
			callback(this, 0x1E, 0x39);
			setType(this, obj_type - 0x03);
		} else {
			systemMessage(user, "The lantern is out of fuel.");
		}
		break;
	default
		return(0x00);
		break;
	}
	sfx(getLocation(this), 0x47, 0x00);
	return(0x01);
}

function int douse(obj user) {
	int obj_type = getObjType(this);
	if (hasObjVar(this, "fuel")) {
		int fuel = getObjVar(this, "fuel");
	}
	switch(obj_type) {
	case 0x0B1A
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A26);
		break;
	case 0x0B1D
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A27);
		break;
	case 0x0B26
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A29);
		break;
	case 0x1854
		setObjVar(this, "burning", 0x00);
		setType(this, 0x1853);
		break;
	case 0x1858
		setObjVar(this, "burning", 0x00);
		setType(this, 0x1857);
		break;
	case 0x184A
		setObjVar(this, "burning", 0x00);
		setType(this, 0x1849);
		break;
	case 0x184E
		setObjVar(this, "burning", 0x00);
		setType(this, 0x184D);
		break;
	case 0x0A0F
		systemMessage(user, "You blow out the candle, and discard it.");
		destroyOne(this);
		break;
	case 0x0A12
		systemMessage(user, "You douse the torch, and discard it.");
		destroyOne(this);
		break;
	case 0x0A15
	case 0x0A1A
	case 0x0A22
		setObjVar(this, "burning", 0x00);
		setType(this, obj_type + 0x03);
		break;
	default
		return(0x00);
		break;
	}
	sfx(getLocation(this), 0x47, 0x00);
	return(0x01);
}

function void toggle_light(obj user) {
	if (!ignite(user)) {
		int result = douse(user);
	}
	return();
}

function void burn_out() {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x0A0F
	case 0x0A28
	case 0x0A12
		deleteObject(this);
	case 0x0A15
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A18);
		break;
	case 0x0A1A
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A1D);
		break;
	case 0x0A22
		setObjVar(this, "burning", 0x00);
		setType(this, 0x0A25);
		break;
	}
	return();
}

trigger creation {
	return(init_light_state());
}

trigger use {
	toggle_light(user);
	return(0x01);
}

trigger callback(0x39) {
	int burning = getObjVar(this, "burning");
	if (burning == 0x01) {
		int fuel = getObjVar(this, "fuel");
		setObjVar(this, "fuel", fuel - 0x01);
		if (fuel - 0x01 > 0x00) {
			callback(this, 0x1E, 0x39);
		} else {
			burn_out();
		}
	}
	return(0x01);
}

trigger wasdropped {
	int item_type = getObjType(this);
	int result;
	obj container;
	int burning = getObjVar(this, "burning");
	if (burning == 0x01) {
		container = containedBy(this);
		obj slot_item;
		if (container != NULL()) {
			slot_item = getItemAtSlot(dropper, 0x01);
			if (slot_item == this) {
				return(0x01);
			}
			slot_item = getItemAtSlot(dropper, 0x02);
			if (slot_item == this) {
				return(0x01);
			}
			toggle_light(dropper);
		}
	}
	return(0x01);
}

trigger message("ignite") {
	obj user_obj = args[0x00];
	int result = ignite(user_obj);
	return(0x00);
}

trigger message("douse") {
	obj user_obj = args[0x00];
	int result = douse(user_obj);
	return(0x00);
}

trigger message("toggle") {
	obj user_obj = args[0x00];
	toggle_light(user_obj);
	return(0x00);
}
