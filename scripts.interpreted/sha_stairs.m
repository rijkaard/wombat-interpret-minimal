inherits globals;

trigger enterrange(0x01) {
	loc dest;
	loc self_loc = getLocation(this);
	loc src_1 = 0x1573, 0x12, (0x00 - 0x34);
	loc src_2 = 0x1588, 0x08, 0x00;
	loc src_3 = 0x1588, 0x94, 0x14;
	loc src_4 = 0x15E2, 0x65, (0x00 - 0x17);
	loc src_5 = 0x16F1, 0x11, 0x0A;
	loc src_6 = 0x158C, 0xAE, (0x00 - 0x17);
	loc dst_1 = 0x158B, 0x08, 0x00;
	loc dst_2 = 0x1570, 0x12, (0x00 - 0x1E);
	loc dst_3 = 0x15E0, 0x65, 0x00;
	loc dst_4 = 0x1589, 0x94, 0x14;
	loc dst_5 = 0x1587, 0xAF, 0x00;
	loc dst_6 = 0x16F6, 0x12, (0x00 - 0x0A);
	if (self_loc == src_1) {
		dest = dst_1;
	} else {
		if (self_loc == src_2) {
			dest = dst_2;
		} else {
			if (self_loc == src_3) {
				dest = dst_3;
			} else {
				if (self_loc == src_4) {
					dest = dst_4;
				} else {
					if (self_loc == src_5) {
						dest = dst_5;
					} else {
						if (self_loc == src_6) {
							dest = dst_6;
						} else {
							bark(this, "Not a supported teleporter location.");
							return(0x01);
						}
					}
				}
			}
		}
	}
	if (!teleport(target, dest)) {
		return(0x01);
	}
	return(0x00);
}
