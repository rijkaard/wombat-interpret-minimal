inherits furniture;

trigger use {
	int obj_type = getObjType(this);
	loc user_loc = getLocation(user);
	loc there = getLocation(this);
	int dist = getDistanceInTiles(user_loc, there);
	if (dist > 0x02) {
		bark(user, "I am too far away to do that.");
		return(0x00);
	}
	int ok;
	switch(obj_type) {
	case 0x0A53
		setType(this, 0x0A52);
		callback(this, 0x0A, 0x26);
		break;
	case 0x0A4F
		setType(this, 0x0A4E);
		callback(this, 0x0A, 0x26);
		break;
	case 0x0A51
		setType(this, 0x0A50);
		callback(this, 0x0A, 0x26);
		break;
	case 0x0A4D
		setType(this, 0x0A4C);
		callback(this, 0x0A, 0x26);
		break;
	case 0x0A52
		setType(this, 0x0A53);
		ok = teleport(this, getLocation(this));
		break;
	case 0x0A4E
		setType(this, 0x0A4F);
		ok = teleport(this, getLocation(this));
		break;
	case 0x0A50
		setType(this, 0x0A51);
		ok = teleport(this, getLocation(this));
		break;
	case 0x0A4C
		setType(this, 0x0A4D);
		ok = teleport(this, getLocation(this));
		break;
	default
		break;
	}
	return(0x01);
}

trigger callback(0x26) {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x0A52
		setType(this, 0x0A53);
		break;
	case 0x0A4E
		setType(this, 0x0A4F);
		break;
	case 0x0A50
		setType(this, 0x0A51);
		break;
	case 0x0A4C
		setType(this, 0x0A4D);
		break;
	default
		break;
	}
	return(0x00);
}

trigger wasdropped {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x0A4C
		update_facing_type(0x0A4C, 0x0A50, 0x0A4C, 0x0A50);
		break;
	case 0x0A4D
		update_facing_type(0x0A4D, 0x0A51, 0x0A4D, 0x0A51);
		break;
	case 0x0A4E
		update_facing_type(0x0A4E, 0x0A52, 0x0A4E, 0x0A52);
		break;
	case 0x0A4F
		update_facing_type(0x0A4F, 0x0A53, 0x0A4F, 0x0A53);
		break;
	case 0x0A50
		update_facing_type(0x0A4C, 0x0A50, 0x0A4C, 0x0A50);
		break;
	case 0x0A51
		update_facing_type(0x0A4D, 0x0A51, 0x0A4D, 0x0A51);
		break;
	case 0x0A52
		update_facing_type(0x0A4E, 0x0A52, 0x0A4E, 0x0A52);
		break;
	case 0x0A53
		update_facing_type(0x0A4F, 0x0A53, 0x0A4F, 0x0A53);
		break;
	}
	return(0x01);
}
