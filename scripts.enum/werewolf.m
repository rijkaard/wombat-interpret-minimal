inherits sndfx;

trigger ooruse {

member obj m_user = user;
	setObjVar(user, "oldBodyType", getObjType(user));
	setObjVar(user, "oldHue", getHue(user));
	setType(user, 0x3B);
	callBack(this, 0x0A, 0xC8);
	return(0x01);
}

trigger callback(0xC8) {
	setType(m_user, (getObjVar(m_user, "oldBodyType")));
	return(0x01);
}
