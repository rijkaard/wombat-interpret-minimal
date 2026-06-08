inherits globals;

member int escort_type;

member string dest_code;

member list dialogue_lines;

member string dest_name;

member int poll_count;

forward string get_city_name(string );

function void set_ad_text(int quest_type) {
	switch(quest_type) {
	default
	case 0x00
		dialogue_lines = "  Greetings!", "  I am a poor healer who", "seeks a worthy escort. I", "can offer some small pay", "to any doughty warrior", "able to assist me. It is", "imperative that I reach my", "destination, or innocents", "may perish!";
		break;
	case 0x01
		dialogue_lines = "  'Tis a terrible thing", "to be a parent with an", "ungrateful child! Yet such", "is my situation.", "  Because of the poor", "behavior and lack of", "character of this offspring", "of mine, I am obliged to", "foster them away from", "home.", "  So now I am in need of", "an able escort of good", "character who might serve", "as role model, and who can", "ensure that my child", "reaches their destination", "safely.", "  I shall let my child", "post their whereabouts so", "that thou mayst meet with", "them and arrange terms.           ---";
		break;
	case 0x02
		dialogue_lines = "  I am so happy! I am to", "be married, and my life", "will finally be complete!", "  Alas, I am no warrior,", "and the wedding is not to", "take place here. I am in", "need of an escort, for the", "roads are treacherous and", "my future spouse would be", "sad indeed to hear that", "an ettin ate me before the", "wedding.";
		break;
	case 0x03
		dialogue_lines = "  Wizard seeks escort to a", "conference.";
		break;
	case 0x04
		dialogue_lines = "  Reputable merchant seeks", "able warriors to serve as", "mercantile escort. Pay is", "scale; we prefer to hire", "experienced mercenaries.";
		break;
	case 0x05
		dialogue_lines = "  I am one of Lord British's", "couriers, and I seek an able", "warrior to escort me safely,", "as the message I carry is of", "utmost importance to the", "realm!";
		break;
	case 0x06
		dialogue_lines = "  'Tis a bit of a problem to", "admit it, but our normally", "trustworthy household guard", "seem to have broken his leg!", "  If thou art able with a", "weapon, we are pleased to take", "applications for his", "replacement, to serve as", "guard and escort on our", "forthcoming journey.";
		break;
	case 0x07
		dialogue_lines = "  I've always wished for", "adventure! Now I can have it", "at last!", "  My weaponsmaster in school", "always said I was a dab hand", "with a blade, and I am afire", "with the love of adventure!", "  Plus I have money.", "  So if you are willing to", "hire on as my bodyguard and", "join me as we seek the deepest", "depths of the Abyss, and", "as we conquer dragons with", "the rapid flick of our sharp", "swords, disregarding all", "danger and ignorant of fear,", "seek me out!", "  Cowards need not apply!";
		break;
	}
	return();
}

function void post_bulletin_board_notice(obj this) {
	list scratch;
	obj board = findClosestBBoard(getLocation(this));
	obj post = createNoResObjectIn(0x0EB0, board);
	loc unused_loc;
	string unused_str;
	string title;
	list title_options = "Escort needed", "Guard needed", "I need an escort!", "Traveling companion?", "Seeking companion", "Now hiring", "Hiring a guard", "Hiring an escort", "Seeking escort";
	title = title_options[random(0x00, numInList(title_options) - 0x01)];
	list postText = title;
	set_ad_text(escort_type);
	list location_lines = "  I can be found", getDistance(getLocation(board), getLocation(this)), getDirection(getLocation(board), getLocation(this)) + "", "of here. When thou dost find", "me, look at me close to accept", "the task of taking me to", get_city_name(dest_code) + ".", "    " + getName(this);
	string blah;
	for (int i = 0x00; i < numInList(dialogue_lines); i++) {
		blah = dialogue_lines[i];
		appendToList(postText, blah);
	}
	for (i = 0x00; i < numInList(location_lines); i++) {
		blah = location_lines[i];
		appendToList(postText, blah);
	}
	setObjVar(post, "postText", postText);
	setObjVar(this, "myBoardPost", post);
	return();
}

function string get_city_name(string city_key) {
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
	if (city_key == "dungn") {
		return("a dungeon");
	}
	return("somewhere");
}

function string pick_city_dest(obj this) {
	list city_codes = "city_bucden", "city_jhelom", "city_serphold", "city_nujelm", "city_trinsic", "city_skara", "city_ocllo", "city_magincia", "city_moonglow", "city_britain", "city_cove", "city_vesper", "city_minoc", "city_yew";
	string dest = city_codes[random(0x00, numInList(city_codes) - 0x01)];
	if (isInArea(dest, getLocation(this), 0x00)) {
		dest = pick_city_dest(this);
	}
	return(dest);
}

function string pick_dungeon_dest(obj this) {
	list dest_codes = "dungn";
	string dest = dest_codes[random(0x00, numInList(dest_codes) - 0x01)];
	if (isInArea(dest, getLocation(this), 0x00)) {
		dest = pick_city_dest(this);
	}
	return(dest);
}

trigger creation {
	disableBehaviors(this);
	setObjVar(this, "isWaitingForEscort", 0x01);
	if (hasObjVar(this, "questEscortType")) {
		escort_type = getObjVar(this, "questEscortType");
	} else {
		escort_type = random(0x00, 0x07);
		setObjVar(this, "questEscortType", escort_type);
	}
	dest_name = get_city_name(dest_code);
	switch(escort_type) {
	default
	case 0x00
	case 0x01
	case 0x02
	case 0x03
	case 0x04
	case 0x05
	case 0x06
		dest_code = pick_city_dest(this);
		break;
	case 0x07
		dest_code = pick_dungeon_dest(this);
		break;
	}
	post_bulletin_board_notice(this);
	return(0x01);
}

trigger 0x64 enterrange(0x01) {
	if (hasObjVar(this, "isWaitingForEscort")) {
		bark(this, "I am waiting for my escort to " + get_city_name(dest_code) + ". If thou art interested, check the local bulletin board for details, or just say 'I will take thee.'");
	}
	return(0x01)}

trigger speech("*destination*") {
	if (hasObjVar(this, "myEscort")) {
		obj escort = getObjVar(this, "myEscort");
		if (speaker == escort) {
			followNpc(this, speaker, 0x00);
			string msg = "Lead on! Payment will be made when we arrive in " + get_city_name(dest_code) + ".";
			bark(this, msg);
		}
	}
	return(0x01);
}

trigger speech("I will take thee") {
	if (getDistanceInTiles(getLocation(speaker), getLocation(this)) > 0x03) {
		return(0x01);
	}
	if (!hasObjVar(this, "isWaitingForEscort")) {
		if (hasObjVar(this, "myEscort")) {
			bark(this, "I am already being led!");
		} else {
			bark(this, "I am sorry, but I do not wish to go anywhere.");
			callback(this, 0x64, 0x7A);
		}
		return(0x01);
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	if (hasObjVar(this, "myBoardPost")) {
		obj board_post = getObjVar(this, "myBoardPost");
		deleteObject(board_post);
	}
	string msg = "Lead on! Payment will be made when we arrive in " + get_city_name(dest_code) + ".";
	bark(this, msg);
	removeObjVar(this, "isWaitingForEscort");
	followNpc(this, speaker, 0x00);
	setObjVar(this, "myEscort", speaker);
	callback(this, 0x05, 0x01);
	return(0x00);
}

trigger callback(0x01) {
	if (!hasObjVar(this, "myEscort")) {
		enableBehaviors(this);
		callback(this, 0x64, 0x7A);
		return(0x01);
	}
	obj escort = getObjVar(this, "myEscort");
	if (!isInArea(dest_code, getLocation(this), 0x00)) {
		poll_count = poll_count + 0x01;
		if (poll_count > 0x06) {
			poll_count = 0x00;
			if (getDistanceInTiles(getLocation(this), getLocation(escort)) > 0x1E) {
				bark(this, "My escort seems to have abandoned me!");
				enableBehaviors(this);
				callback(this, 0x64, 0x7A);
				return(0x01);
			}
		}
		callback(this, 0x05, 0x01);
		return(0x01);
	}
	stopFollowing(this);
	removeObjVar(this, "myEscort");
	string arrival_msg = "We have arrived! I thank thee, " + getName(escort) + "! I have no further need of thy services. Here is thy pay.";
	bark(this, arrival_msg);
	if (!getCompileFlag(0x01)) {
		if (getNotoriety(escort) < 0x7F) {
			addNotoriety(escort, 0x01);
		}
	} else {
		changeFame(escort, 0x03E8);
	}
	obj reward = requestCreateObjectAt(0x0EED, getLocation(escort));
	int success;
	if (reward != NULL()) {
		success = requestAddQuantity(reward, random(0x64, 0x01F4));
	}
	if (!success) {
		bark(this, "I fear that I lied about a reward, however. I lack any funds.");
		deleteObject(reward);
		enableBehaviors(this);
		callback(this, 0x64, 0x7A);
		return(0x01);
	}
	obj backpack = getBackpack(escort);
	success = putObjContainer(reward, backpack);
	enableBehaviors(this);
	callback(this, 0xC8, 0x7A);
	return(0x01);
}

trigger callback(0x7A) {
	deleteObject(this);
	return(0x01);
}
