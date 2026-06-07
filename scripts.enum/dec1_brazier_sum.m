inherits globals;

member list summon_types;

trigger objectloaded {
	summon_types = 0x020A, 0x020F, 0x0210, 0x0211, 0x0212, 0x0213, 0x0214, 0x0215, 0x0216, 0x0217, 0x0218, 0x0219, 0x021D, 0x021E, 0x0220, 0x0221, 0x022B, 0x022C, 0x022F, 0x0230, 0x0231, 0x0232, 0x0235, 0x0242, 0x0243, 0x0244;
	return(0x00);
}

trigger creation {
	summon_types = 0x020A, 0x020F, 0x0210, 0x0211, 0x0212, 0x0213, 0x0214, 0x0215, 0x0216, 0x0217, 0x0218, 0x0219, 0x021D, 0x021E, 0x0220, 0x0221, 0x022B, 0x022C, 0x022F, 0x0230, 0x0231, 0x0232, 0x0235, 0x0242, 0x0243, 0x0244;
	return(0x00);
}

trigger use {
	loc spawn_loc = 0x1433, 0x0267, 0x00;
	if (!hasObjVar(this, "beenUsed")) {
		int summon_type = summon_types[random(0x00, numInList(summon_types) - 0x01)];
		obj npc = requestCreateNPCAt(summon_type, spawn_loc, 0x04);
		if (npc != NULL()) {
			doLocAnimation(spawn_loc, 0x3709, 0x02, 0x38, 0x00, 0x00);
		} else {
			bark(this, "The brazier fizzes and pops, but nothing seems to happen.");
		}
		setObjVar(this, "beenUsed", 0x00);
	} else {
		bark(this, "The brazier fizzes and pops, but nothing seems to happen.");
	}
	return(0x00);
}

trigger time("hour:0") {
	if (hasObjVar(this, "beenUsed")) {
		removeObjVar(this, "beenUsed")}
	return(0x00);
}

trigger enterrange(0x03) {
	if (!hasObjVar(this, "beenUsed")) {
		bark(this, "Heed this warning well, and use this brazier at your own peril.");
	}
	return(0x01);
}
