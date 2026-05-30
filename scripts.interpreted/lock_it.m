inherits globals;

member int lockLevel;

function int lock_it(obj m_target, int start, int stop) {
	if (!hasObjVar(m_target, "isLocked")) {
		attachScript(m_target, "locked");
		lockLevel = random(start, stop);
		setObjVar(m_target, "isLocked", lockLevel);
		setObjVar(m_target, "lockLevel", lockLevel);
		return(0x01);
	}
	return(0x00);
}

function int set_lock_level(obj it, int start, int stop) {
	lockLevel = random(start, stop);
	setObjVar(it, "lockLevel", lockLevel);
	return(0x01);
}

function void apply_lock(obj lock_target) {
	if (!hasObjVar(lock_target, "isLocked")) {
		int level = getObjVar(lock_target, "lockLevel");
		setObjVar(lock_target, "isLocked", level);
	}
	return();
}
