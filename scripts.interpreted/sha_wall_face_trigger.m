trigger use {
	list exclude;
	messageToRange(getLocation(this), 0x0A, "fireInTheHole", exclude);
	return(0x01);
}
