inherits sndfx;

member int activated;

member int trap_type;

member loc east_target;

member loc south_target;

member loc user_loc;

member int poisoned;

trigger creation {
	setObjVar(this, "isTrapped", 0x01);
	user_loc = getLocation(this);
	trap_type = getObjType(this);
	switch(trap_type) {
	case 0x112F
		east_target = user_loc;
		setX(east_target, getX(user_loc) + 0x01);
		break;
	case 0x112B
		south_target = user_loc;
		setY(south_target, getY(user_loc) + 0x01);
		break;
	}
	int roll = random(0x01, 0x64);
	if (0x3C < roll) {
		poisoned = 0x01;
	}
	return(0x00);
}

trigger message("activate") {
	trap_type = getObjType(this);
	activated = 0x01;
	if (hasObjVar(this, "disarmed")) {
		switch(trap_type) {
		case 0x1130
			setType(this, 0x112F);
			break;
		case 0x112C
			setType(this, 0x112B);
			break;
		default
			break;
		}
		callback(this, 0x64, 0x2F);
	} else {
		switch(trap_type) {
		case 0x112F
			setType(this, 0x1130);
			break;
		case 0x112B
			setType(this, 0x112C);
			break;
		default
			break;
		}
		sfx(user_loc, 0x0223, 0x00);
		shortcallback(this, 0x02, 0x44);
	}
	return(0x00);
}

trigger message("deactivate") {
	return(0x00);
}

trigger enterrange(0x01) {
	trap_type = getObjType(this);
	list mobs;
	int i;
	if (!hasObjVar(this, "disarmed")) {
		switch(trap_type) {
		case 0x112F
			getMobsAt(mobs, east_target);
			if (numInList(mobs) > 0x00) {
				setType(this, 0x1130);
				for (i = 0x00; i < numInList(mobs); i++) {
					loseHP(mobs[i], dice(0x01, 0x06));
					if (0x00 < poisoned) {
						setObjVar(mobs[i], "poison_strength", random(0x01, 0x02));
						attachScript(mobs[i], "poisoned");
					}
				}
				sfx(user_loc, 0x0223, 0x00);
				shortcallback(this, 0x02, 0x24);
			}
			break;
		case 0x112B
			getMobsAt(mobs, south_target);
			if (numInList(mobs) > 0x00) {
				setType(this, 0x112C);
				for (i = 0x00; i < numInList(mobs); i++) {
					loseHP(mobs[i], dice(0x01, 0x06));
					if (0x00 < poisoned) {
						setObjVar(mobs[i], "poison_strength", random(0x01, 0x02));
						attachScript(mobs[i], "poisoned");
					}
				}
				sfx(user_loc, 0x0224, 0x00);
				shortcallback(this, 0x02, 0x24);
			}
			break;
		default
			break;
		}
	} else {
		callback(this, 0x64, 0x2F);
	}
	return(0x01);
}

trigger enterrange(0x00) {
	if (!hasObjVar(this, "disarmed")) {
		switch(trap_type) {
		case 0x112F
			setType(this, 0x1130);
			sfx(user_loc, 0x0223, 0x00);
			loseHP(target, dice(0x01, 0x06));
			if (0x00 < poisoned) {
				setObjVar(target, "poison_strength", random(0x01, 0x02));
				attachScript(target, "poisoned");
			}
			shortcallback(this, 0x01, 0x24);
			break;
		case 0x112B
			setType(this, 0x112C);
			sfx(user_loc, 0x0224, 0x00);
			loseHP(target, dice(0x01, 0x06));
			if (0x00 < poisoned) {
				setObjVar(target, "poison_strength", random(0x01, 0x02));
				attachScript(target, "poisoned");
			}
			shortcallback(this, 0x01, 0x24);
			break;
		default
			break;
		}
	} else {
		callback(this, 0x64, 0x2F);
	}
	return(0x01);
}

trigger callback(0x24) {
	trap_type = getObjType(this);
	switch(trap_type) {
	case 0x1130
		setType(this, 0x112F);
		break;
	case 0x112C
		setType(this, 0x112B);
		break;
	default
		break;
	}
	setObjVar(this, "disarmed", 0x01);
	callback(this, 0x05, 0x2F);
	return(0x00);
}

trigger callback(0x2F) {
	removeObjVar(this, "disarmed");
	return(0x00);
}
