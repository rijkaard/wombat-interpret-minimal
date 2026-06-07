inherits spelskil;

member loc summon_loc;

member obj spell_caster;

function obj summon_spirit(loc location, obj spell, obj caster) {
	obj spirit = createGlobalNPCAt(0x023E, location, 0x00);
	if (spirit != NULL()) {
		copyControllerInfo(spirit, caster);
		attachScript(spirit, "bspiritai");
		attachScript(spirit, "destcrea");
		setObjVar(spirit, "summonDifficulty", 0x01F4);
		callback(spirit, 0x78, 0x08);
		if (!getCompileFlag(0x01)) {
			report_loc_aggression(spirit, location, 0x02, 0x00);
		}
		int result = doNPCHandleStates(spirit);
	}
	return(spirit);
}

function int summon_blood_spirit(obj user, loc place) {
	int success = 0x00;
	int damage;
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, place));
	list objects_at_loc;
	getObjectsAt(objects_at_loc, place);
	if (numInList(objects_at_loc) == 0x00) {
		doLocAnimation(place, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
		spell_caster = user;
		summon_loc = place;
		if (!getCompileFlag(0x01)) {
			report_loc_aggression(user, place, 0x02, 0x00);
		}
		obj spirit = summon_spirit(summon_loc, this, user);
		if (isValid(spirit)) {
			success = 0x01;
		}
	} else {
		barkTo(user, user, "That location is blocked.");
	}
	schedule_cleanup(this);
	return(success);
}
