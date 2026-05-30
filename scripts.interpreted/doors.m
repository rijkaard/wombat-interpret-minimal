inherits sndfx;

trigger use {
	int obj_type = getObjType(this);
	int newType = 0x00;
	loc door_loc = getLocation(this);
	int sfx_id;
	switch(obj_type) {
	case 0xF4
		newType = 0xF5;
		sfx_id = 0xED;
		callback(this, 0x0F, 0x1B);
		break;
	case 0xF5
		newType = 0xF4;
		sfx_id = 0xED;
		break;
	case 0x0320
		newType = 0x0321;
		sfx_id = 0xED;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0321
		newType = 0x0320;
		sfx_id = 0xED;
		break;
	case 0x0330
		newType = 0x0331;
		sfx_id = 0xED;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0331
		newType = 0x0330;
		sfx_id = 0xED;
		break;
	case 0x0340
		newType = 0x0341;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0341
		newType = 0x0340;
		sfx_id = 0xF1;
		break;
	case 0x0350
		newType = 0x0351;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0351
		newType = 0x0350;
		sfx_id = 0xF1;
		break;
	case 0x0360
		newType = 0x0361;
		sfx_id = 0xED;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0361
		newType = 0x0360;
		sfx_id = 0xED;
		break;
	case 0x0681
		newType = 0x0682;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0682
		newType = 0x0681;
		sfx_id = 0xF1;
		break;
	case 0x0691
		newType = 0x0692;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0692
		newType = 0x0691;
		sfx_id = 0xF1;
		break;
	case 0x06A1
		newType = 0x06A2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06A2
		newType = 0x06A1;
		sfx_id = 0xF1;
		break;
	case 0x06B1
		newType = 0x06B2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06B2
		newType = 0x06B1;
		sfx_id = 0xF1;
		break;
	case 0x06C1
		newType = 0x06C2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06C2
		newType = 0x06C1;
		sfx_id = 0xF1;
		break;
	case 0x06D1
		newType = 0x06D2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06D2
		newType = 0x06D1;
		sfx_id = 0xF1;
		break;
	case 0x06E1
		newType = 0x06E2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06E2
		newType = 0x06E1;
		sfx_id = 0xF1;
		break;
	case 0x06F1
		newType = 0x06F2;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x06F2
		newType = 0x06F1;
		sfx_id = 0xF1;
		break;
	case 0x0830
		newType = 0x0831;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0831
		newType = 0x0830;
		sfx_id = 0xF1;
		break;
	case 0x0858
		newType = 0x0859;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0859
		newType = 0x0858;
		sfx_id = 0xF1;
		break;
	case 0x0845
		newType = 0x0846;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0846
		newType = 0x0845;
		sfx_id = 0xF1;
		break;
	case 0x0872
		newType = 0x0873;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x0873
		newType = 0x0872;
		sfx_id = 0xF1;
		break;
	case 0x190E
		newType = 0x190F;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x190F
		newType = 0x190E;
		sfx_id = 0xF1;
		break;
	case 0x1FF9
		newType = 0x1FFA;
		sfx_id = 0xEA;
		callback(this, 0x0F, 0x1B);
		break;
	case 0x1FFA
		newType = 0x1FF9;
		sfx_id = 0xF1;
		break;
	}
	if (newType == 0x00) {
		return(0x00);
	}
	setType(this, newType);
	sfx(door_loc, sfx_id, 0x00);
	return(0x00);
}

trigger callback(0x1B) {
	int newType = 0x00;
	int sfx_id;
	int obj_type = getObjType(this);
	loc pos = getLocation(this);
	switch(obj_type) {
	case 0xF5
		newType = 0xF4;
		sfx_id = 0xED;
		break;
	case 0x0321
		newType = 0x0320;
		sfx_id = 0xED;
		break;
	case 0x0331
		newType = 0x0330;
		sfx_id = 0xED;
		break;
	case 0x0341
		newType = 0x0340;
		sfx_id = 0xF1;
		break;
	case 0x0351
		newType = 0x0350;
		sfx_id = 0xF1;
		break;
	case 0x0361
		newType = 0x0360;
		sfx_id = 0xED;
		break;
	case 0x0682
		newType = 0x0681;
		sfx_id = 0xF1;
		break;
	case 0x0692
		newType = 0x0691;
		sfx_id = 0xF1;
		break;
	case 0x06A2
		newType = 0x06A1;
		sfx_id = 0xF1;
		break;
	case 0x06B2
		newType = 0x06B1;
		sfx_id = 0xF1;
		break;
	case 0x06C2
		newType = 0x06C1;
		sfx_id = 0xF1;
		break;
	case 0x06D2
		newType = 0x06D1;
		sfx_id = 0xF1;
		break;
	case 0x06E2
		newType = 0x06E1;
		sfx_id = 0xF1;
		break;
	case 0x06F2
		newType = 0x06F1;
		sfx_id = 0xF1;
		break;
	case 0x0831
		newType = 0x0830;
		sfx_id = 0xF1;
		break;
	case 0x0859
		newType = 0x0858;
		sfx_id = 0xF1;
		break;
	case 0x0846
		newType = 0x0845;
		sfx_id = 0xF1;
		break;
	case 0x0873
		newType = 0x0872;
		sfx_id = 0xF1;
		break;
	case 0x190F
		newType = 0x190E;
		sfx_id = 0xF1;
		break;
	case 0x1FF9
		newType = 0x1FFA;
		sfx_id = 0xF1;
		break;
	}
	if (newType == 0x00) {
		return(0x00);
	}
	setType(this, newType);
	sfx(pos, sfx_id, 0x00);
	return(0x00);
}
