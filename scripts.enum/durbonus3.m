inherits spelskil;

trigger creation {
	int max_hp = getWeaponMaxHP(this);
	int new_max_hp = max_hp + 0x1E;
	int dummy = setWeaponMaxHP(this, new_max_hp);
	return(0x00);
}
