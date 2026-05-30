trigger use {
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	int n;
	string s;
	string msg;
	s = objToStr(usedon);
	concat(msg, s);
	concat(msg, " ");
	n = getDecayCount(usedon);
	s = n;
	concat(msg, s);
	concat(msg, " ");
	n = getDecayMax(usedon);
	s = n;
	concat(msg, s);
	barkTo(usedon, user, msg);
	return(0x01);
}
