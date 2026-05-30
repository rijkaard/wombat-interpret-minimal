inherits sndfx;

member obj victim;

function void summon_daemon(obj user) {
	int delay;
	loc here = getLocation(this);
	loc there = getObjVar(this, "dest2");
	list nearby;
	faceHere(user, getDirectionInternal(here, there));
	list dest_objs;
	getObjectsAt(dest_objs, there);
	if (numInList(dest_objs) == 0x00) {
		doLocAnimation(there, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
		doLocAnimation(there, 0x3728, 0x08, 0x14, 0x00, 0x00);
		obj daemon = createGlobalNPCAt(0x022F, there, 0x00);
		sfx(there, 0x0216, 0x00);
		setType(daemon, 0x0A);
		attachScript(daemon, "destcrea");
		delay = 0x0384;
		callback(daemon, delay, 0x08);
		doDamage(victim, daemon, 0x00);
		return();
	}
	return();
}

trigger enterrange(0x00) {
	int trap_z = getZ(getLocation(this));
	int target_z = getZ(getLocation(target));
	if (trap_z == target_z) {
		victim = target;
		summon_daemon(target);
	}
	return(0x01);
}
