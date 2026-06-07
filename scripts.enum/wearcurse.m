inherits wearstat;

trigger creation {
	str_mod = 0x00 - 0x0A;
	dex_mod = 0x00 - 0x0A;
	int_mod = 0x00 - 0x0A;
	return(0x01);
}

function void on_charges_expired(obj it) {
	detachScript(it, "wearcurse");
	return();
}
