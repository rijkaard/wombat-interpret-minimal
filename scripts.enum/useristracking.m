inherits globals;

forward void append_direction(string , int );

forward void bark_trackee_direction(obj , int );

trigger callback(0x50) {
	obj trackee = getObjVar(this, "trackee");
	if (!isValid(trackee)) {
		systemMessage(this, "You have lost your quarry.");
		callback(this, 0x01, 0x51);
		return(0x00);
	}
	loc my_loc = getLocation(this);
	loc trackee_loc = getLocation(trackee);
	int direction = getDirectionInternal(my_loc, trackee_loc);
	int lastDirection;
	if (hasObjVar(this, "lastDirection")) {
		lastDirection = getObjVar(this, "lastDirection");
		if (lastDirection != direction) {
			setObjVar(this, "lastDirection", direction);
			bark_trackee_direction(trackee, direction);
		}
	} else {
		setObjVar(this, "lastDirection", direction);
		bark_trackee_direction(trackee, direction);
	}
	callback(this, 0x01, 0x50);
	return(0x00);
}

trigger callback(0x51) {
	removeObjVar(this, "trackee");
	removeObjVar(this, "lastDirection");
	detachScript(this, "useristracking");
	return(0x00);
}

trigger speech("stop") {
	if (speaker == this) {
		callback(this, 0x01, 0x51);
	}
	return(0x00);
}

function void bark_trackee_direction(obj trackee, int direction) {
	string description = getName(trackee) + " is ";
	append_direction(description, direction);
	ebarkTo(this, this, description);
	return();
}

function void append_direction(string description, int direction) {
	switch(direction) {
	case 0x00
		description = description + "to the North.";
		break;
	case 0x01
		description = description + "to the Northeast.";
		break;
	case 0x02
		description = description + "to the East.";
		break;
	case 0x03
		description = description + "to the Southeast.";
		break;
	case 0x04
		description = description + "to the South.";
		break;
	case 0x05
		description = description + "to the Southwest.";
		break;
	case 0x06
		description = description + "to the West.";
		break;
	case 0x07
		description = description + "to the Northwest.";
		break;
	default
		debugMessage("getDirection: invalid direction returned.");
		description = description + " in some direction.";
		break;
	}
	return();
}
