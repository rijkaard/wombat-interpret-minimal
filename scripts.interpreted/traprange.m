trigger enterrange(0x01) {
	if (isDead(target)) {
		return(0x01);
	}
	string msg;
	if (hasObjVar(this, "TrapMessageRange")) {
		int range = getObjVar(this, "TrapMessageRange");
		if (hasObjVar(this, "TrapTheMessage")) {
			msg = getObjVar(this, "TrapTheMessage");
		} else {
			msg = "blah";
		}
		list msg_args = target, msg;
		messageToRange(getLocation(this), range, "TRAP", msg_args);
	}
	return(0x01);
}
