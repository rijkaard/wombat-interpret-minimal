inherits defbonus;

member int armor_bonus_scaled;

trigger creation {
	armor_bonus_scaled = 0xFA;
	apply_defense_bonus(this, armor_bonus_scaled / 0x0A);
	return(0x01);
}
