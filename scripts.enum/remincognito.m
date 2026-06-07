inherits globals;

function void remove_incognito() {
	if (hasObjVar(this, "origName")) {
		string s = getObjVar(this, "origName");
		removeObjVar(this, "origName");
		setRealName(this, s);
	}
	if (hasObjVar(this, "origSkinColor")) {
		int skin_color = getObjVar(this, "origSkinColor");
		removeObjVar(this, "origSkinColor");
		setPartialHue(this, skin_color);
	}
	if (hasObjVar(this, "origHairStyle")) {
		int hair_style = getObjVar(this, "origHairStyle");
		removeObjVar(this, "origHairStyle");
		int hair_color = 0x00;
		if (hasObjVar(this, "origHairColor")) {
			hair_color = getObjVar(this, "origHairColor");
			removeObjVar(this, "origHairColor");
		}
		obj hair_obj = getItemAtSlot(this, EQUIP_HAIR);
		if (hair_obj != NULL()) {
			deleteObject(hair_obj);
		}
		if (hair_style) {
			hair_obj = createNoResObjectIn(hair_style, this);
			setHue(hair_obj, hair_color);
			int base_equip_result = equipObj(hair_obj, this, 0x0B);
		}
	}
	if (hasObjVar(this, "origFacialHairStyle")) {
		int facial_hair_style = getObjVar(this, "origFacialHairStyle");
		removeObjVar(this, "origFacialHairStyle");
		int facial_hair_color = 0x00;
		if (hasObjVar(this, "origFacialHairColor")) {
			facial_hair_color = getObjVar(this, "origFacialHairColor");
			removeObjVar(this, "origFacialHairColor");
		}
		obj facial_hair_obj = getItemAtSlot(this, EQUIP_FACIAL_HAIR);
		if (facial_hair_obj != NULL()) {
			deleteObject(facial_hair_obj);
		}
		if (facial_hair_style) {
			facial_hair_obj = createNoResObjectIn(facial_hair_style, this);
			setHue(facial_hair_obj, facial_hair_color);
			int result = equipObj(facial_hair_obj, this, 0x10);
		}
	}
	detachScript(this, "remincognito");
	return();
}

trigger callback(0x1D) {
	remove_incognito();
	return(0x01);
}

trigger message("undoincognito") {
	remove_incognito();
	return(0x01);
}
