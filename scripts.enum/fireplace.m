inherits itemmanip;

trigger use {
	int cur_type = getObjType(this);
	int newType;
	obj new_self;
	obj partner_obj;
	int partner_type;
	int new_partner_type;
	obj new_partner;
	loc self_loc = getLocation(this);
	loc partner_loc = self_loc;
	switch(cur_type) {
	case 0x0935
		newType = 0x0937;
		partner_type = 0x0936;
		changeLoc(partner_loc, 0x00, 0x00 - 0x01, 0x00);
		new_partner_type = 0x093D;
		break;
	case 0x0936
		newType = 0x093D;
		partner_type = 0x0935;
		changeLoc(partner_loc, 0x00, 0x01, 0x00);
		new_partner_type = 0x0937;
		break;
	case 0x0937
		newType = 0x0935;
		partner_type = 0x093D;
		changeLoc(partner_loc, 0x00, 0x00 - 0x01, 0x00);
		new_partner_type = 0x0936;
		break;
	case 0x093D
		newType = 0x0936;
		partner_type = 0x0937;
		changeLoc(partner_loc, 0x00, 0x01, 0x00);
		new_partner_type = 0x0935;
		break;
	case 0x0951
		newType = 0x0953;
		partner_type = 0x0952;
		changeLoc(partner_loc, 0x00, 0x00 - 0x01, 0x00);
		new_partner_type = 0x0959;
		break;
	case 0x0952
		newType = 0x0959;
		partner_type = 0x0951;
		changeLoc(partner_loc, 0x00, 0x01, 0x00);
		new_partner_type = 0x0953;
		break;
	case 0x0953
		newType = 0x0951;
		partner_type = 0x0959;
		changeLoc(partner_loc, 0x00, 0x00 - 0x01, 0x00);
		new_partner_type = 0x0952;
		break;
	case 0x0959
		newType = 0x0952;
		partner_type = 0x0953;
		changeLoc(partner_loc, 0x00, 0x01, 0x00);
		new_partner_type = 0x0951;
		break;
	case 0x0944
		newType = 0x094B;
		partner_type = 0x0943;
		changeLoc(partner_loc, 0x01, 0x00, 0x00);
		new_partner_type = 0x0945;
		break;
	case 0x0943
		newType = 0x0945;
		partner_type = 0x0944;
		changeLoc(partner_loc, 0x00 - 0x01, 0x00, 0x00);
		new_partner_type = 0x094B;
		break;
	case 0x094B
		newType = 0x0944;
		partner_type = 0x0945;
		changeLoc(partner_loc, 0x01, 0x00, 0x00);
		new_partner_type = 0x0943;
		break;
	case 0x0945
		newType = 0x0943;
		partner_type = 0x094B;
		changeLoc(partner_loc, 0x00 - 0x01, 0x00, 0x00);
		new_partner_type = 0x0944;
		break;
	case 0x0960
		newType = 0x0967;
		partner_type = 0x095F;
		changeLoc(partner_loc, 0x01, 0x00, 0x00);
		new_partner_type = 0x0961;
		break;
	case 0x095F
		newType = 0x0961;
		partner_type = 0x0960;
		changeLoc(partner_loc, 0x00 - 0x01, 0x00, 0x00);
		new_partner_type = 0x0967;
		break;
	case 0x0967
		newType = 0x0960;
		partner_type = 0x0961;
		changeLoc(partner_loc, 0x01, 0x00, 0x00);
		new_partner_type = 0x095F;
		break;
	case 0x0961
		newType = 0x095F;
		partner_type = 0x0967;
		changeLoc(partner_loc, 0x00 - 0x01, 0x00, 0x00);
		new_partner_type = 0x0960;
		break;
	}
	partner_obj = getFirstObjectOfType(partner_loc, partner_type);
	new_partner = createGlobalObjectAt(new_partner_type, partner_loc);
	new_self = createGlobalObjectAt(newType, self_loc);
	deleteObject(partner_obj);
	deleteObject(this);
	return(0x00);
}
