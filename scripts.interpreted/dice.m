trigger use {
	if (isDead(user)) {
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		ebarkTo(this, user, "Someone else is already using those dice.");
		return(0x00);
	}
	setObjVar(this, "inUse", 0x01);
	int die1 = dice(0x01, 0x06);
	int die2 = dice(0x01, 0x06);
	int total = die1 + die2;
	string die1_str = die1;
	string die2_str = die2;
	string total_str = total;
	string msg = getName(user) + " shakes the cup and spills the dice. The dice come to a stop showing a " + die1_str + " and a " + die2_str + " for a total of " + total_str + ".";
	ebark(this, msg);
	removeObjVar(this, "inUse");
	return(0x00);
}
