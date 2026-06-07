trigger use {
	if (!hasObjVar(this, "creatureTemplate")) {
		return(0x01);
	}
	int template = getObjVar(this, "creatureTemplate");
	obj npc = createGlobalNPCAt(template, getLocation(user), 0x00);
	return(0x01);
}
