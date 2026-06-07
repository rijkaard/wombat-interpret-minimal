trigger creation {
	int obj_type = getObjType(this);
	if (obj_type == 0x0FA9) {
		deleteObject(this);
	}
	return(0x01);
}
