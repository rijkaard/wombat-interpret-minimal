inherits wearstat;

trigger creation {
	int_mod = 0x00 - 0x0A;
	return(0x01);
}

function void on_charges_expired(obj it) {
	detachScript(it, "wearfblmd");
	return();
}
