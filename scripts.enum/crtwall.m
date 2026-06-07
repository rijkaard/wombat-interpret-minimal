inherits spelskil;

trigger callback(0x2E) {
	int newType = getObjVar(this, "newType");
	setType(this, newType);
	int wall_type = getObjVar(this, "walltype");
	int wall_dur = getObjVar(this, "walldur");
	switch(wall_type) {
	case 0x00
		attachScript(this, "ff_trig");
		break;
	case 0x01
		attachScript(this, "pf_trig");
		break;
	case 0x02
		attachScript(this, "paf_trig");
		break;
	case 0x03
		attachScript(this, "ef_trig");
		break;
	case 0x04
		attachScript(this, "sf_trig");
		break;
	}
	attachScript(this, "destroy");
	callback(this, wall_dur, 0x1E);
	return(0x00);
}
