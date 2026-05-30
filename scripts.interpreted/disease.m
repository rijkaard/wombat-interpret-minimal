inherits globals;

trigger creation {
	callback(this, 0x0E10, 0x5B);
	return(0x01);
}

trigger callback(0x5B) {
	list nearby_players;
	getPlayersInRange(nearby_players, getLocation(this), 0x0A);
	if (numInList(nearby_players) > 0x00) {
		callback(this, 0x012C, 0x5B);
		return(0x00);
	}
	deleteObject(this);
	return(0x01);
}

trigger gotattacked {
	callback(this, 0x0E10, 0x5B);
	return(0x01);
}
