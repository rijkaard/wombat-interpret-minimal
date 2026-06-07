inherits spelskil;

function void remove_dex_effect() {
	setDefaultReturn(0x01);
	remove_stat_effect(this, STAT_DEX, 0x01);
	return();
}

trigger message("cancelmagic") {
	remove_dex_effect();
	return(0x01);
}

trigger callback(0x69) {
	remove_dex_effect();
	return(0x01);
}
