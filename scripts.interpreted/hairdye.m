inherits globals;

trigger creation {
	switch(random(0x01, 0x08)) {
	case 0x01
		setHue(this, random(0x0641, 0x0676));
		break;
	case 0x02
		setHue(this, random(0x0515, 0x054A));
		break;
	case 0x03
		setHue(this, random(0x0579, 0x05A7));
		break;
	case 0x04
		setHue(this, random(0x05DD, 0x060B));
		break;
	case 0x05
		setHue(this, random(0x04B1, 0x04DF));
		break;
	case 0x06
		setHue(this, random(0x0961, 0x097E));
		break;
	case 0x07
		setHue(this, random(0x0899, 0x08B0));
		break;
	default
		setHue(this, random(0x044E, 0x047C));
		break;
	}
	setObjVar(this, "lookAtText", "hair dye");
	setObjVar(this, "mybasevalue", 0x14);
	return(0x01);
}

trigger use {
	int dye_hue = getHue(this);
	int old_hue;
	int old_hue2;
	obj hair = getItemAtSlot(user, 0x0B);
	obj facial_hair = getItemAtSlot(user, 0x10);
	if (hair != NULL()) {
		if (!hasObjVar(hair, "oldhue")) {
			old_hue = getHue(hair);
			setObjVar(hair, "oldhue", old_hue);
		}
		setHue(hair, dye_hue);
		callback(hair, 0x0BB8, 0x00);
		attachScript(hair, "hairundye");
	}
	if (facial_hair != NULL()) {
		if (!hasObjVar(facial_hair, "oldhue")) {
			old_hue2 = getHue(facial_hair);
			setObjVar(facial_hair, "oldhue", old_hue2);
		}
		callback(facial_hair, 0x0BB8, 0x00);
		attachScript(facial_hair, "hairundye");
		setHue(facial_hair, dye_hue);
	}
	deleteObject(this);
	return(0x01);
}
