function void handle_use(obj usedon) {
	return;
}

trigger use {
	handle_use(this);
	return(0x01);
}
