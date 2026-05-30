trigger enterrange(0x01) {
	loc dest;
	if (hasObjVar(this, "toLocation")) {
		dest = getObjVar(this, "toLocation"));
		if (!teleport(target, dest)) {
			return(0x01);
		}
		return(0x00);
	}
	return(0x01);
}
