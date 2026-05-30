inherits sndfx;

forward void cleanup();

forward void restore_pole();

trigger message("fish") {
	obj pole = args[0x00];
	loc there = args[0x01];
	setObjVar(this, "there", there);
	loc here = getLocation(this);
	int dir = getDirectionInternal(here, there);
	faceHere(this, dir);
	if ((isEquipped(pole))) {
		setObjVar(this, "equipped", 0x01);
	} else {
		obj pack = getBackpack(this);
		obj rightHand = getItemAtSlot(this, 0x01);
		if (!(rightHand == NULL())) {
			if (!(putObjContainer(rightHand, pack))) {
				return(0x00);
			}
		}
		obj leftHand = getItemAtSlot(this, 0x02);
		if (!(leftHand == NULL())) {
			if (!(putObjContainer(leftHand, pack))) {
				return(0x00);
			}
		}
		loc pole_loc;
		obj container;
		int contained = 0x00;
		if (isInContainer(pole)) {
			container = containedBy(pole);
			setObjVar(pole, "container", container);
		} else {
			pole_loc = getLocation(pole);
			setObjVar(pole, "location", pole_loc);
		}
		if (!(putObjContainer(pole, this))) {
		}
		if (!(equipObj(pole, this, 0x01))) {
			return(0x00);
		}
		setObjVar(this, "rightHand", rightHand);
		setObjVar(this, "leftHand", leftHand);
		setObjVar(this, "pole", pole);
	}
	animateMobile(this, 0x0C, 0x07, 0x01, 0x00, 0x00);
	callback(this, 0x02, 0x4B);
	return(0x01);
}

trigger callback(0x4B) {
	obj rightHand;
	obj leftHand;
	obj pole;
	int result;
	loc there;
	if (hasObjVar(this, "there")) {
		there = getObjVar(this, "there");
	}
	if (!(hasObjVar(this, "splash"))) {
		doLocAnimation(there, 0x352D, 0x04, 0x10, 0x00, 0x00);
		sfx(getLocation(this), 0x023F, 0x00);
		setObjVar(this, "splash", 0x01);
		callback(this, 0x05, 0x4B);
		return(0x00);
	}
	if (!(hasObjVar(this, "equipped"))) {
		if (hasObjVar(this, "rightHand")) {
			rightHand = getObjVar(this, "rightHand");
		} else {
			cleanup();
			return(0x00);
		}
		if (hasObjVar(this, "leftHand")) {
			leftHand = getObjVar(this, "leftHand");
		} else {
			cleanup();
			return(0x00);
		}
		if (hasObjVar(this, "pole")) {
			pole = getObjVar(this, "pole");
		} else {
			cleanup();
			return(0x00);
		}
		restore_pole();
		if (!(rightHand == NULL())) {
			if (!(equipObj(rightHand, this, 0x01))) {
				cleanup();
				return(0x00);
			}
		}
		if (!(leftHand == NULL())) {
			if (!(equipObj(leftHand, this, 0x02))) {
				cleanup();
				return(0x00);
			}
		}
	}
	if (!testSkill(this, 0x12)) {
		systemMessage(this, "You fish a while, but fail to catch anything.");
		cleanup();
		return(0x00);
	}
	string target_type = getObjVar(this, "targetType");
	int fish_avail;
	int fish_type;
	obj fish_obj;
	if (target_type == "object") {
		debugMessage("fishing on objects");
		list water_tile_types = 0x1796, 0x1797, 0x1798, 0x1799, 0x179A, 0x179B, 0x179C, 0x179D, 0x179E, 0x179F, 0x17A0, 0x17A1, 0x17A2, 0x17A3, 0x17A4, 0x17A5, 0x17A6, 0x17A7, 0x17A8, 0x17A9, 0x17AA, 0x17AB, 0x17AC, 0x17AD, 0x346E, 0x346F, 0x3470, 0x3471, 0x3472, 0x3473, 0x3474, 0x3475, 0x3476, 0x3477, 0x3478, 0x3479, 0x347A, 0x347B, 0x347C, 0x347D, 0x347E, 0x347F, 0x3480, 0x3481, 0x3482, 0x3483, 0x3484, 0x3485, 0x3486, 0x3487, 0x3488, 0x3489, 0x348A, 0x348B, 0x348C, 0x348D, 0x348E, 0x348F, 0x3490, 0x3491, 0x3492, 0x3493, 0x3494, 0x3495, 0x3496, 0x3497, 0x3498, 0x3499, 0x349A, 0x349B, 0x349C, 0x349D, 0x349E, 0x349F, 0x34A0, 0x34A1, 0x34A2, 0x34A3, 0x34A4, 0x34A5, 0x34A6, 0x34A7, 0x34A8, 0x34A9, 0x34AA, 0x34AB, 0x34AC, 0x34AD, 0x34AE, 0x34AF, 0x34A6, 0x34B1, 0x34B2, 0x34B3, 0x34B4, 0x34B5, 0x34B6, 0x34B7, 0x34B8, 0x34B9, 0x34BA, 0x34BB, 0x34BD, 0x34BE, 0x34BF, 0x34C0, 0x34C2, 0x34C3, 0x34C4, 0x34C5, 0x34C7, 0x34C8, 0x34C9, 0x34CA;
		list nearby_objs;
		getObjectsInRange(nearby_objs, there, 0x02);
		obj target_obj;
		int obj_type;
		list fish_tiles;
		int tile_count;
		int i;
		for (i = 0x00; i < numInList(nearby_objs); i++) {
			target_obj = nearby_objs[i];
			obj_type = getObjType(target_obj);
			if (isInList(water_tile_types, obj_type)) {
				result = getResource(fish_avail, target_obj, "fish", 0x03, 0x02);
				if (fish_avail > 0x00) {
					appendToList(fish_tiles, target_obj);
					tile_count++;
					if (tile_count > 0x03) {
						break;
					}
				}
			} else {
				i++;
				continue;
			}
		}
		debugMessage("fish tiles");
		if (tile_count > 0x03) {
			fish_type = random(0x09CC, 0x09CF);
			fish_obj = createNoResObjectAt(fish_type, getLocation(this));
			for (i = 0x00; i < 0x04; i++) {
				target_obj = fish_tiles[i];
				transferResources(fish_obj, target_obj, 0x01, "fish");
			}
			systemMessage(this, "You pull out a nice fish!");
		} else {
			barkTo(this, this, "The fish don't seem to be biting here.");
		}
	}
	if (target_type == "terrain") {
		debugMessage("fishing on terrain");
		obj chunk_egg = getChunkEgg(there);
		string chunk_str = objToStr(chunk_egg);
		debugMessage("chunk egg = " + chunk_str);
		result = getResource(fish_avail, chunk_egg, "fish", 0x03, 0x02);
		debugMessage("FishAvailable = " + fish_avail);
		if (fish_avail > 0x04) {
			fish_type = random(0x09CC, 0x09CF);
			fish_obj = createNoResObjectAt(fish_type, getLocation(this));
			transferResources(fish_obj, chunk_egg, 0x04, "fish");
			systemMessage(this, "You pull out a nice fish!");
		} else {
			barkTo(this, this, "The fish don't seem to be biting here.");
		}
	}
	cleanup();
	return(0x00);
}

function void cleanup() {
	if (hasObjVar(this, "pole")) {
		removeObjVar(this, "pole");
	}
	if (hasObjVar(this, "targetType")) {
		removeObjVar(this, "targetType");
	}
	if (hasObjVar(this, "there")) {
		removeObjVar(this, "there");
	}
	if (hasObjVar(this, "splash")) {
		removeObjVar(this, "splash");
	}
	if (hasObjVar(this, "rightHand")) {
		removeObjVar(this, "rightHand");
	}
	if (hasObjVar(this, "leftHand")) {
		removeObjVar(this, "leftHand");
	}
	if (hasObjVar(this, "staff")) {
		removeObjVar(this, "staff");
	}
	if (hasObjVar(this, "equipped")) {
		removeObjVar(this, "equipped");
	} else {
		restore_pole();
	}
	if (hasObjVar(this, "poleID")) {
		removeObjVar(this, "poleID");
	}
	detachScript(this, "userisfishing");
	return();
}

function void restore_pole() {
	obj pole = getObjVar(this, "poleID");
	obj container;
	loc location;
	int result;
	if (hasObjVar(pole, "container")) {
		container = getObjVar(pole, "container");
		result = putObjContainer(pole, container);
	} else {
		location = getObjVar(pole, "location");
		result = teleport(pole, location);
	}
	return();
}
