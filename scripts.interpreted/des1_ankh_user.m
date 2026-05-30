inherits globals;

member int creation_hour;

member int creation_day;

trigger creation {
	creation_hour = getHour();
	creation_day = getDay();
	return(0x00);
}

trigger time("hour:**") {
	if ((getDay() != creation_day) && (getHour() == creation_hour) && (hasObjVar(this, "usedDespiseLevelOneAnkh"))) {
		int ankh_use_val = getObjVar(this, "usedDespiseLevelOneAnkh");
		if (ankh_use_val == 0x04) {
			setCurHP(this, getMaxHP(this));
			setCurMana(this, getMaxMana(this));
			setCurFatigue(this, getMaxFatigue(this));
			barkTo(this, this, "You feel completely rejuvinated!");
		}
		removeObjVar(this, "usedDespiseLevelOneAnkh");
		detachScript(this, "des1_ankh_user");
	}
	return(0x00);
}
