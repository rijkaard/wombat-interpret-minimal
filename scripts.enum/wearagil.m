inherits wearstat;

trigger creation {
	dex_mod = 0x0A;
	return(0x01);
}

function void on_charges_expired(obj it) {
	detachScript(it, "wearagil");
	return();
}
