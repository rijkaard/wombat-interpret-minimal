function void activate(obj victim) {
	loc location = getLocation(this);
	doLocAnimation(location, 0x119B, 0x0A, 0x05, 0x00, 0x00);
	list objects;
	getObjectsAt(objects, location);
	appendToList(objects, victim);
	int count = numInList(objects);
	for (int i = 0x00; i < count; i++) {
		if (isMobile(objects[i])) {
			loseHP(objects[i], 0x0A);
		}
	}
	return();
}

trigger message("activate") {
	activate(this);
	return(0x01);
}

trigger enterrange(0x00) {
	activate(target);
	return(0x01);
}
