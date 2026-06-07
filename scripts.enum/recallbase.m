inherits spelskil;

member loc origin_loc;

member obj caster;

function int validate_recall_target(obj user, obj usedon) {
	if (usedon == NULL()) {
		return(0x00);
	}
	if ((containedBy(usedon) == NULL()) && (canSeeObj(user, usedon) != 0x01)) {
		bark(user, "I cannot see that object.");
		return(0x00);
	}
	if (isMobile(usedon)) {
		bark(user, "I cannot recall from that object.");
		return(0x00);
	}
	if (!hasObjVar(usedon, "markLoc")) {
		bark(user, "I cannot recall from that object.");
		return(0x00);
	}
	return(0x01);
}

function int execute_recall(obj user, obj usedon) {
	int success = 0x00;
	if (validate_recall_target(user, usedon)) {
		loc mark_loc = getObjVar(usedon, "markLoc");
		origin_loc = getLocation(user);
		caster = user;
		sfx(mark_loc, 0x01FC, 0x00);
		int blocked = 0x00;
		if (getEncumbrance(caster) > 0x64) {
			systemMessage(caster, "Thou art too encumbered to move.");
			blocked = 0x01;
		}
		if (!blocked && (!can_teleport_out(origin_loc) || !can_teleport_in(mark_loc))) {
			systemMessage(caster, "You can not teleport into that area.");
			blocked = 0x01;
		}
		if (!blocked) {
			trigger_teleport(user, mark_loc);
			success = 0x01;
		}
	}
	schedule_cleanup(this);
	return(success);
}
