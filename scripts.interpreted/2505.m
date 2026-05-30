inherits eat;

trigger creation {
	setObjVar(this, "I_am_food", 0x01);
	setObjVar(this, "satiety", 0x0A);
	return(0x01);
}

trigger use {
	eat_food(user, 0x00);
	return(0x01);
}
