inherits hintupdate;

trigger decay {
	int hint_type = 0x02;
	int magic_val = 0x00;
	if (!getResource(magic_val, this, "magic", 0x03, 0x02)) {
		if (hasObjVar(this, "hintValue")) {
			magic_val = getObjVar(this, "hintValue");
		} else {
			magic_val = 0x01;
		}
	}
	if (magic_val < 0x14) {
		hint_type = 0x03;
	} else {
		if (magic_val < 0x50) {
			hint_type = 0x02;
		} else {
			hint_type = 0x00;
		}
	}
	hintupdate(hint_type, this);
	return(0x01);
}
