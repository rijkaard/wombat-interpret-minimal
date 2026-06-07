inherits spelskil;

function void remove_dex_modifier() {
	setDefaultReturn(0x01);
	remove_stat_effect(this, STAT_STR, 0x01);
	return();
}

trigger message("cancelmagic") {
	remove_dex_modifier();
	return(0x01);
}

trigger callback(0x67) {
	remove_dex_modifier();
	return(0x01);
}
