inherits itemmanip;

function int teleport_through_moongate(obj it, obj mobile) {
	if (isShopkeeper(mobile)) {
		return(0x00);
	}
	loc gate_loc = getLocation(it);
	int gate_id = getObjVar(it, "gateID");
	int dest_index = getMoonGateDest(gate_id);
	loc dest_loc;
	switch(dest_index) {
	case 0x00
		dest_loc = 0x1173, 0x0503, 0x0A;
		break;
	case 0x01
		dest_loc = 0x0538, 0x07CD, 0x05;
		break;
	case 0x02
		dest_loc = 0x05DB, 0x0EBB, 0x05;
		break;
	case 0x03
		dest_loc = 0x0303, 0x02F0, 0x05;
		break;
	case 0x04
		dest_loc = 0x0A8D, 0x02B4, 0x05;
		break;
	case 0x05
		dest_loc = 0x0724, 0x0B84, 0x00 - 0x14;
		break;
	case 0x06
		dest_loc = 0x0283, 0x0813, 0x05;
		break;
	case 0x07
		dest_loc = 0x0DEB, 0x085B, 0x22;
		break;
	case 0x029A
		break;
	case 0x029B
		break;
	default
		bark(it, "default case");
		break;
		return(0x01);
	}
	reveal_and_notify(mobile);
	moveDir(dest_loc, getFacing(mobile));
	teleport_followers(mobile, dest_loc);
	setLastValidTerrainLoc(mobile, dest_loc);
	sfx(gate_loc, 0x020E, 0x00);
	int r = teleport(mobile, dest_loc);
	if (r) {
		sfx(dest_loc, 0x01FE, 0x00);
	}
	return(!r);
}

trigger enterrange(0x00) {
	return(teleport_through_moongate(this, target));
}

trigger use {
	if (getLocation(this) == getLocation(user)) {
		int ok = teleport_through_moongate(this, user);
	}
	return(0x00);
}
