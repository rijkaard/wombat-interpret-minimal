inherits guildbase;

function void request_collect() {
	list args;
	appendToList(args, getLocation(this));
	multiMessageToLoc(getRelayLoc(this), "collect", args);
	return();
}

trigger online {
	request_collect();
	return(0x01);
}

trigger serverswitch {
	request_collect();
	return(0x01);
}

trigger message("requestCollection") {
	request_collect();
	return(0x01);
}
