trigger use {
	loc trapLocation = 0x15AB, 0x0758, 0x00;
	list f_args;
	messageToRange(trapLocation, 0x0A, "covThreeFireTrapDisarm", f_args);
	return(0x01);
}
