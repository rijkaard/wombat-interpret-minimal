trigger creation {
	int zero;
	setType(this, 0x124B);
	setObjVar(this, "MaidenClosed", zero);
	return(0x00);
}

trigger use {
	int zero;
	loc this_loc = getLocation(this);
	loc user_loc = getLocation(user);
	if (getDistanceInTiles(this_loc, user_loc) > 0x02) {
		ebarkTo(user, user, "If you had been closer, you might have stepped in and met a gruesome fate!");
		return(0x00);
	}
	if (hasObjVar(this, "MaidenWorking")) {
		return(0x00);
	}
	if (hasObjVar(this, "MaidenClosed")) {
		setType(this, 0x1249);
		removeObjVar(this, "MaidenClosed");
		setObjVar(this, "MaidenOpen", zero);
		callBack(this, 0x0A, 0x01);
		ebarkTo(user, user, "Hmm... you suspect that if you used this again, it might hurt.");
		return(0x00);
	}
	if (hasObjVar(this, "MaidenOpen")) {
		setType(this, 0x124B);
		removeObjVar(this, "MaidenOpen");
		setObjVar(this, "MaidenWorking", zero);
		callBack(this, 0x01, 0x03);
		callBack(this, 0x05, 0x02);
		int x = getX(this_loc) + 0x01;
		int y = getY(this_loc) + 0x01;
		int z = getZ(this_loc);
		loc adj_loc = x, y, z;
		if (!teleport(user, this_loc)) {
		}
		loseHP(user, dice(0x0A, 0x03));
		return(0x01);
	}
	return(0x00);
}

trigger callback(0x01) {
	if (hasObjVar(this, "MaidenOpen")) {
		callback(this, 0x00, 0x02);
	}
	return(0x00);
}

trigger callback(0x02) {
	int zero;
	if (hasObjVar(this, "MaidenWorking")) {
		removeObjVar(this, "MaidenWorking");
	}
	if (hasObjVar(this, "MaidenOpen")) {
		removeObjVar(this, "MaidenOpen")}
	if (!hasObjVar(this, "MaidenClosed")) {
		setType(this, 0x124B);
		setObjVar(this, "MaidenClosed", zero);
	}
	return(0x00);
}

trigger callback(0x03) {
	setType(this, 0x124C);
	callback(this, 0x01, 0x04);
	return(0x00);
}

trigger callback(0x04) {
	setType(this, 0x124D);
	callback(this, 0x01, 0x05);
	return(0x00);
}

trigger callback(0x05) {
	setType(this, 0x124C);
	callback(this, 0x03, 0x02);
	return(0x00);
}
