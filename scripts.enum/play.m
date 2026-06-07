inherits sndfx;

trigger use {
	setObjVar(user, "lastInstrument", this);
	int sound_id;
	if (!skillTest(user, SKILL_MUSICIANSHIP)) {
		sound_id = getObjVar(this, "badSound");
		sfx(getLocation(user), sound_id, 0x3C);
		return(0x00);
	}
	sound_id = getObjVar(this, "goodSound");
	sfx(getLocation(user), sound_id, 0x3C);
	return(0x01);
}
