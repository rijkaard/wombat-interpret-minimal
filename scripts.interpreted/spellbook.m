inherits spelskil;

trigger objectloaded {
	if (hasScript(this, "shipclaim")) {
		return(0x01);
	}
	list contents;
	obj player = getTopmostContainer(this);
	if (!isMobile(player)) {
		player = NULL();
	}
	getContents(contents, this);
	int num = numInList(contents);
	for (int i = 0x00; i < num; i++) {
		obj it = contents[i];
		if (!is_scroll(it)) {
			int moved = 0x00;
			if (player != NULL()) {
				moved = toMobile(it, player);
			}
			if (!moved) {
				deleteObject(it);
			}
		}
	}
	return(0x01);
}

trigger give {
	if (!is_scroll(givenobj)) {
		return(0x00);
	}
	list spells;
	getContents(spells, this);
	int count = numInList(spells);
	for (int i = 0x00; i < count; i++) {
		obj spell = spells[i];
		if (getMiscData(spell) == getMiscData(givenobj)) {
			return(0x00);
		}
	}
	obj new_spell = createGlobalObjectIn(getObjType(givenobj), this);
	destroyOne(givenobj);
	return(0x00);
}
