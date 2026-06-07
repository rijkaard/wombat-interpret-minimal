inherits globals;

trigger use {
	list args = user;
	obj chest;
	chest = getMultiSlaveId(this);
	message(chest, "getTreasure", args);
	return(0x00);
}
