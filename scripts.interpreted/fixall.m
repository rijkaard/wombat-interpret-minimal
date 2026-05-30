trigger creation {
	list players;
	getPlayersInRange(players, getLocation(this), 0x270F);
	int count = numInList(players);
	for (int i = 0x00; i < count; i++) {
		attachScript(players[i], "fixme");
	}
	bark(this, "fixme should have been run on all players now.");
	detachScript(this, "fixall");
	return(0x01);
}
