inherits spelskil;

member int restore_done;

trigger callback(0x71) {
	detachScript(this, "polychec");
	return(0x01);
}

function void revert_polymorph(obj it) {
	if (restore_done) {
		return();
	}
	int result;
	list stored_items;
	string tmp_str;
	int count;
	int objSlot;
	if (hasObjVar(it, "oldBodyType")) {
		setType(it, getObjVar(it, "oldBodyType"));
		removeObjVar(it, "oldBodyType");
	}
	if (hasObjVar(it, "oldHue")) {
		setHue(it, getObjVar(it, "oldHue"));
		removeObjVar(it, "oldHue");
	}
	if (hasObjListVar(it, "notMyItems")) {
		getObjListVar(stored_items, it, "notMyItems");
		removeObjVar(it, "notMyItems");
	}
	count = numInList(stored_items);
	for (int x = 0x00; x < count; x++) {
		objSlot = getObjVar(stored_items[x], "objSlot");
		removeObjVar(stored_items[x], "objSlot");
		result = equipObj(stored_items[x], it, objSlot);
	}
	shortcallback(it, 0x01, 0x71);
	restore_done = 0x01;
	return();
}

trigger death {
	revert_polymorph(this);
	return(0x01);
}

trigger callback(0x14) {
	revert_polymorph(this);
	return(0x00);
}
