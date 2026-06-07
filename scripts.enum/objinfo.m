trigger use {
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	string num;
	string msg = objToStr(usedon);
	int val = getValue(usedon);
	num = val;
	concat(msg, " ");
	concat(msg, num);
	barkTo(usedon, user, msg);
	msg = "weight: ";
	num = getWeight(usedon);
	concat(msg, num);
	bark(usedon, msg);
	loc blah = getLocation(usedon);
	bark(usedon, "(" + getX(blah) + "," + getY(blah) + "," + getZ(blah) + ")");
	return(0x01);
}
