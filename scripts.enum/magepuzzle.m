inherits sndfx;

member obj subject;

member loc portcullis_loc_1;

member loc portcullis_loc_2;

member loc earth_loc;

member loc fire_loc;

member loc wind_loc;

member loc water_loc;

member obj earth_marker;

member obj fire_marker;

member obj wind_marker;

member obj water_marker;

forward int check_elements_placed();

forward void open_portcullis();

forward void spawn_daemon();

trigger speech("Relvinian") {
	list mobs;
	setObjVar(speaker, "spokeName", 0x01);
	getMobsAt(mobs, getLocation(this));
	for (int i = 0x00; i < numInList(mobs); i++) {
		if (hasObjVar(mobs[i], "spokeName")) {
			removeObjVar(mobs[i], "spokeName");
			subject = mobs[i];
			callback(this, 0x01, 0x2F);
			return(0x00);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeName");
	}
	return(0x00);
}

trigger speech("relvinian") {
	list mobs;
	setObjVar(speaker, "spokeName", 0x01);
	getMobsAt(mobs, getLocation(this));
	for (int i = 0x00; i < numInList(mobs); i++) {
		if (hasObjVar(mobs[i], "spokeName")) {
			removeObjVar(mobs[i], "spokeName");
			subject = mobs[i];
			callback(this, 0x01, 0x2F);
			return(0x00);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeName");
	}
	return(0x00);
}

trigger speech("RELVINIAN") {
	list mobs_at_loc;
	setObjVar(speaker, "spokeName", 0x01);
	getMobsAt(mobs_at_loc, getLocation(this));
	for (int i = 0x00; i < numInList(mobs_at_loc); i++) {
		if (hasObjVar(mobs_at_loc[i], "spokeName")) {
			removeObjVar(mobs_at_loc[i], "spokeName");
			subject = mobs_at_loc[i];
			callback(this, 0x01, 0x2F);
			return(0x00);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeName");
	}
	return(0x00);
}

trigger callback(0x2F) {
	if (check_elements_placed() == 0x01) {
		open_portcullis();
	} else {
		spawn_daemon();
	}
	return(0x00);
}

function int check_elements_placed() {
	list objects;
	int success = 0x00;
	int obj_type;
	earth_loc = 0x0470, 0x08B6, 0x14;
	fire_loc = 0x046D, 0x08B9, 0x14;
	wind_loc = 0x046A, 0x08B6, 0x14;
	water_loc = 0x046D, 0x08B3, 0x14;
	getObjectsAt(objects, earth_loc);
	for (int i = 0x00; i < numInList(objects); i++) {
		obj_type = getObjType(objects[i]);
		if (obj_type == 0x0F0E) {
			obj earth = objects[i];
			success++;
		}
	}
	clearList(objects);
	getObjectsAt(objects, fire_loc);
	for (i = 0x00; i < numInList(objects); i++) {
		obj_type = getObjType(objects[i]);
		if (obj_type == 0x1F2B) {
			obj fire = objects[i];
			success++;
		}
	}
	getObjectsAt(objects, wind_loc);
	for (i = 0x00; i < numInList(objects); i++) {
		obj_type = getObjType(objects[i]);
		if (obj_type == 0x19B8) {
			obj wind = objects[i];
			success++;
		}
	}
	clearList(objects);
	getObjectsAt(objects, water_loc);
	for (i = 0x00; i < numInList(objects); i++) {
		obj_type = getObjType(objects[i]);
		if (obj_type == 0x0FFA) {
			obj water = objects[i];
			success++;
		}
	}
	if (success >= 0x04) {
		deleteObject(earth);
		earth_marker = createGlobalObjectAt(0x1ECD, earth_loc);
		deleteObject(fire);
		fire_marker = createGlobalObjectAt(0x1ECD, fire_loc);
		deleteObject(wind);
		wind_marker = createGlobalObjectAt(0x1ECD, wind_loc);
		deleteObject(water);
		water_marker = createGlobalObjectAt(0x1ECD, water_loc);
		return(0x01);
	}
	return(0x00);
}

function void open_portcullis() {
	list portcullis;
	portcullis_loc_1 = 0x33, 0x46, 0x00;
	portcullis_loc_2 = 0x33, 0x45, 0x00;
	getObjectsAt(portcullis, portcullis_loc_1);
	for (int i = 0x00; i < numInList(portcullis); i++) {
		int obj_type = getObjType(portcullis[i]);
		if (obj_type == 0x06F6) {
			deleteObject(portcullis[i]);
		}
	}
	clearList(portcullis);
	getObjectsAt(portcullis, portcullis_loc_2);
	for (i = 0x00; i < numInList(portcullis); i++) {
		obj_type = getObjType(portcullis[i]);
		if (obj_type == 0x06F6) {
			deleteObject(portcullis[i]);
		}
	}
	callback(this, 0x012C, 0x1B);
	return();
}

trigger callback(0x1B) {
	obj portcullis_1 = createGlobalObjectAt(0x06F6, portcullis_loc_1);
	obj portcullis_2 = createGlobalObjectAt(0x06F6, portcullis_loc_2);
	deleteObject(earth_marker);
	deleteObject(fire_marker);
	deleteObject(wind_marker);
	deleteObject(water_marker);
	return(0x00);
}

function void spawn_daemon() {
	int delay;
	loc spawn_loc = 0x2E, 0x4D, 0x00;
	doLocAnimation(spawn_loc, 0x3728, 0x08, 0x14, 0x00, 0x00);
	obj daemon = createGlobalNPCAt(0x022F, spawn_loc, 0x00);
	sfx(spawn_loc, 0x0216, 0x00);
	setType(daemon, 0x0A);
	attachScript(daemon, "destcrea");
	delay = 0x0384;
	callback(daemon, delay, 0x08);
	doDamage(subject, daemon, 0x00);
	return();
}
