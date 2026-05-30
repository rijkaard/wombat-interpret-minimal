trigger use {
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	int is_multi = isMultiComp(usedon);
	loc offset;
	int val;
	string s;
	string msg;
	if (is_multi) {
		val = getObjType(usedon);
		s = val;
		msg = msg + s;
		msg = msg + " ";
		msg = msg + " ";
		offset = getMultiComponentOffset(usedon);
		val = getX(offset);
		s = val;
		msg = msg + s;
		msg = msg + " ";
		val = getY(offset);
		s = val;
		msg = msg + s;
		msg = msg + " ";
		val = getZ(offset);
		s = val;
		msg = msg + s;
		barkTo(usedon, user, msg);
	}
	return(0x01);
}
