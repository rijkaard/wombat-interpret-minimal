inherits spelskil;

member int gold_amount_str;

member int stat_index;

trigger creation {
	stat_index = 0x01;
	gold_amount_str = 0x0A;
	return(0x01);
}

trigger equip {
	apply_stat_mod(equippedon, stat_index, gold_amount_str);
	return(0x01);
}

trigger unequip {
	apply_stat_mod(unequippedfrom, stat_index, 0x00 - gold_amount_str);
	return(0x01);
}
