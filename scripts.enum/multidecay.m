inherits multistuff;

member int decay_count;

trigger decay {
	obj multi = getMultiSlaveId(this);
	int visit_count = getobjvar_int(multi, "decayvisits");
	if (visit_count < 0x0B40) {
		visit_count = visit_count + 0x01;
		setObjVar(multi, "decayvisits", visit_count);
		return(0x00);
	}
	resetMultiCarriedDecay(multi);
	int ret = 0x01;
	intRet(ret);
	return(0x01);
}
