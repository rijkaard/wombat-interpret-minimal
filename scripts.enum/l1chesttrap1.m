trigger use {
	list f_args;
	messageToRange(getLocation(this), 0x03, "trapCheck", f_args);
	return(0x01);
}
