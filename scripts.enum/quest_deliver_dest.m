inherits quest_general_funcs;

trigger creation {
	if (!hasObjVar(this, "questDeliverObjectRec")) {
		debugMessage("Attempted to attach deliver quest without telling the destination mobile the object wanted.");
		detachScript(this, "quest_deliver_dest");
		return(0x01);
	}

member obj deliver_obj = getObjVar(this, "questDeliverObjectRec");
	return(0x01);
}

trigger give {
	int matched = 0x00;
	if (deliver_obj != NULL()) {
		if (givenobj == deliver_obj) {
			matched = 0x01;
		}
	}
	if (!matched) {
		return(0x01);
	}
	complete_quest_and_reward(this, giver, 0x01);
	deleteObject(givenobj);
	removeObjVar(this, "isActor");
	removeObjVar(this, "questDeliverObjectRec");
	detachScript(this, "quest_deliver_dest");
	return(0x00);
}
