inherits spelskil;

member int dex_modifier;

function void init_cost() {
	if (!hasObjVar(this, "plateMailCost")) {
		dex_modifier = (0x00 - 0x05);
	} else {
		dex_modifier = getObjVar(this, "plateMailCost");
		dex_modifier = (0x00 - dex_modifier);
	}
	if (hasObjVar(this, "pmf")) {
		removeObjVar(this, "pmf");
	}
	return();
}

trigger creation {
	init_cost();
	return(0x01);
}

trigger objectloaded {
	init_cost();
	return(0x01);
}

trigger equip {
	apply_stat_mod(equippedon, 0x01, dex_modifier);
	return(0x01);
}

trigger unequip {
	int neg_dex_mod = 0x00 - dex_modifier;
	apply_stat_mod(unequippedfrom, 0x01, neg_dex_mod);
	return(0x01);
}
