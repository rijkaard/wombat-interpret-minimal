inherits shipstuff;

function void register_hold(obj hold) {
	obj ship = getMultiSlaveId(hold);
	if (ship == NULL()) {
		return();
	}
	if (!hasObjVar(ship, "myshiphold")) {
		setObjVar(ship, "myshiphold", hold);
	}
	return();
}

trigger creation {
	register_hold(this);
	return(0x01);
}

trigger objectloaded {
	register_hold(this);
	return(0x01);
}

trigger use {
	if (isDead(user)) {
		return(0x00);
	}
	obj ship = getMultiSlaveId(this);
	if (ship == NULL()) {
		return(0x01);
	}
	if (!is_on_multi(user, ship)) {
		barkTo(user, user, "You must be on the ship to open the hold.");
		return(0x00);
	}
	if (is_ship_moving(ship)) {
		barkTo(user, user, "I can not open the hold while the ship is moving.");
		return(0x00);
	}
	return(0x01);
}
