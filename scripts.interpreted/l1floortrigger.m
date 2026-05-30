member list msg_args;

trigger enterrange(0x00) {
	loc target_loc;
	if (getX(getLocation(this)) == 0x143B) {
		if (getY(getLocation(this)) == 0x024C) {
			target_loc = 0x1430, 0x0248, 0x00;
			messageToRange(target_loc, 0x01, "PPdisarm", msg_args);
		}
		if (getY(getLocation(this)) == 0x0249) {
			target_loc = 0x1435, 0x0257, 0x00;
			messageToRange(target_loc, 0x0A, "FSdisarm", msg_args);
		}
	}
	if (getX(getLocation(this)) == 0x1431) {
		if (getY(getLocation(this)) == 0x0249) {
			target_loc = 0x1430, 0x0257, 0x00;
			messageToRange(target_loc, 0x01, "WTdisarm", msg_args);
			messageToRange(getLocation(this), 0x02, "trapCheck", msg_args);
		}
		if (getY(getLocation(this)) == 0x024C) {
			target_loc = 0x1435, 0x0250, 0x04;
			messageToRange(target_loc, 0x02, "WSdisarm", msg_args);
		}
	}
	return(0x00);
}

trigger leaverange(0x00) {
	if (getX(getLocation(this)) == 0x143B) {
		if (getY(getLocation(this)) == 0x0249) {
			callback(this, 0x3C, 0x02);
		}
		if (getY(getLocation(this)) == 0x024C) {
			callback(this, 0x3C, 0x04);
		}
	}
	if (getX(getLocation(this)) == 0x1431) {
		if (getY(getLocation(this)) == 0x0249) {
			callback(this, 0x3C, 0x01);
		}
		if (getY(getLocation(this)) == 0x024C) {
			callback(this, 0x3C, 0x03);
		}
	}
	return(0x00);
}

trigger callback(0x01) {
	loc target_loc = 0x1430, 0x0257, 0x00;
	messageToRange(target_loc, 0x01, "WTreload", msg_args);
	return(0x00);
}

trigger callback(0x02) {
	loc target_loc = 0x1435, 0x0257, 0x00;
	messageToRange(target_loc, 0x0A, "FSreload", msg_args);
	return(0x00);
}

trigger callback(0x03) {
	loc target_loc = 0x1435, 0x0250, 0x04;
	messageToRange(target_loc, 0x02, "WSreload", msg_args);
	return(0x00);
}

trigger callback(0x04) {
	loc target_loc = 0x1430, 0x0248, 0x00;
	messageToRange(target_loc, 0x01, "PPreload", msg_args);
	return(0x00);
}
