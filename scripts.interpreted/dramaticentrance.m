inherits sndfx;

member obj activating_user;

trigger use {
	doLocAnimation(getLocation(user), 0x3709, 0x0A, 0x1E, 0x00, 0x00);
	sfx(getLocation(user), 0x54, 0x05);
	shortcallback(this, 0x04, 0x41);
	activating_user = user;
	return(0x00);
}

trigger callback(0x41) {
	setInvisible(activating_user, 0x00);
	int result = teleport(activating_user, getLocation(activating_user));
	return(0x00);
}
