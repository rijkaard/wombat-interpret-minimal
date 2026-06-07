inherits spelskil;

function void cancel_stat_effect() {
	setDefaultReturn(0x01);
	remove_stat_effect(this, STAT_STR, 0x00);
	handleHealthGain(this);
	return();
}

trigger message("cancelmagic") {
	cancel_stat_effect();
	return(0x01);
}

trigger callback(0x68) {
	cancel_stat_effect();
	return(0x01);
}

trigger ishealthy {
	return(0x00);
}
