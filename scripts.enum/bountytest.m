inherits globals;

trigger lookedat {
	if (!hasObjVar(this, "bountyPlayer")) {
		return(0x01);
	}
	obj player = getObjVar(this, "bountyPlayer");
	barkTo(this, looker, "RelayLoc=" + getRelayLoc(player));
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		removeObjVar(this, "bountyPlayer");
		removeObjVar(this, "bountyPlayerName");
		return(0x00);
	}
	if (!isPlayer(usedon)) {
		removeObjVar(this, "bountyPlayer");
		removeObjVar(this, "bountyPlayerName");
		return(0x00);
	}
	systemMessage(user, getName(usedon) + " selected.");
	setObjVar(this, "bountyPlayer", usedon);
	setObjVar(this, "bountyPlayerName", getName(usedon));
	return(0x00);
}

trigger use {
	obj player = user;
	if (!hasObjVar(this, "bountyPlayer")) {
		systemMessage(user, "Select player to bounty:");
		targetObj(user, this);
		return(0x00);
	}
	string player_name = "PD BugKiller";
	if (hasObjVar(this, "bountyPlayerName")) {
		player_name = getObjVar(this, "bountyPlayerName");
	}
	systemMessage(user, "creating bounty for (" + objtoint(player) + ".");
	obj bountyInfo = createNoResObjectAt(0x01, getLocation(user));
	setObjVar(bountyInfo, "subject", player);
	attachScript(bountyInfo, "bountyinfo");
	list args = player, 0x029A, 0x00, player_name;
	message(bountyInfo, "addBounty", args);
	int teleport_result = teleport(bountyInfo, getRelayLoc(player));
	if (isValid(bountyInfo)) {
		clearList(args);
		message(bountyInfo, "teleported", args);
	}
	args = getAdjFame(user);
	systemMessage(user, "MurderReport: Messaging via probe to " + objtoint(user) + ".");
	relay_message(player, "murderReport", args);
	obj head = createNoResObjectIn(0x1DA0, getBackpack(user));
	setObjVar(head, "nameVar", player_name);
	setObjVar(head, "controller", player);
	return(0x00);
}
