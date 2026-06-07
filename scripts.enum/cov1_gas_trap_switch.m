inherits globals;

trigger use {
	list f_args;
	messageToRange(getLocation(this), 0x05, "switchChange", f_args);
	callback(this, 0x01, 0x24);
	return(0x01);
}

trigger message("cov_reset") {
	if (getObjType(this) != 0x1092) {
		setType(this, 0x1092);
	}
	return(0x00);
}

trigger message("switchChange") {
	list objs;
	loc loc_1 = 0x1531, 0x0753, 0x0D;
	loc loc_2 = 0x1532, 0x0753, 0x0D;
	loc loc_3 = 0x1533, 0x0753, 0x0D;
	loc loc_4 = 0x1534, 0x0753, 0x0D;
	loc loc_5 = 0x1535, 0x0753, 0x0D;
	if (getLocation(this) == getLocation(sender)) {
		return(0x00);
	}
	if (getLocation(this) == loc_1) {
		if (getObjType(this) == 0x1091) {
			if ((getLocation(sender) == loc_2) || (getLocation(sender) == loc_4) || (getLocation(sender) == loc_3)) {
				setType(this, 0x1092);
			}
		}
	}
	if (getLocation(this) == loc_2) {
		if (getObjType(this) == 0x1091) {
			if ((getLocation(sender) == loc_5) || (getLocation(sender) == loc_1)) {
				setType(this, 0x1092);
			}
		}
	}
	if (getLocation(this) == loc_3) {
		if (getObjType(this) == 0x1091) {
			if (getLocation(sender) == loc_2) {
				setType(this, 0x1092);
			}
			if (getLocation(sender) == loc_5) {
				getObjectsAt(objs, loc_4);
				for (int i = 0x00; i < numInList(objs); i++) {
					if ((hasScript(objs[i], "cov1_gas_trap_switch")) && (getObjType(objs[i]) != 0x1092)) {
						setType(this, 0x1092);
					}
				}
			}
		}
	}
	if (getLocation(this) == loc_4) {
		if (getObjType(this) == 0x1091) {
			if ((getLocation(sender) == loc_2) || (getLocation(sender) == loc_3) || (getLocation(sender) == loc_5)) {
				setType(this, 0x1092);
			}
		}
	}
	if (getLocation(this) == loc_5) {
		if (getObjType(this) == 0x1091) {
			if ((getLocation(sender) == loc_1) || (getLocation(sender) == loc_4)) {
				setType(this, 0x1092);
			}
		}
	}
	return(0x00);
}

trigger callback(0x24) {
	list f_args;
	loc range_loc = 0x1532, 0x0758, 0x00;
	messageToRange(range_loc, 0x01, "flipped", f_args);
	return(0x00);
}
