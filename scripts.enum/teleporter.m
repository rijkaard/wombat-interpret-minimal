inherits itemmanip;

trigger enterrange(0x00) {
	int self_z = getZ(getLocation(this));
	int target_z = getZ(getLocation(target));
	int z_diff = self_z - target_z;
	if ((z_diff > 0x10) || (z_diff < (0x00 - 0x10))) {
		return(0x01);
	}
	if (hasObjVar(this, "dest")) {
		loc destination = getObjVar(this, "dest");
	} else {
		bark(this, "No dest Object variable found.");
		return(0x01);
	}
	if (isPlayer(target)) {
		if (hasObjVar(this, "accessList")) {
			if (!isInObjVarListSet(this, "accessList", target)) {
				if (!isEditing(target)) {
					return(0x01);
				}
			}
		}
		teleport_followers(target, destination);
		setLastValidTerrainLoc(target, destination);
		int r = teleport(target, destination);
		return(!r);
	}
	return(0x01);
}
