inherits spelskil;

trigger creation {
	int base_max_hp = getWeaponMaxHP(this);
	int new_max_hp = base_max_hp + 0x0A;
	int dummy = setWeaponMaxHP(this, new_max_hp);
	return(0x00);
}
