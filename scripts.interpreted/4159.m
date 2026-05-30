inherits cook;

trigger use {
	systemMessage(user, "What should I cook this on?");
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (hasObjVar(this, "NAME")) {
		string name;
		name = getObjVar(this, "NAME");
		if (name == "cake mix") {
			cook_item_default(user, usedon, 0x09E9)return(0x01);
		} else {
			barkTo(this, user, "name incorrect");
			return(0x01);
		}
	}
	cook_item_default(user, usedon, 0x160B);
	return(0x01);
}

trigger lookedat {
	if (hasObjVar(this, "NAME")) {
		string name = getObjVar(this, "NAME");
		barkTo(this, looker, name);
		return(0x00);
	}
	return(0x01);
}
