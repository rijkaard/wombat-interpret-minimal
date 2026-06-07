inherits spelskil;

function int is_human_mobile(obj it) {
	if (isMobile(it)) {
		int obj_type = getObjType(it);
		if ((obj_type == 0x0190) || (obj_type == 0x0191)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int validate_incognito_target(obj usedon) {
	if (!is_targetable_mobile(usedon)) {
		return(0x00);
	}
	if (!is_human_mobile(usedon)) {
		return(0x00);
	}
	if (hasScript(usedon, "remincognito")) {
		return(0x00);
	}
	if (hasScript(usedon, "polychec")) {
		return(0x00);
	}
	return(0x01);
}

function int apply_incognito(obj user, obj usedon) {
	int success = 0x00;
	if (validate_incognito_target(usedon)) {
		success = 0x01;
		int duration;
		int unused;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		doMobAnimation(usedon, 0x373A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x01EC, 0x00);
		if (getSkillLevel(user, SKILL_MAGERY) < 0x0A) {
			duration = 0x06;
		} else {
			duration = 0x06 * getSkillLevel(user, SKILL_MAGERY) / 0x05;
		}
		int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
		obj hair_obj = getItemAtSlot(usedon, EQUIP_HAIR);
		if (hair_obj != NULL()) {
			setObjVar(usedon, "origHairStyle", getObjType(hair_obj));
			setObjVar(usedon, "origHairColor", getHue(hair_obj));
			deleteObject(hair_obj);
		} else {
			setObjVar(usedon, "origHairStyle", 0x00);
		}
		obj facial_hair_obj = getItemAtSlot(usedon, EQUIP_FACIAL_HAIR);
		if (facial_hair_obj != NULL()) {
			setObjVar(usedon, "origFacialHairStyle", getObjType(facial_hair_obj));
			setObjVar(usedon, "origFacialHairColor", getHue(facial_hair_obj));
			deleteObject(facial_hair_obj);
		} else {
			setObjVar(usedon, "origFacialHairStyle", 0x00);
		}
		setObjVar(usedon, "origSkinColor", getHue(usedon));
		setObjVar(usedon, "origName", getRealName(usedon));
		int is_male = 0x01;
		if (getObjType(usedon) == 0x0191) {
			is_male = 0x00;
		}
		setRealNameFromTemplate(usedon, 0x00);
		setPartialHue(usedon, random(0x03EA, 0x0422));
		int hair_type = random(0x00, 0x09);
		if (is_male == 0x00 || (hair_type != 0x00)) {
			list female_hair_types = 0x2046, 0x203B, 0x203C, 0x203D, 0x2044, 0x2045, 0x2047, 0x2048, 0x2049, 0x204A;
			hair_type = female_hair_types[hair_type];
		}
		if (hair_type) {
			hair_obj = createNoResObjectIn(hair_type, usedon);
			setHue(hair_obj, random(0x044E, 0x047D));
			int equip_result = equipObj(hair_obj, usedon, 0x0B);
		}
		if (is_male == 0x01) {
			list facial_hair_types = 0x00, 0x2040, 0x203E, 0x203F, 0x2041, 0x204B, 0x204C, 0x204D;
			hair_type = facial_hair_types[random(0x00, 0x07)];
			if (hair_type) {
				facial_hair_obj = createNoResObjectIn(hair_type, usedon);
				setHue(facial_hair_obj, random(0x044E, 0x047D));
				int facial_equip_result = equipObj(facial_hair_obj, usedon, 0x10);
			}
		}
		attachScript(usedon, "remincognito");
		callback(usedon, duration, 0x1D);
	}
	schedule_cleanup(this);
	return(success);
}
