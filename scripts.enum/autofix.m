inherits sk_table;

trigger creation {
	callback(this, 0x0F, 0x77);
	return(0x01);
}

trigger callback(0x77) {
	list where;
	appendToList(where, NULL());
	list equipped;
	int ret;
	for (int slot = 0x01; slot < 0x1A; slot++) {
		obj it = getItemAtSlot(this, slot);
		appendToList(where, it);
		if (it != NULL()) {
			ret = putObjContainer(it, this);
		}
	}
	list f_args;
	message(this, "cancelmagic", f_args);
	for (int stat = 0x00; stat < 0x03; stat++) {
		ret = setStatMod(this, stat, 0x00);
	}
	int i;
	for (i = 0x00; i < 0x2E; i++) {
		ret = setSkillMod(this, i, 0x00);
	}
	int num = numInList(where);
	for (int m = 0x00; m < num; m++) {
		obj item = where[m];
		if (item != NULL()) {
			ret = equipObj(item, this, m);
		}
	}
	return(0x01);
}
