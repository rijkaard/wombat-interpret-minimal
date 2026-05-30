trigger message("barknow") {
	string msg = args[0x00];
	bark(this, msg);
	return(0x00);
}
