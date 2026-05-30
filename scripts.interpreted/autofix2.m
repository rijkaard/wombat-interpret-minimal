inherits globals;

function void statfix(obj it) {
	for (int i = 0x00; i < 0x03; i++) {
		int raw_stat = getRealStat(it, i);
		int fixed_stat = raw_stat;
		if (raw_stat < 0x00) {
			fixed_stat = 0x00;
		}
		if (raw_stat >= 0xC8) {
			fixed_stat = 0x00;
		}
		if (fixed_stat != raw_stat) {
			int result = setRealStat(it, i, fixed_stat);
		}
	}
	return();
}

trigger creation {
	if (!isEditing(this)) {
		callback(this, 0x05, 0x93);
	}
	return(0x01);
}

trigger callback(0x93) {
	statfix(this);
	return(0x01);
}
