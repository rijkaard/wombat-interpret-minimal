trigger creation {
	disableBehaviors(this);

member int walking = 0x00;
	return(0x01);
}

trigger speech("come") {
	loc a = getLocation(speaker);
	walkTo(this, a, 0x2A);
	enableBehaviors(this);
	return(0x00);
}

trigger speech("stop") {
	disableBehaviors(this);
	walking = 0x00;
	return(0x00);
}

trigger speech("start") {
	enableBehaviors(this);
	walking = 0x01;
	return(0x00);
}

trigger pathfound(0x2A) {
	bark(this, "I made it!");
	if (!walking) {
		disableBehaviors(this);
	}
	return(0x00);
}

trigger pathnotfound(0x2A) {
	bark(this, "hrmph, I failed.");
	if (!walking) {
		disableBehaviors(this);
	}
	return(0x00);
}
