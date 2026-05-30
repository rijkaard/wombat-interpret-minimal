trigger use {
	list listeners;
	messageToRange(getLocation(this), 0x08, "allow", listeners);
	return(0x01);
}
