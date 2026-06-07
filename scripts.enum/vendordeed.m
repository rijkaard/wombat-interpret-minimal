inherits housestuff;

trigger creation {
	setObjVar(this, "mybasevalue", 0x03E8);
	return(0x00);
}

trigger use {
	loc deed_loc = getLocation(this);
	obj house = get_nearby_house_for_user(user, deed_loc);
	if (!isValid(house)) {
		systemMessage(user, "Shops can only be set up near your house.");
		return(0x00);
	}
	if (!house_can_add_vendor(house)) {
		systemMessage(user, "This house can not support any more vendors.");
		return(0x00);
	}
	loc user_loc = getLocation(user);
	int vendor_type = random(0x0835, 0x0836);
	obj vendor = createGlobalNPCAt(vendor_type, deed_loc, 0x00);
	if (vendor == NULL()) {
		systemMessage(user, "Vendor was unable to be created there.");
		return(0x00);
	}
	setObjVar(vendor, "owner", user);
	setObjVar(vendor, "multi", house);
	attachScript(vendor, "vendor");
	disableBehaviors(vendor);
	add_vendor_to_house(house, vendor);
	deleteObject(this);
	return(0x00);
}
