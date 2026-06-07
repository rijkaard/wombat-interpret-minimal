trigger message("barknow") {
	string text = args[0x00];
	bark(this, text);
	return(0x00);
}
