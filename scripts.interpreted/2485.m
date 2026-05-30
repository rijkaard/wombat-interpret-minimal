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
	cook_item_default(user, usedon, 0x09B6);
	return(0x01);
}
