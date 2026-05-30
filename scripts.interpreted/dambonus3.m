inherits spelskil;

trigger creation {
	adjust_weapon_class(this, 0x00, 0x00, 0x05, 0x00);
	return(0x01);
}
