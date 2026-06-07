trigger use {
	loc trap_loc = 0x1532, 0x0758, 0x00;
	list msg_args;
	if (!hasObjVar(this, "working")) {
		messageToRange(trap_loc, 0x01, "unconditionalDisarm", msg_args);
	}
	return(0x01);
}
