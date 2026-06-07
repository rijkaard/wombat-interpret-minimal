inherits globals;

member obj master;

member loc master_loc;

trigger creation {
	master_loc = 0x144F, 0x0261, 0x03;
	list objs_at;
	getObjectsAt(objs_at, master_loc);
	for (int i = 0x00; i < numInList(objs_at); i++) {
		if (hasScript(objs_at[i], "dec_orbmaster")) {
			master = objs_at[i];
		}
	}
	return(0x00);
}

trigger use {
	list f_args;
	message(master, "makeMeTalk", f_args);
	return(0x00);
}

trigger speech("*") {
	list args = arg;
	message(master, "newAddition", args);
	return(0x00);
}
