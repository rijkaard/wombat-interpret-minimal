trigger use {
	list flame_types = 0x07C9, 0x07CA, 0x07CB, 0x07CC;
	list objs_at;
	loc tile_loc;
	int x_start = 0x1498;
	int y_base = 0x029B;
	int x_end = 0x149F;
	int z = 0x05;
	obj flame_obj;
	int flame_type;
	int is_clear;
	int obj_type;
	int y;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		setType(this, 0x108D);
		callback(this, 0x02, 0x01);
		for (int row = 0x00; row < 0x02; row++) {
			y = y_base + row;
			for (int i = x_start; i < (x_end + 0x01); i++) {
				tile_loc = i, y, z;
				is_clear = 0x01;
				clearList(objs_at);
				getObjectsAt(objs_at, tile_loc);
				for (int idx = 0x00; idx < numInList(objs_at); idx++) {
					obj_type = getObjType(objs_at[idx]);
					if ((obj_type == 0x07C9) || (obj_type == 0x07CA) || (obj_type == 0x07CB) || (obj_type == 0x07CC)) {
						is_clear = 0x00;
					}
				}
				if (is_clear == 0x01) {
					flame_type = flame_types[random(0x00, (numInList(flame_types) - 0x01))];
					flame_obj = createGlobalObjectAt(flame_type, tile_loc);
					attachScript(flame_obj, "flame_bridge_tile");
				}
			}
		}
	}
	return(0x00);
}

trigger callback(0x01) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	if (getObjType(this) == 0x108E) {
		setType(this, 0x108C);
	}
	if (getObjType(this) == 0x108D) {
		setType(this, 0x108E);
		callBack(this, 0x02, 0x01);
	}
	return(0x00);
}
