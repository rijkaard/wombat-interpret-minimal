inherits globals;

member loc trapLocation;

member loc reset_loc;

member list empty_args;

trigger creation {
	trapLocation = 0x1539, 0x0759, 0x00;
	reset_loc = 0x1533, 0x0753, 0x0D;
	return(0x00);
}

trigger message("flipped") {
	list objs;
	int type_up = 0x1092;
	int type_down = 0x1091;
	loc loc_switch_1 = 0x1531, 0x0753, 0x0D;
	loc loc_switch_2 = 0x1532, 0x0753, 0x0D;
	loc loc_switch_3 = 0x1533, 0x0753, 0x0D;
	loc loc_switch_4 = 0x1534, 0x0753, 0x0D;
	loc loc_switch_5 = 0x1535, 0x0753, 0x0D;
	getObjectsAt(objs, loc_switch_1);
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
		shortCallback(this, 0x01, 0x24);
		return(0x00);
	}
	for (int i = 0x00; i < numInList(objs); i++) {
		if (hasScript(objs[i], "cov1_gas_trap_switch")) {
			if (getObjType(objs[i]) == type_up) {
				if (hasObjVar(this, "covSwitchOneDown")) {
					removeObjVar(this, "covSwitchOneDown");
				}
			}
			if (getObjType(objs[i]) == type_down) {
				if (!hasObjVar(this, "covSwitchOneDown")) {
					setObjVar(this, "covSwitchOneDown", 0x01);
				}
			}
		}
	}
	clearList(objs);
	getObjectsAt(objs, loc_switch_2);
	for (i = 0x00; i < numInList(objs); i++) {
		if (hasScript(objs[i], "cov1_gas_trap_switch")) {
			if (getObjType(objs[i]) == type_up) {
				if (hasObjVar(this, "covSwitchTwoDown")) {
					removeObjVar(this, "covSwitchTwoDown");
				}
			}
			if (getObjType(objs[i]) == type_down) {
				if (!hasObjVar(this, "covSwitchTwoDown")) {
					setObjVar(this, "covSwitchTwoDown", 0x01);
				}
			}
		}
	}
	clearList(objs);
	getObjectsAt(objs, loc_switch_3);
	for (i = 0x00; i < numInList(objs); i++) {
		if (hasScript(objs[i], "cov1_gas_trap_switch")) {
			if (getObjType(objs[i]) == type_up) {
				if (hasObjVar(this, "covSwitchThreeDown")) {
					removeObjVar(this, "covSwitchThreeDown");
				}
			}
			if (getObjType(objs[i]) == type_down) {
				if (!hasObjVar(this, "covSwitchThreeDown")) {
					setObjVar(this, "covSwitchThreeDown", 0x01);
				}
			}
		}
	}
	clearList(objs);
	getObjectsAt(objs, loc_switch_4);
	for (i = 0x00; i < numInList(objs); i++) {
		if (hasScript(objs[i], "cov1_gas_trap_switch")) {
			if (getObjType(objs[i]) == type_up) {
				if (hasObjVar(this, "covSwitchFourDown")) {
					removeObjVar(this, "covSwitchFourDown");
				}
			}
			if (getObjType(objs[i]) == type_down) {
				if (!hasObjVar(this, "covSwitchFourDown")) {
					setObjVar(this, "covSwitchFourDown", 0x01);
				}
			}
		}
	}
	clearList(objs);
	getObjectsAt(objs, loc_switch_5);
	for (i = 0x00; i < numInList(objs); i++) {
		if (hasScript(objs[i], "cov1_gas_trap_switch")) {
			if (getObjType(objs[i]) == type_up) {
				if (hasObjVar(this, "covSwitchFiveDown")) {
					removeObjVar(this, "covSwitchFiveDown");
				}
			}
			if (getObjType(objs[i]) == type_down) {
				if (!hasObjVar(this, "covSwitchFiveDown")) {
					setObjVar(this, "covSwitchFiveDown", 0x01);
				}
			}
		}
	}
	if ((hasObjVar(this, "covSwitchOneDown")) && (hasObjVar(this, "covSwitchThreeDown")) && (hasObjVar(this, "covSwitchFiveDown")) && (!hasObjVar(this, "covSwitchTwoDown")) && (!hasObjVar(this, "covSwitchFourDown"))) {
		messageToRange(trapLocation, 0x0A, "cov_disarm", empty_args);
		callback(this, 0x1E, 0x24);
		setObjVar(this, "working", 0x01);
	}
	return(0x00);
}

trigger callback(0x24) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
		if (hasObjVar(this, "covSwitchOneDown")) {
			removeObjVar(this, "covSwitchOneDown");
		}
		if (hasObjVar(this, "covSwitchTwoDown")) {
			removeObjVar(this, "covSwitchTwoDown");
		}
		if (hasObjVar(this, "covSwitchThreeDown")) {
			removeObjVar(this, "covSwitchThreeDown");
		}
		if (hasObjVar(this, "covSwitchFourDown")) {
			removeObjVar(this, "covSwitchFourDown");
		}
		if (hasObjVar(this, "covSwitchFiveDown")) {
			removeObjVar(this, "covSwitchFiveDown");
		}
		messageToRange(trapLocation, 0x0A, "cov_reload", empty_args);
		messageToRange(reset_loc, 0x0A, "cov_reset", empty_args);
	}
	return(0x00);
}

trigger message("unconditionalDisarm") {
	if (!hasObjVar(this, "working")) {
		messageToRange(trapLocation, 0x0A, "cov_disarm", empty_args);
		callback(this, 0x1E, 0x24);
		setObjVar(this, "working", 0x01);
	}
	return(0x00);
}
