inherits eat;

trigger creation {
	setObjVar(this, "I_am_food", 0x01);
	setObjVar(this, "satiety", 0x02);
	return(0x01);
}

trigger use {
	eat_food(user, 0x09EA);
	return(0x01);
}
