function void deactivate(obj this) {
	if (hasObjVar(this, "objectId") && hasObjVar(this, "objectType")) {
		obj objectId = getobjvar_obj(this, "objectId");
		int objectType = getobjvar_int(this, "objectType");
		deleteIfValid(objectId, objectType);
		removeObjVar(this, "objectId");
		removeObjVar(this, "objectType");
		processTriggerCmds(this, "d");
	}
	return;
}

trigger message("activate") {
	if (hasObjVar(this, "onlyOne")) {
		deactivate(this);
	}
	int radius = 0x03;
	if (hasObjVar(this, "radius")) {
		radius = getobjvar_int(this, "radius");
	}
	int template_id = 0x00;
	if (hasObjVar(this, "template")) {
		template_id = getobjvar_int(this, "template");
		loc location = getLocation(this);
		obj npc = requestCreateNPCAt(template_id, location, radius);
		int a = objtoint(npc);
		if (a != 0x00) {
			int objectType = getObjType(npc);
			setObjVar(this, "objectId", npc);
			setObjVar(this, "objectType", objectType);
			processTriggerCmds(this, "a");
		}
	} else {
		bark(this, "Missing template objvar!");
	}
	return(0x00);
}

trigger message("deactivate") {
	deactivate(this);
	return(0x00);
}
