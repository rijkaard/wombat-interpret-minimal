inherits spelskil;

member int str_dex_mod;

member int int_mod;

trigger creation {
	str_dex_mod = 0x00 - 0x05;
	int_mod = 0x05;
	setObjVar(this, "lookAtText", "a magical wizard's hat");
	return(0x01);
}

trigger objectloaded {
	str_dex_mod = 0x00 - 0x05;
	int_mod = 0x05;
	return(0x01);
}

trigger equip {
	for (int s = 0x00; s < 0x02; s++) {
		apply_stat_mod(equippedon, s, str_dex_mod);
	}
	apply_stat_mod(equippedon, STAT_INT, int_mod);
	return(0x01);
}

trigger unequip {
	int neg_str_dex_mod = 0x00 - str_dex_mod;
	int neg_int_mod = 0x00 - int_mod;
	for (int s = 0x00; s < 0x02; s++) {
		apply_stat_mod(unequippedfrom, s, neg_str_dex_mod);
	}
	apply_stat_mod(unequippedfrom, STAT_INT, neg_int_mod);
	return(0x01);
}
