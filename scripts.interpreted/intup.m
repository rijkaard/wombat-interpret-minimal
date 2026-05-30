inherits spelskil;

function void remove_effect() {
	setDefaultReturn(0x01);
	remove_stat_effect(this, 0x02, 0x01);
	return();
}

trigger message("cancelmagic") {
	remove_effect();
	return(0x01);
}

trigger callback(0x6B) {
	remove_effect();
	return(0x01);
}
