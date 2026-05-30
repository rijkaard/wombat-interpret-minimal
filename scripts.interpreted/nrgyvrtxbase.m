inherits spelskil;

member loc summon_loc;

function int summon_energy_vortex(obj user, loc place) {
	int success = 0x00;
	int damage;
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, place));
	list objects_at_target;
	getObjectsAt(objects_at_target, place);
	if (numInList(objects_at_target) == 0x00) {
		if (!getCompileFlag(0x01)) {
			report_loc_aggression(user, summon_loc, 0x02, 0x00);
		}
		summon_loc = place;
		obj vortex = createGlobalNPCAt(0x023D, summon_loc, 0x00);
		if (vortex != NULL()) {
			success = 0x01;
			copyControllerInfo(vortex, user);
			attachScript(vortex, "vortexai");
			attachScript(vortex, "destcrea");
			setObjVar(vortex, "summonDifficulty", 0x0320);
			sfx(summon_loc, 0x0212, 0x00);
			callback(vortex, 0x5A, 0x08);
			int state_result = doNPCHandleStates(vortex);
		}
	} else {
		barkTo(user, user, "That location is blocked.");
	}
	schedule_cleanup(this);
	return(success);
}
