inherits housestuff;

trigger wasgotten {
	systemMessage(getter, "That is locked down.");
	return(0x00);
}

trigger decay {
	loc where = getLocation(this);
	list nearby;
	getObjectsInRange(nearby, where, 0x01);
	int num = numInList(nearby);
	for (int i = 0x00; i < num; i++) {
		obj it = nearby[i];
		if (isMultiComp(it)) {
			return(0x00);
		}
	}
	return(0x01);
}
