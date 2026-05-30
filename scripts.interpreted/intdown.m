inherits spelskil;

function void remove_effect() {
	setDefaultReturn(0x01);
	remove_stat_effect(this, 0x02, 0x00);
	handleHealthGain(this);
	return();
}

trigger message("cancelmagic") {
	remove_effect();
	return(0x01);
}

trigger callback(0x6C) {
	remove_effect();
	return(0x01);
}

trigger ishealthy {
	return(0x00);
}
