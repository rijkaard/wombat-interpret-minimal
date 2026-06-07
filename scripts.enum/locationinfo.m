trigger use {
	list nearby;
	getObjectsInRange(nearby, getLocation(this), 0x01);
	systemMessage(user, "Objects Here:");
	for (int i = (numInList(nearby) - 0x01); i >= 0x00; i--) {
		obj target_obj = nearby[i];
		int z = getZ(getLocation(target_obj));
		systemMessage(user, "(" + z + "-" + (z + getHeight(target_obj)) + ") '" + getName(target_obj) + "' Type:" + getObjType(target_obj));
	}
	return(0x01);
}
