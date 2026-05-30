inherits spelskil;

trigger enterrange(0x00) {
	int ok;
	ok = teleport(target, getObjVar(this, "destination"));
	return(0x01);
}
