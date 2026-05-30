inherits globals;

trigger creation {
	setObjVar(this, "I_am_food", 0x01);
	return(0x00);
}

trigger use {
	loc location = getLocation(this);
	obj dish = createNoResObjectAt(0x097A, location);
	transferResources(dish, this, 0x04, "fish");
	return(0x00);
}
