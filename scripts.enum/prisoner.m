inherits globals;

function string rand_kidnap_headline() {
	list phrases = "A kidnapping!", "Help!", "Help us, please!", "Adventurers needed!", "Seeking assistance", "In need of aid", "Canst thou help us?", "Shall any save our friend?", "A friend was kidnapped!", "Heroes wanted!", "Can any assist us?", "Kidnapped!", "Taken prisoner";
	string result = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(result);
}

function string rand_distress_cry() {
	list phrases = "They are in terrible danger!", "Help!", "Help us, please!", "Please, someone help!", "Surely not all are cowards?", "We desperately need help!", "Canst thou help us?", "Shall any save our friend?", "A friend was kidnapped!", "Look not away from our need!", "Can any assist us?", "In Lord British's name, help!", "I fear for their life...";
	string result = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(result);
}

function string rand_villain_adj() {
	list phrases = "foul", "vile", "evil", "dark", "cruel", "vicious", "scoundrelly", "dastardly", "cowardly", "craven", "foul and monstrous", "monstrous", "hideous", "terrible", "cruel, evil", "truly vile", "vicious and cunning", "";
	string result = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(result);
}

function string get_location_name(string city_key) {
	if (city_key == "city_yew") {
		return("the city of Yew");
	}
	if (city_key == "city_minoc") {
		return("the city of Minoc");
	}
	if (city_key == "city_vesper") {
		return("the city of Vesper");
	}
	if (city_key == "city_cove") {
		return("the village of Cove");
	}
	if (city_key == "city_britain") {
		return("the city of Britain");
	}
	if (city_key == "city_moonglow") {
		return("the city of Moonglow");
	}
	if (city_key == "city_magincia") {
		return("the city of Magincia");
	}
	if (city_key == "city_ocllo") {
		return("the island of Ocllo");
	}
	if (city_key == "city_skara") {
		return("Skara Brae");
	}
	if (city_key == "city_trinsic") {
		return("Trinsic");
	}
	if (city_key == "city_nujelm") {
		return("Nujel'm");
	}
	if (city_key == "city_serphold") {
		return("Serpent's Hold");
	}
	if (city_key == "city_jhelom") {
		return("the city of Jhelom");
	}
	if (city_key == "city_bucden") {
		return("Buccaneer's Den");
	}
	if (city_key == "shrine") {
		return("any of the shrines of the Virtues");
	}
	if (city_key == "inn") {
		return("an inn where I can rest and recover");
	}
	if (city_key == "tavern") {
		return("a tavern where I can recover");
	}
	if (city_key == "city") {
		return("any city");
	}
	return("an inn");
}

trigger creation {
	disableBehaviors(this);
	setObjVar(this, "isPrisoner", 0x01);

member string location_code;
	list location_codes = "inn", "tavern", "city", "shrine", "city_yew", "city_vesper", "city_minoc", "city_nujelm", "city_cove", "city_moonglow", "city_magincia", "city_ocllo", "city_serphold", "city_jhelom", "city_skara", "city_trinsic";
	location_code = location_codes[random(0x00, numInList(location_codes) - 0x01)];

member string location_desc = get_location_name(location_code);

member string villains;
	if (!hasObjVar(this, "questVillains")) {
		villains = "orcs";
	} else {
		villains = getObjVar(this, "questVillains");
	}
	obj bboard = findClosestBBoard(getLocation(this));
	obj post = createNoResObjectIn(0x0EB0, bboard);
	loc area_loc;
	string area_name;
	int found = getLocalizedDesc(area_name, area_loc, getLocation(this), getLocation(bboard));
	if (!found) {
		area_name = "the woods";
	}
	list postText = rand_kidnap_headline(), "Help us please! " + getName(this) + " hath", "been kidnapped by ", rand_villain_adj() + " " + villains + "!", "We believe that " + getHeShe(this) + " is held in", area_name, getDistance(getLocation(bboard), getLocation(this)), getDirection(getLocation(bboard), getLocation(this)) + ".", rand_distress_cry();
	setObjVar(post, "postText", postText);
	setObjVar(this, "myBoardPost", post);
	return(0x01);
}

trigger enterrange(0x08) {
	if (hasObjVar(this, "isPrisoner")) {
		if (!isPlayer(target)) {
			return(0x01);
		}
		switch(random(0x00, 0x05)) {
		case 0x00
			bark(this, "HELP!");
			break;
		case 0x01
			bark(this, "Help me!");
			break;
		case 0x02
			bark(this, "Canst thou aid me?!");
			break;
		case 0x03
			bark(this, "Help a poor prisoner!");
			break;
		case 0x04
			bark(this, "Help! Please!");
			break;
		case 0x05
			bark(this, "Aaah! Help me!");
			break;
		default
			break;
		}
	}
	return(0x01);
}

trigger enterrange(0x01) {
	if (hasObjVar(this, "isPrisoner")) {
		bark(this, "Quickly, I beg thee! Unlock my chains! If thou dost look at me close thou canst see them.");
	}
	return(0x01);
}

trigger use {
	if (!hasObjVar(this, "isPrisoner")) {
		callback(this, 0x64, 0x7A);
		return(0x01);
	}
	if (isDead(user)) {
		return(0x01);
	}
	if (hasObjVar(this, "myBoardPost")) {
		obj board_post = getObjVar(this, "myBoardPost");
		deleteObject(board_post);
	}
	bark(this, "*The chains are open.*");
	removeObjVar(this, "isPrisoner");
	followNpc(this, user, 0x00);
	setObjVar(this, "myRescuer", user);
	string thanks_msg = "I thank thee! If thou dost take me to " + location_desc + ", I am sure that thou wilt be rewarded!";
	bark(this, thanks_msg);
	callback(this, 0x05, 0x01);
	return(0x00);
}

trigger speech("*") {
	if (hasObjVar(this, "myRescuer")) {
		obj rescuer = getObjVar(this, "myRescuer");
		if (speaker == rescuer) {
			followNpc(this, speaker, 0x00);
		}
	}
	return(0x01);
}

trigger callback(0x01) {
	if (!isInArea(location_code, getLocation(this), 0x00)) {
		callBack(this, 0x05, 0x01);
		return(0x01);
	}
	if (!hasObjVar(this, "myRescuer")) {
		enableBehaviors(this);
		callback(this, 0xC8, 0x7A);
		return(0x01);
	}
	stopFollowing(this);
	obj rescuer = getObjVar(this, "myRescuer");
	string thank_msg = "I thank thee, " + getName(rescuer) + "!";
	removeObjVar(this, "myRescuer");
	bark(this, thank_msg);
	if (!getCompileFlag(0x01)) {
		if (getNotoriety(rescuer) < 0x7F) {
			addNotoriety(rescuer, 0x01);
		}
	} else {
		changeFame(rescuer, 0x03E8);
	}
	obj reward = requestCreateObjectAt(0x0EED, getLocation(rescuer));
	int success;
	if (reward != NULL()) {
		success = requestAddQuantity(reward, random(0x64, 0x01F4));
	}
	if (!success) {
		bark(this, "I fear that I lied about a reward, however. I lack any funds.");
		deleteObject(reward);
		enableBehaviors(this);
		callback(this, 0xC8, 0x7A);
		return(0x01);
	}
	obj backpack = getBackpack(rescuer);
	success = putObjContainer(reward, backpack);
	enableBehaviors(this);
	callback(this, 0xC8, 0x7A);
	return(0x01);
}

trigger callback(0x7A) {
	deleteObject(this);
	return(0x01);
}
