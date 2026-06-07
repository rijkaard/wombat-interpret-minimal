inherits globals;

trigger use {
	list f_args;
	loc trapLocation = 0x154C, 0xBB, 0x00;
	messageToRange(trapLocation, 0x05, "reset", f_args);
	return(0x01);
}
