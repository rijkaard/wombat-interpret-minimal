trigger speech("*") {
	if (speaker != this) {
		return(0x01);
	}
	if (!isEditing(this)) {
		return(0x01);
	}
	list parts;
	split(parts, arg);
	if (numInList(parts) != 0x04) {
		barkTo(this, this, "say 'x1 y1 x2 y2' to use this");
		return(0x00);
	}
	string x1_str = parts[0x00];
	string y1_str = parts[0x01];
	string x2_str = parts[0x02];
	string y2_str = parts[0x03];
	int x1 = x1_str;
	int y1 = y1_str;
	int x2 = x2_str;
	int y2 = y2_str;
	loc where;
	list objs;
	int count = 0x00;
	for (int y = y1; y <= y2; y++) {
		setY(where, y);
		for (int x = x1; x <= x2; x++) {
			setX(where, x);
			getObjectsAtInZRange(objs, where, 0x00 - 0x80, 0x7F);
			int n = numInList(objs);
			for (int i = 0x00; i < n; i++) {
				obj target_obj = objs[i];
				if ((!thinksItsAtHome(target_obj)) && (!isPlayer(target_obj)) && (!isMultiComp(target_obj))) {
					deleteObject(target_obj);
					count++;
				}
			}
		}
	}
	barkTo(this, this, "destroyed " + count + "objects.");
	return(0x00);
}
