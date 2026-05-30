inherits sk_table;

member obj target_map;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "mapmaking");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "Select the map upon which to draw.");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	list valid_map_types = 0x14EB, 0x14EC, 0x14ED, 0x14EE;
	int is_map = 0x00;
	for (int i = 0x00; i < 0x04; i++) {
		int obj_type = getObjType(usedon);
		int valid_type = valid_map_types[i];
		if (obj_type == valid_type) {
			is_map = 0x01;
		}
	}
	if (!is_map) {
		barkTo(usedon, user, "This is not a map.");
		return(0x00);
	}
	if (hasObjVar(usedon, "wasHandMade")) {
		barkTo(usedon, user, "You cannot overwrite this carefully hand-drawn map!");
		return(0x00);
	}
	target_map = usedon;
	list scale_choices = 0x196F, "A map of the local environs.", 0x1970, "A map suitable for cities.", 0x1971, "A moderately sized sea chart.", 0x1972, "A map of the world.";
	selectType(user, this, 0x1A, "Attempt what scale of map?", scale_choices);
	return(0x00);
}

function void clear_map_vars(obj map) {
	if (hasObjVar(map, "stockmap")) {
		removeObjVar(map, "stockmap");
		if (hasObjVar(map, "lookAtText")) {
			removeObjVar(map, "lookAtText");
		}
	}
	return;
}

trigger typeselected(0x1A) {
	bark(target_map, "Making the map now.");
	if (hasObjVar(target_map, "valueless")) {
		removeObjVar(this, "valueless");
	}
	if (!testSkill(this, 0x0C)) {
		clear_map_vars(target_map);
		setMapProperties(target_map, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
		barkTo(target_map, this, "Thy trembling hand results in an unusable map.");
		if (random(0x00, 0x03) == 0x01) {
			deleteObject(target_map);
		}
		return(0x00);
	}
	int half_extent;
	int scale;
	int skill = getSkillLevel(this, 0x0C);
	loc origin = getLocation(this);
	switch(objtype) {
	case 0x196F
		scale = 0x04;
		break;
	case 0x1970
		scale = 0x08;
		break;
	case 0x1971
		scale = 0x14;
		break;
	case 0x1972
		scale = 0x28;
		origin = 0x0580, 0x0680, 0x00;
		break;
	default
		scale = 0x01;
		break;
	}
	if (skill < 0x0A) {
		skill = 0x0A;
	}
	half_extent = ((skill * scale) / 0x02) + 0x40;
	int half_size = half_extent / 0x02;
	if (scale > 0x0A) {
		half_size = half_size - (half_size / 0x03);
	}
	if (half_size < 0xC8) {
		half_size = 0xC8;
	}
	if (half_size > 0x0190) {
		half_size = 0x0190;
	}
	if (half_size > half_extent) {
		half_extent = half_size;
	}
	int disp_w = half_size;
	int disp_h = half_size;
	int cx = getX(origin);
	int cy = getY(origin);
	int min_x = cx - half_extent;
	int min_y = cy - half_extent;
	int max_x = cx + half_extent;
	int max_y = cy + half_extent;
	if (min_x < 0x00) {
		min_x = 0x00;
	}
	if (max_x > 0x13FF) {
		max_x = 0x144F;
	}
	if (min_y < 0x00) {
		min_y = 0x00;
	}
	if (max_y > 0x0FFF) {
		max_y = 0x0FFF;
	}
	clear_map_vars(target_map);
	setMapProperties(target_map, 0x00, min_x, min_y, max_x, max_y, disp_w, disp_h);
	setObjVar(target_map, "wasHandMade", 0x01);
	barkTo(target_map, this, "With great care, thou dost make a chart of the geography.");
	return(0x00);
}
