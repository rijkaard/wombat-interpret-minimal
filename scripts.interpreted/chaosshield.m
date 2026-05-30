inherits virtueshield;

trigger equip {
	if (isNPC(equippedon)) {
		return(0x01);
	}
	if (getCompileFlag(0x01)) {
		if (hasScript(equippedon, "chaosguild")) {
			return(0x01);
		}
	} else {
		if (get_notoriety_level(equippedon) >= 0x05) {
			return(0x01);
		}
	}
	schedule_destroy();
	return(0x00);
}
