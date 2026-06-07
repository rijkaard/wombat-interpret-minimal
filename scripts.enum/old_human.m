inherits human_funcs;

forward int check_murder_witness(string );

forward int has_scavenge_targets(obj );

forward void scavenge_item(obj );

forward int handle_train_speech(obj , obj , string );

forward int handle_name_speech(obj , obj , string );

forward int handle_need_speech(obj , obj , string );

forward int handle_time_query(obj , obj , string );

forward int handle_location_query(obj , obj , string );

forward int handle_shop_query(obj , obj , string );

trigger message("getPriceModifier") {
	int hue_factor = 0x64;
	int guildMember = 0xFF;
	int my_guild = 0xFE;
	if (hasObjVar(this, "guildMember")) {
		my_guild = getObjVar(this, "guildMember");
	}
	if (hasObjVar(sender, "guildMember")) {
		guildMember = getObjVar(sender, "guildMember");
	}
	if (my_guild == guildMember) {
		hue_factor = hue_factor - 0x0A;
	}
	int notoriety_factor = getNotoriety(sender);
	notoriety_factor = notoriety_factor / 0x05;
	hue_factor = hue_factor - notoriety_factor;
	return(hue_factor);
}

trigger speech("*") {
	int is_direct = 0x00;
	debugMessage("Starting stock convo trigger.");
	if (0x00) {
		bark(this, "Standard convo trigger executing.");
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	is_direct = is_direct_address(arg, this);
	int flag;
	int i;
	if (!check_convo_eligibility(this, speaker, arg)) {
		if (0x00) {
			bark(this, "Failed convo facing check");
		}
		return(0x01);
	}
	if (count_targets(this)) {
		bark(this, "I am too busy fighting to deal with thee!");
		return(0x00);
	}
	debugMessage("Doing recognition of speaker.");
	if (is_notable_target(this, speaker)) {
		if (0x00) {
			debugMessage("Internal recognition keyword called.");
		}
		replyTo(this, speaker, "@InternalRecognition");
		begin_convo_pause(this);
	}
	if (!handle_shop_query(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_location_query(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_time_query(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_need_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_name_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_train_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!is_direct) {
		if (0x00) {
			bark(this, "Responding now.");
		}
		replyTo(this, speaker, arg);
		begin_convo_pause(this);
	}
	remember_target(this, speaker);
	return(0x00);
}

trigger enterrange(0x01) {
	if (hasObjVar(this, "StandingOnMe")) {
		return(0x01);
	}
	if (!is_valid_player(this, target)) {
		return(0x01);
	}
	setObjVar(this, "StandingOnMe", target);
	callBack(this, 0x78, 0x0A);
	if (0x00) {
		debugMessage("Personal space trigger activated.");
	}
	return(0x01);
}

trigger leaverange(0x01) {
	if (hasObjVar(this, "StandingOnMe")) {
		removeObjVar(this, "StandingOnMe");
		if (0x00) {
			debugMessage("Removing personal space flag.");
		}
		return(0x01);
	}
	return(0x01);
}

trigger callback(0x0A) {
	if (count_targets(this)) {
		return(0x00);
	}
	if (!hasObjVar(this, "StandingOnMe")) {
		return(0x00);
	}
	obj intruder = getObjVar(this, "StandingOnMe");
	loc intruder_loc = getLocation(intruder);
	loc my_loc = getLocation(this);
	removeObjVar(this, "StandingOnMe");
	if (getDistanceInTiles(my_loc, intruder_loc) < 0x02) {
		if (0x00) {
			bark(this, "You're standing too close, go away.");
		}
		replyTo(this, intruder, "@InternalPersonalSpace");
		setObjVar(this, "StandingOnMe", intruder);
		callBack(this, 0x64, 0x0A);
	}
	return(0x01);
}

trigger time("hour:**") {
	if (hasObjVar(this, "myJobLocation")) {
		loc place = getObjVar(this, "myJobLocation");
		walkTo(this, place, 0x06);
		return(0x01);
	}
	return(0x01);
}

trigger creation {
	callBack(this, 0xFA, 0x0B);
	if (0x00) {
		debugMessage("Initializing scavenger behavior.");
	}
	return(0x01);
}

function int has_scavenge_targets(obj this) {
	list nearby;
	getObjectsInRange(nearby, getLocation(this), 0x0A);
	if (numInList(nearby) == 0x00) {
		if (0x00) {
			debugMessage("Nothing nearby to scavenge.");
		}
		return(0x00);
	}
	return(0x01);
}

trigger callback(0x0B) {
	callback(this, 0x3C, 0x0B);
	if (!has_scavenge_targets(this)) {
		return(0x01);
	}
	scavenge_item(this);
	return(0x01);
}

function void scavenge_item(obj this) {
	list nearby_objects;
	getObjectsInRange(nearby_objects, getLocation(this), 0x0A);
	int rand_idx = random(0x00, numInList(nearby_objects) - 0x01);
	obj candidate_item = nearby_objects[rand_idx];
	if (!is_tile_clear(this, candidate_item)) {
		return();
	}
	if (getWeight(candidate_item) > 0x14) {
		if (0x00) {
			bark(this, "Tried to scavenge something too heavy. :P");
		}
		return();
	}
	if (is_guarded(this, candidate_item)) {
		return();
	}
	if (getObjType(candidate_item) == 0x00) {
		return();
	}
	if (hasObjVar(this, "ScavengeLastItemGotten")) {
		obj last_item = getObjVar(this, "ScavengeLastItemGotten");
		if (hasObj(this, last_item)) {
			deleteObject(last_item);
		}
	}

member obj scavenge_target = candidate_item;
	walkTo(this, getLocation(candidate_item), 0x08);
	return();
}

trigger pathfound(0x08) {
	replyTo(this, this, "@InternalScavenger");
	if (0x00) {
		string item_name = getName(scavenge_target);
		bark(this, "I found something to scavenge...");
		bark(this, item_name);
	}
	loc there = getLocation(scavenge_target);
	int dir = getDirectionInternal(getLocation(this), there);
	curtsy(this, dir);
	if (giveItem(this, scavenge_target) == NULL()) {
		int bar = putObjContainer(scavenge_target, this);
	}
	setObjVar(this, "ScavengeLastItemGotten", scavenge_target);
	return(0x00);
}

trigger leaverange(0x05) {
	if (is_valid_player(this, target)) {
		remember_target(this, target);
	}
	return(0x01);
}

trigger enterrange(0x0A) {
	if (!is_valid_player(this, target)) {
		return(0x01);
	}
	if (0x00) {
		debugMessage("Someone is approaching.");
	}
	update_fame_memory(this, target, 0x00);
	return(0x01);
}

trigger 0x012C enterrange(0x05) {
	if (!is_valid_player(this, target)) {
		return(0x01);
	}
	if (!isFacingPerson(this, target)) {
		return(0x01);
	}
	if (is_notable_target(this, target)) {
		if (0x00) {
			debugMessage("Issuing greeting message.");
			bark(this, "Hello, I recognize you.");
		}
		if (getNotoriety(target) > 0x5A) {
			int direction = getDirectionInternal(getLocation(this), getLocation(target));
			if (getSex(this) == 0x00) {
				bow_equipped(this, direction);
			} else {
				curtsy(this, direction);
			}
		}
		replyTo(this, target, "@InternalRecognition");
		begin_convo_pause(this);
	}
	if (!is_tile_clear(this, this)) {
		return(0x01);
	}
	if (hasObjVar(this, "myJobLocation")) {
		loc myJobLocation = getObjVar(this, "myJobLocation");
		if (getDistanceInTiles(getLocation(this), myJobLocation) > 0x10) {
			return(0x01);
		}
	}
	if (isShopkeeper(this)) {
		replyTo(this, target, "@InternalGreeting");
		begin_convo_pause(this);
	}
	return(0x01)}

trigger creation {
	int hue = random(0x01, 0xC8);
	int hue_factor = 0x05;
	hue = (hue * hue_factor) - 0x01 + random(0x00, 0x02);
	setDefaultTextHue(this, hue);
	if (!isShopkeeper(this)) {
		return(0x01);
	}
	loc home_loc = getLocation(this);
	setObjVar(this, "myJobLocation", home_loc);
	if (0x00) {
		bark(this, "Setting my job location.");
	}
	string myHomeShop;
	if (getSmallestArea(myHomeShop, home_loc)) {
		setObjVar(this, "myHomeShop", myHomeShop);
	}
	callBack(this, 0x64, 0x0C);
	setLoiterMode(this, 0x01);
	setBehavior(this, 0x02);
	return(0x01);
}

trigger callback(0x0C) {
	if (0x00) {
		bark(this, "Doing my job activity.");
		if (!hasObjVar(this, "myJobLocation")) {
			bark(this, "I am missing my job location.");
		}
		loc job_loc = getObjVar(this, "myJobLocation");
		int x = getX(job_loc);
		int y = getY(job_loc);
		string x_str = x;
		string y_str = y;
		string place = "My job location is " + x_str + ", " + y_str + ".";
		bark(this, place);
	}
	int hour = getHour();
	if (hasObjVar(this, "myJobLocation")) {
		loc there = getObjVar(this, "myJobLocation");
		walkTo(this, there, 0x0D);
		if (0x00) {
			debugMessage("Walking back to my job location.");
		}
	}
	callBack(this, 0x64, 0x0C);
	return(0x01);
}

function int handle_train_speech(obj this, obj speaker, string arg) {
	if (!check_convo_eligibility(this, speaker, arg)) {
		return(0x01);
	}
	list speech_words;
	split(speech_words, arg);
	int found_train = 0x00;
	if (isInList(speech_words, "train")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "training")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "teach")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "teaching")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "learn")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "learning")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "practice")) {
		found_train = 0x01;
	}
	if (isInList(speech_words, "practicing")) {
		found_train = 0x01;
	}
	if (!found_train) {
		return(0x01);
	}
	int found_skill = 0x00;
	list skill_keywords = "parrying", "parry", "battle", "defense", "first", "aid", "heal", "healing", "medicine", "hide", "hiding", "steal", "stealing", "alchemy", "anatomy", "animal", "lore", "appraise", "item", "identification", "identify", "armslore", "arms", "beg", "begging", "blacksmith", "smith", "blacksmithy", "smithing", "blacksmithing", "bowyer", "bow", "arrow", "fletcher", "bowcraft", "fletching", "calm", "peace", "peacemaking", "camp", "camping", "carpentry", "woodwork", "woodworking", "cartography", "map", "mapmaking", "cooking", "cook", "detect", "hidden", "entice", "enticement", "enticing", "evaluate", "intelligence", "evaluating", "fish", "fishing", "incite", "provoke", "provoking", "provocation", "lockpicking", "lock", "pick", "picking", "locks", "magic", "magery", "sorcery", "wizardry", "mage", "resist", "resisting", "spells", "battle", "tactic", "tactics", "fight", "fighting", "peek", "peeking", "snoop", "snooping", "play", "instrument", "playing", "musician", "musicianship", "poisoning", "poison", "ranged", "missile", "missiles", "shoot", "shooting", "archery", "archer", "spirit", "ghost", "seance", "spiritualism", "tailoring", "tailor", "clothier", "tame", "animal", "animals", "taming", "taste", "tasting", "tinker", "tinkering", "vet", "veterinarian", "forensic", "forensics", "herd", "herding", "tracking", "track", "hunt", "hunting", "inscribe", "scroll", "inscribing", "inscription", "sword", "swords", "blade", "blades", "swordsman", "swordsmanship", "club", "clubs", "mace", "maces", "dagger", "daggers", "fence", "fencing", "hand", "wrestle", "wrestling";
	string keyword;
	string matched_keyword;
	for (int i = 0x00; i < numInList(skill_keywords); i++) {
		keyword = skill_keywords[i];
		if (isInList(speech_words, keyword)) {
			found_skill = 0x01;
			matched_keyword = keyword;
		}
	}
	if (!found_skill) {
		list responses;
		responses = "If thy desire is to learn, thou must say what thou wishest to learn.", "I cannot teach thee if thou dost not name what to learn!", "Without the name of a skill, 'tis difficult for me to teach thee.", "If thou namest a skill or ability, perhaps I can aid thee.", "If thou art desirous of practice in a craft or skill, name it when thou askest for aid.";
		if (getIntelligence(this) > 0x46) {
			responses = "'Tis a noble endeavor to seek to improve thyself. Perhaps if thou couldst name the particular skill thou seekest to improve?", "If thou failest to name what thou desirest me to teach, I cannot fulfill thy desire!", "'Tis a difficult task to instruct thee in mine arts, if thou dost not specify which of said arts thou seekest to master.", "If thou wouldst name the skill when thou askest, I could, perchance, aid thee.", "I presume that thou art on a quest to locate teachers of some ability. If this is indeed thy desire, name the skill as part of thy inquiry.";
		}
		if (getIntelligence(this) < 0x23) {
			responses = "I dunno what thou wishest to learn.", "If thou dost not tell me what thou'rt wantin' to learn, well...", "'Tis hard to teach thee without the name of the skill.", "I mebbe could help thee, methinks, if thou namest what thou'rt wishin' to learn.", "If thou wantest to learn a skill, thou needest name it when thou'rt askin'.";
		}
		string response = responses[random(0x00, 0x04)];
		bark(this, response);
		begin_convo_pause(this);
		list teachable_skills;
		string skills_str = "I can teach thee of ";
		if (0x00) {
			bark(this, "All known skill slots...");
		}
		for (int slot = 0x00; slot < (0x2E - 0x01); slot++) {
			if (0x00) {
				string slot_str = slot;
				if (getSkillLevel(this, slot) > 0x01) {
					bark(this, "Have slot #" + slot_str);
				}
			} else {
				if (getSkillLevel(this, slot) > getSkillLevel(speaker, slot)) {
					appendToList(teachable_skills, slot);
				}
			}
		}
		if (numInList(teachable_skills) == 0x00) {
			bark(this, "Alas, I cannot teach thee anything.");
			begin_convo_pause(this);
			return(0x00);
		}
		for (slot = 0x00; slot < numInList(teachable_skills); slot++) {
			if (slot != 0x00) {
				skills_str = skills_str + ", ";
			}
			if (slot == (numInList(teachable_skills) - 0x01)) {
				skills_str = skills_str + "and ";
			}
			switch(teachable_skills[slot]) {
			case 0x00
				skills_str = skills_str + "alchemy";
				break;
			case 0x01
				skills_str = skills_str + "anatomy";
				break;
			case 0x02
				skills_str = skills_str + "animal lore";
				break;
			case 0x03
				skills_str = skills_str + "appraising and identifying items";
				break;
			case 0x04
				skills_str = skills_str + "arms lore";
				break;
			case 0x05
				skills_str = skills_str + "parrying attacks";
				break;
			case 0x06
				skills_str = skills_str + "begging";
				break;
			case 0x07
				skills_str = skills_str + "blacksmithing";
				break;
			case 0x08
				skills_str = skills_str + "the making of bows and fletching of arrows";
				break;
			case 0x09
				skills_str = skills_str + "peacemaking";
				break;
			case 0x0A
				skills_str = skills_str + "camping in the wilderness";
				break;
			case 0x0B
				skills_str = skills_str + "carpentry";
				break;
			case 0x0C
				skills_str = skills_str + "cartography and the making of maps";
				break;
			case 0x0D
				skills_str = skills_str + "cooking";
				break;
			case 0x0E
				skills_str = skills_str + "detecting hidden people";
				break;
			case 0x0F
				skills_str = skills_str + "enticing folk with music";
				break;
			case 0x10
				skills_str = skills_str + "evaluating people's intelligence";
				break;
			case 0x11
				skills_str = skills_str + "basic healing";
				break;
			case 0x12
				skills_str = skills_str + "fishing";
				break;
			case 0x13
				skills_str = skills_str + "forensic evaluation";
				break;
			case 0x14
				skills_str = skills_str + "herding animals";
				break;
			case 0x15
				skills_str = skills_str + "hiding in plain sight";
				break;
			case 0x16
				skills_str = skills_str + "provoking anger and causing fights";
				break;
			case 0x17
				skills_str = skills_str + "inscribing scrolls and books";
				break;
			case 0x18
				skills_str = skills_str + "picking locks";
				break;
			case 0x19
				skills_str = skills_str + "magery";
				break;
			case 0x1A
				skills_str = skills_str + "resisting magic spells";
				break;
			case 0x1B
				skills_str = skills_str + "battle tactics";
				break;
			case 0x1C
				skills_str = skills_str + "snooping in backpacks";
				break;
			case 0x1D
				skills_str = skills_str + "musicianship";
				break;
			case 0x1E
				skills_str = skills_str + "the deadly art of poisoning";
				break;
			case 0x1F
				skills_str = skills_str + "archery";
				break;
			case 0x20
				skills_str = skills_str + "spirit talking";
				break;
			case 0x21
				skills_str = skills_str + "stealing";
				break;
			case 0x22
				skills_str = skills_str + "tailoring";
				break;
			case 0x23
				skills_str = skills_str + "taming wild animals";
				break;
			case 0x24
				skills_str = skills_str + "food tasting";
				break;
			case 0x25
				skills_str = skills_str + "tinkering";
				break;
			case 0x26
				skills_str = skills_str + "tracking";
				break;
			case 0x27
				skills_str = skills_str + "veterinary healing";
				break;
			case 0x28
				skills_str = skills_str + "swordsmanship";
				break;
			case 0x29
				skills_str = skills_str + "clubs and maces";
				break;
			case 0x2A
				skills_str = skills_str + "fencing and daggers";
				break;
			case 0x2B
				skills_str = skills_str + "hand to hand combat and wrestling";
				break;
			default
				skills_str = skills_str + "idle chattering";
				break;
			}
		}
		skills_str = skills_str + ".";
		bark(this, skills_str);
		return(0x00);
	}
	int skill_id = 0xFF;
	if (matched_keyword == "battle") {
		skill_id = 0x05;
	}
	if (matched_keyword == "defense") {
		skill_id = 0x05;
	}
	if (matched_keyword == "parry") {
		skill_id = 0x05;
	}
	if (matched_keyword == "parrying") {
		skill_id = 0x05;
	}
	if (matched_keyword == "first") {
		skill_id = 0x11;
	}
	if (matched_keyword == "aid") {
		skill_id = 0x11;
	}
	if (matched_keyword == "heal") {
		skill_id = 0x11;
	}
	if (matched_keyword == "healing") {
		skill_id = 0x11;
	}
	if (matched_keyword == "medicine") {
		skill_id = 0x11;
	}
	if (matched_keyword == "hide") {
		skill_id = 0x15;
	}
	if (matched_keyword == "hiding") {
		skill_id = 0x15;
	}
	if (matched_keyword == "steal") {
		skill_id = 0x21;
	}
	if (matched_keyword == "stealing") {
		skill_id = 0x21;
	}
	if (matched_keyword == "alchemy") {
		skill_id = 0x00;
	}
	if (matched_keyword == "anatomy") {
		skill_id = 0x01;
	}
	if (matched_keyword == "animal") {
		skill_id = 0x02;
	}
	if (matched_keyword == "lore") {
		skill_id = 0x02;
	}
	if (matched_keyword == "appraise") {
		skill_id = 0x03;
	}
	if (matched_keyword == "identify") {
		skill_id = 0x03;
	}
	if (matched_keyword == "identification") {
		skill_id = 0x03;
	}
	if (matched_keyword == "item") {
		skill_id = 0x03;
	}
	if (matched_keyword == "armslore") {
		skill_id = 0x04;
	}
	if (matched_keyword == "arms") {
		skill_id = 0x04;
	}
	if (matched_keyword == "beg") {
		skill_id = 0x06;
	}
	if (matched_keyword == "begging") {
		skill_id = 0x06;
	}
	if (matched_keyword == "blacksmith") {
		skill_id = 0x07;
	}
	if (matched_keyword == "blacksmithy") {
		skill_id = 0x07;
	}
	if (matched_keyword == "blacksmithing") {
		skill_id = 0x07;
	}
	if (matched_keyword == "smith") {
		skill_id = 0x07;
	}
	if (matched_keyword == "smithing") {
		skill_id = 0x07;
	}
	if (matched_keyword == "bowyer") {
		skill_id = 0x08;
	}
	if (matched_keyword == "bowcraft") {
		skill_id = 0x08;
	}
	if (matched_keyword == "bow") {
		skill_id = 0x08;
	}
	if (matched_keyword == "arrow") {
		skill_id = 0x08;
	}
	if (matched_keyword == "fletcher") {
		skill_id = 0x08;
	}
	if (matched_keyword == "fletching") {
		skill_id = 0x08;
	}
	if (matched_keyword == "calm") {
		skill_id = 0x09;
	}
	if (matched_keyword == "peace") {
		skill_id = 0x09;
	}
	if (matched_keyword == "peacemaking") {
		skill_id = 0x09;
	}
	if (matched_keyword == "camp") {
		skill_id = 0x0A;
	}
	if (matched_keyword == "camping") {
		skill_id = 0x0A;
	}
	if (matched_keyword == "carpentry") {
		skill_id = 0x0B;
	}
	if (matched_keyword == "woodwork") {
		skill_id = 0x0B;
	}
	if (matched_keyword == "woodworking") {
		skill_id = 0x0B;
	}
	if (matched_keyword == "cartography") {
		skill_id = 0x0C;
	}
	if (matched_keyword == "map") {
		skill_id = 0x0C;
	}
	if (matched_keyword == "mapmaking") {
		skill_id = 0x0C;
	}
	if (matched_keyword == "cooking") {
		skill_id = 0x0D;
	}
	if (matched_keyword == "cook") {
		skill_id = 0x0D;
	}
	if (matched_keyword == "detect") {
		skill_id = 0x0E;
	}
	if (matched_keyword == "detecting") {
		skill_id = 0x0E;
	}
	if (matched_keyword == "hidden") {
		skill_id = 0x0E;
	}
	if (matched_keyword == "entice") {
		skill_id = 0x0F;
	}
	if (matched_keyword == "enticement") {
		skill_id = 0x0F;
	}
	if (matched_keyword == "evaluate") {
		skill_id = 0x10;
	}
	if (matched_keyword == "evaluating") {
		skill_id = 0x10;
	}
	if (matched_keyword == "intelligence") {
		skill_id = 0x10;
	}
	if (matched_keyword == "fish") {
		skill_id = 0x12;
	}
	if (matched_keyword == "fishing") {
		skill_id = 0x12;
	}
	if (matched_keyword == "incite") {
		skill_id = 0x16;
	}
	if (matched_keyword == "provoke") {
		skill_id = 0x16;
	}
	if (matched_keyword == "provoking") {
		skill_id = 0x16;
	}
	if (matched_keyword == "provocation") {
		skill_id = 0x16;
	}
	if (matched_keyword == "lockpicking") {
		skill_id = 0x18;
	}
	if (matched_keyword == "lock") {
		skill_id = 0x18;
	}
	if (matched_keyword == "pick") {
		skill_id = 0x18;
	}
	if (matched_keyword == "picking") {
		skill_id = 0x18;
	}
	if (matched_keyword == "locks") {
		skill_id = 0x18;
	}
	if (matched_keyword == "magic") {
		skill_id = 0x19;
	}
	if (matched_keyword == "magery") {
		skill_id = 0x19;
	}
	if (matched_keyword == "mage") {
		skill_id = 0x19;
	}
	if (matched_keyword == "sorcery") {
		skill_id = 0x19;
	}
	if (matched_keyword == "wizardry") {
		skill_id = 0x19;
	}
	if (matched_keyword == "resist") {
		skill_id = 0x1A;
	}
	if (matched_keyword == "resisting") {
		skill_id = 0x1A;
	}
	if (matched_keyword == "spells") {
		skill_id = 0x1A;
	}
	if (matched_keyword == "battle") {
		skill_id = 0x1B;
	}
	if (matched_keyword == "tactic") {
		skill_id = 0x1B;
	}
	if (matched_keyword == "tactics") {
		skill_id = 0x1B;
	}
	if (matched_keyword == "fighting") {
		skill_id = 0x1B;
	}
	if (matched_keyword == "fight") {
		skill_id = 0x1B;
	}
	if (matched_keyword == "peek") {
		skill_id = 0x1C;
	}
	if (matched_keyword == "peeking") {
		skill_id = 0x1C;
	}
	if (matched_keyword == "snooping") {
		skill_id = 0x1C;
	}
	if (matched_keyword == "snoop") {
		skill_id = 0x1C;
	}
	if (matched_keyword == "play") {
		skill_id = 0x1D;
	}
	if (matched_keyword == "playing") {
		skill_id = 0x1D;
	}
	if (matched_keyword == "instrument") {
		skill_id = 0x1D;
	}
	if (matched_keyword == "musician") {
		skill_id = 0x1D;
	}
	if (matched_keyword == "musicianship") {
		skill_id = 0x1D;
	}
	if (matched_keyword == "poisoning") {
		skill_id = 0x1E;
	}
	if (matched_keyword == "poison") {
		skill_id = 0x1E;
	}
	if (matched_keyword == "ranged") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "missile") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "missiles") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "shoot") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "shooting") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "archery") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "archer") {
		skill_id = 0x1F;
	}
	if (matched_keyword == "spirit") {
		skill_id = 0x20;
	}
	if (matched_keyword == "ghost") {
		skill_id = 0x20;
	}
	if (matched_keyword == "ghosts") {
		skill_id = 0x20;
	}
	if (matched_keyword == "seance") {
		skill_id = 0x20;
	}
	if (matched_keyword == "spiritualism") {
		skill_id = 0x20;
	}
	if (matched_keyword == "spiritualism") {
		skill_id = 0x20;
	}
	if (matched_keyword == "tailoring") {
		skill_id = 0x22;
	}
	if (matched_keyword == "tailor") {
		skill_id = 0x22;
	}
	if (matched_keyword == "clothier") {
		skill_id = 0x22;
	}
	if (matched_keyword == "tame") {
		skill_id = 0x23;
	}
	if (matched_keyword == "taming") {
		skill_id = 0x23;
	}
	if (matched_keyword == "animal") {
		skill_id = 0x23;
	}
	if (matched_keyword == "animals") {
		skill_id = 0x23;
	}
	if (matched_keyword == "taste") {
		skill_id = 0x24;
	}
	if (matched_keyword == "tasting") {
		skill_id = 0x24;
	}
	if (matched_keyword == "tinker") {
		skill_id = 0x25;
	}
	if (matched_keyword == "tinkering") {
		skill_id = 0x25;
	}
	if (matched_keyword == "vet") {
		skill_id = 0x27;
	}
	if (matched_keyword == "veterinarian") {
		skill_id = 0x27;
	}
	if (matched_keyword == "veterinary") {
		skill_id = 0x27;
	}
	if (matched_keyword == "forensic") {
		skill_id = 0x13;
	}
	if (matched_keyword == "forensics") {
		skill_id = 0x13;
	}
	if (matched_keyword == "herd") {
		skill_id = 0x14;
	}
	if (matched_keyword == "herding") {
		skill_id = 0x14;
	}
	if (matched_keyword == "track") {
		skill_id = 0x26;
	}
	if (matched_keyword == "tracking") {
		skill_id = 0x26;
	}
	if (matched_keyword == "hunt") {
		skill_id = 0x26;
	}
	if (matched_keyword == "hunting") {
		skill_id = 0x26;
	}
	if (matched_keyword == "inscribe") {
		skill_id = 0x17;
	}
	if (matched_keyword == "scroll") {
		skill_id = 0x17;
	}
	if (matched_keyword == "inscribing") {
		skill_id = 0x17;
	}
	if (matched_keyword == "inscription") {
		skill_id = 0x17;
	}
	if (matched_keyword == "sword") {
		skill_id = 0x28;
	}
	if (matched_keyword == "swords") {
		skill_id = 0x28;
	}
	if (matched_keyword == "blade") {
		skill_id = 0x28;
	}
	if (matched_keyword == "blades") {
		skill_id = 0x28;
	}
	if (matched_keyword == "swordsman") {
		skill_id = 0x28;
	}
	if (matched_keyword == "swordsmanship") {
		skill_id = 0x28;
	}
	if (matched_keyword == "club") {
		skill_id = 0x29;
	}
	if (matched_keyword == "clubs") {
		skill_id = 0x29;
	}
	if (matched_keyword == "mace") {
		skill_id = 0x29;
	}
	if (matched_keyword == "maces") {
		skill_id = 0x29;
	}
	if (matched_keyword == "dagger") {
		skill_id = 0x2A;
	}
	if (matched_keyword == "daggers") {
		skill_id = 0x2A;
	}
	if (matched_keyword == "fence") {
		skill_id = 0x2A;
	}
	if (matched_keyword == "fencing") {
		skill_id = 0x2A;
	}
	if (matched_keyword == "hand") {
		skill_id = 0x2B;
	}
	if (matched_keyword == "wrestle") {
		skill_id = 0x2B;
	}
	if (matched_keyword == "wrestling") {
		skill_id = 0x2B;
	}
	if (skill_id == 0xFF) {
		if (0x00) {
			bark(this, "Somehow I recognized a skill keyword but didn't see it the second time I checked...");
		}
		return(0x00);
	}
	if (getSkillLevel(this, skill_id) < 0x0A) {
		if (0x00) {
			bark(this, matched_keyword);
		}
		bark(this, "'Tis not something I can teach thee of.");
		begin_convo_pause(this);
		return(0x00);
	}
	if (getSkillLevel(this, skill_id) < getSkillLevel(speaker, skill_id)) {
		bark(this, "I cannot teach thee, for thou knowest more than I!");
		begin_convo_pause(this);
		return(0x00);
	}
	int skill_diff = (getSkillLevel(this, skill_id) - getSkillLevel(speaker, skill_id));
	if (skill_diff < 0x01) {
		bark(this, "I cannot teach thee, for thou knowest all I can teach!");
		begin_convo_pause(this);
		return(0x00);
	}
	skill_diff = skill_diff * 0x0A;
	string cost_str = skill_diff;
	string msg = "I can teach thee, for a fee. For " + cost_str + " gold coins, I can teach thee all I know. For less, I shall teach thee less.";
	bark(this, msg);
	begin_convo_pause(this);
	setObjVar(this, "trainerSkillToTeach", skill_id);
	setObjVar(speaker, "trainingSkillToLearn", skill_id);
	return(0x00);
}

function int handle_name_speech(obj this, obj speaker, string arg) {
	list args;
	int i;
	int found;
	if (!check_convo_eligibility(this, speaker, arg)) {
		return(0x01);
	}
	split(args, arg);
	list known_names;
	list memoryRecent;
	list memoryNotoriety;
	if (hasObjVar(this, "memoryRecent")) {
		getObjListVar(memoryRecent, this, "memoryRecent");
	}
	if (hasObjVar(this, "memoryNotoriety")) {
		getObjListVar(memoryNotoriety, this, "memoryNotoriety");
	}
	copyList(known_names, memoryRecent);
	if (0x00) {
		debugMessage("Added recent memory to the names check list.");
	}
	list memory_entry;
	obj person;
	int num_entries = numInList(memoryNotoriety);
	for (i = 0x00; i < num_entries; i++) {
		copyList(memory_entry, memoryNotoriety[i]);
		person = memory_entry[0x00];
		appendToList(known_names, person);
		if (0x00) {
			debugMessage("Added a name from fame memory to the names check list.");
		}
	}
	int j;
	found = 0x00;
	string spoken_word;
	string known_name;
	for (i = 0x00; i < numInList(args); i++) {
		spoken_word = args[i];
		for (j = 0x00; j < numInList(known_names); j++) {
			known_name = getName(known_names[j]);
			if (spoken_word == known_name) {
				found = 0x01;
				break;
			}
		}
	}
	if (!found) {
		found = check_murder_witness(arg);
	}
	if (found) {
		if (0x00) {
			debugMessage("Recognized a name in speech.");
		}
		spoken_word = getName(known_names[j]);
		string speaker_name = getName(speaker);
		if (spoken_word != speaker_name) {
			replyTo(this, known_names[j], "@InternalNameRecognition");
			begin_convo_pause(this);
			if (0x00) {
				debugMessage("doing Convo Pause");
			}
			obj recognized = known_names[j];
			string msg = getHeShe(recognized) + " is " + getDirection(getLocation(this), getLocation(recognized)) + ".";
			toUpper(msg, 0x00, 0x01);
			bark(this, msg);
			if (getDistance(getLocation(this), getLocation(recognized)) == "right here") {
				msg = "Just turn around and look.";
			} else {
				if (getDistance(getLocation(this), getLocation(recognized)) == "a long journey") {
					msg = "Just turn around and look.";
				} else {
					msg = getHeShe(recognized) + " is " + getDistance(getLocation(this), getLocation(recognized)) + " from here.";
					toUpper(msg, 0x00, 0x01);
					bark(this, msg);
				}
			}
			return(0x00);
		}
		if (0x00) {
			bark(this, "Speaker asked about himself.");
		}
	}
	return(0x01);
}

function int handle_need_speech(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	int found = 0x00;
	int result;
	string bar;
	list resources;
	list tmp_resources;
	string matched_resource;
	if (getResourcesOnObj(this, 0x00, tmp_resources)) {
		copyList(resources, tmp_resources);
	}
	if (getResourcesOnObj(this, 0x02, tmp_resources)) {
		for (int i = 0x00; i < (numInList(tmp_resources) - 0x01); i++) {
			bar = tmp_resources[i];
			appendToList(resources, bar);
		}
	}
	string word;
	for (i = 0x00; i < numInList(resources); i++) {
		for (int j = 0x00; j < numInList(args); j++) {
			bar = resources[i];
			word = args[j];
			if (bar == word) {
				found = 0x01;
				matched_resource = resources[i];
			}
		}
	}
	if (found) {
		if (0x00) {
			bark(this, "Found something!");
			bark(this, matched_resource);
		}
		bar = matched_resource;
		if (getResource(result, this, matched_resource, 0x00, 0x02)) {
			bar = getResourceName(matched_resource, 0x00);
		} else {
			if (getResource(result, this, matched_resource, 0x02, 0x02)) {
				bar = getResourceName(matched_resource, 0x02);
			}
		}
		setObjVar(this, "CurrentNeedString", bar);
		replyTo(this, speaker, "@InternalNeedResponse");
		begin_convo_pause(this);
		return(0x00);
	}
	return(0x01);
}

function int handle_time_query(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	if (isInList(args, "time")) {
		string time_str;
		int hour;
		string hour_name;
		int minute_interval;
		string minute_phrase;
		int on_the_hour = 0x00;
		minute_interval = getMinute();
		hour = getHour();
		minute_interval = minute_interval / 0x05;
		switch(minute_interval) {
		case 0x00
			minute_phrase = "";
			on_the_hour = 0x01;
			break;
		case 0x01
			minute_phrase = "a few minutes past";
			break;
		case 0x02
			minute_phrase = "ten past";
			break;
		case 0x03
			minute_phrase = "quarter past";
			break;
		case 0x04
			minute_phrase = "twenty minutes past";
			break;
		case 0x05
			minute_phrase = "a few minutes shy of half-past";
			break;
		case 0x06
			minute_phrase = "half-past";
			break;
		case 0x07
			minute_phrase = "just over half-past";
			break;
		case 0x08
			minute_phrase = "lacking twenty minutes until";
			hour = hour + 0x01;
			break;
		case 0x09
			minute_phrase = "quarter of";
			hour = hour + 0x01;
			break;
		case 0x0A
			minute_phrase = "ten of";
			hour = hour + 0x01;
			break;
		case 0x0B
			minute_phrase = "almost";
			hour = hour + 0x01;
			on_the_hour = 0x01;
			break;
		case 0x0C
			minute_phrase = "";
			on_the_hour = 0x01;
			break;
		default
			minute_phrase = "no known minutes!";
			break;
		}
		if (hour > 0x17) {
			hour = 0x00;
		}
		switch(hour) {
		default
			hour_name = "no known hour!";
			break;
		case 0x00
			hour_name = "midnight";
			on_the_hour = 0x00;
			break;
		case 0x0C
			hour_name = "noon";
			on_the_hour = 0x00;
			break;
		case 0x01
		case 0x0D
			hour_name = "one";
			break;
		case 0x02
		case 0x0E
			hour_name = "two";
			break;
		case 0x03
		case 0x0F
			hour_name = "three";
			break;
		case 0x04
		case 0x10
			hour_name = "four";
			break;
		case 0x05
		case 0x11
			hour_name = "five";
			break;
		case 0x06
		case 0x12
			hour_name = "six";
			break;
		case 0x07
		case 0x13
			hour_name = "seven";
			break;
		case 0x08
		case 0x14
			hour_name = "eight";
			break;
		case 0x09
		case 0x15
			hour_name = "nine";
			break;
		case 0x0A
		case 0x16
			hour_name = "ten";
			break;
		case 0x0B
		case 0x17
			hour_name = "eleven";
			break;
		}
		if (on_the_hour) {
			hour_name = hour_name + " o'clock";
		}
		if ((hour > 0x00) && (hour < 0x0B)) {
			hour_name = hour_name + " in the morning";
		}
		if ((hour > 0x0C) && (hour < 0x15)) {
			hour_name = hour_name + " in the afternoon";
		}
		if (hour > 0x14) {
			hour_name = hour_name + " at night";
		}
		time_str = "It is " + minute_phrase + " " + hour_name + ".";
		bark(this, time_str);
		begin_convo_pause(this);
		return(0x00);
	}
	return(0x01);
}

function int handle_location_query(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	int found = 0x00;
	string word;
	list tmp_list;
	int where_idx;
	for (int i = 0x00; i < numInList(args); i++) {
		word = args[i];
		if (word == "where") {
			found = 0x01;
			if (0x00) {
				bark(this, "Being asked where something is.");
			}
			where_idx = i;
		}
	}
	if (!found) {
		return(0x01);
	}
	;
	string area_key = "nothing";
	int is_landmark = 0x00;
	found = 0x00;
	int is_singular = 0x01;
	for (i = where_idx; i < numInList(args); i++) {
		word = args[i];
		if (word == "shrine") {
			area_key = "shrine";
			is_landmark = 0x01;
			is_singular = 0x00;
			found = 0x01;
		}
		if (word == "britain") {
			area_key = "city_britain";
			word = "city of Britain";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "buccaneer") {
			area_key = "city_bucden";
			word = "island known as Buccaneer's Den";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "jhelom") {
			area_key = "city_jhelom";
			word = "city of Jhelom";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "magincia") {
			area_key = "city_magincia";
			word = "city of Magincia";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "vesper") {
			area_key = "city_vesper";
			word = "lovely city of Vesper";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "minoc") {
			area_key = "city_minoc";
			word = "rustic town of Minoc";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "moonglow") {
			area_key = "city_moonglow";
			word = "magical city of Moonglow";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "nujel") {
			area_key = "city_nujelm";
			word = "city of Nujel'm";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "ocllo") {
			area_key = "city_ocllo";
			word = "strange land called Ocllo";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "serpent") {
			area_key = "city_serphold";
			word = "fortress called Serpent's Hold";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "skara") {
			area_key = "city_skara";
			word = "town of Skara Brae";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "trinsic") {
			area_key = "city_trinsic";
			word = "walled city of Trinsic";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "yew") {
			area_key = "city_yew";
			word = "city of Yew";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "cove") {
			area_key = "city_cove";
			word = "township of Cove";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "abbey") {
			area_key = "abbey";
			word = "Empath Abbey";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "alchemist") {
			area_key = "alchemist";
			found = 0x01;
		}
		if (word == "animal") {
			area_key = "animaltrainer";
			word = "animal trainer";
			found = 0x01;
		}
		if ((word == "armorer") || (word == "armourer")) {
			area_key = "armorer";
			found = 0x01;
		}
		if ((word == "artisans") || (word == "artisan")) {
			area_key = "artisansguild";
			word = "artisans guild";
			is_landmark = 0x01;
			if (word == "artisans") {
				is_singular = 0x00;
			}
			found = 0x01;
		}
		if ((word == "baker") || (word == "bakery")) {
			area_key = "baker";
			if (word == "bakery") {
				is_singular = 0x00;
			}
			found = 0x01;
		}
		if (word == "bank") {
			area_key = "bank";
			is_landmark = 0x01;
			found = 0x01;
		}
		if ((word == "bard") || (word == "bards")) {
			area_key = "bard";
			if (word == "bards") {
				is_singular = 0x00;
			}
			found = 0x01;
		}
		if ((word == "bath") || (word == "baths")) {
			area_key = "bath";
			if (word == "baths") {
				is_singular = 0x00;
			}
			found = 0x01;
		}
		if (word == "beekeeper") {
			area_key = "beekeeper";
			found = 0x01;
		}
		if ((word == "smith") || (word == "blacksmith")) {
			area_key = "blacksmith";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "blackthorn") {
			area_key = "blackthornkeep";
			word == "Blackthorn's keep";
			is_landmark = 0x01;
			found = 0x01;
		}
		if ((word == "bowyer") || (word == "fletcher")) {
			area_key = "bowyer";
			found = 0x01;
		}
		if (word == "butcher") {
			area_key = "butcher";
			found = 0x01;
		}
		if (word == "carpenter") {
			area_key = "carpenter";
			found = 0x01;
		}
		if (word == "casino") {
			area_key = "casino";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "cemetery") {
			area_key = "cemetery";
			is_singular = 0x00;
			found = 0x01;
		}
		if (word == "clothier") {
			area_key = "clothier";
			found = 0x01;
		}
		if (word == "cobbler") {
			area_key = "cobbler";
			found = 0x01;
		}
		if (word == "court") {
			area_key = "court";
			found = 0x01;
			is_landmark = 0x01;
		}
		if (word == "customs") {
			area_key == "customs";
			found = 0x01;
			is_singular = 0x00;
		}
		if ((word == "docks") || (word == "dock")) {
			area_key = "docks";
			found = 0x01;
			if (word == "docks") {
				is_singular = 0x00;
			}
			is_landmark = 0x01;
		}
		if ((word == "duel") || (word == "pit")) {
			area_key = "duelpit";
			word == "dueling pit";
			found = 0x01;
		}
		if (word == "farm") {
			area_key = "farm";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "fish") {
			area_key = "fishery";
			found = 0x01;
		}
		if (word == "glassblower") {
			area_key = "glassblower";
			found = 0x01;
		}
		if ((word == "gypsy") || (word == "gypsies")) {
			area_key = "gypsy";
			if (word == "gypsies") {
				is_singular = 0x00;
			}
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "healer") {
			area_key = "healer";
			found = 0x01;
		}
		if (word == "herbalist") {
			area_key = "herbalist";
			found = 0x01;
		}
		if ((word == "inn") || (word == "hostel")) {
			area_key = "inn";
			is_landmark = 0x01;
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "jail") {
			area_key = "jail";
			found = 0x01;
		}
		if (word == "jeweler") {
			area_key = "jeweler";
			found = 0x01;
		}
		if (word == "castle") {
			area_key = "lbcastle";
			is_landmark = 0x01;
			is_singular = 0x00;
			found = 0x01;
		}
		if (word == "library") {
			area_key = "library";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "lighthouse") {
			area_key = "lighthouse";
			is_landmark = 0x01;
			is_singular = 0x00;
			found = 0x01;
		}
		if ((word == "magic") || (word == "mage")) {
			area_key = "magic";
			found = 0x01;
			word = "mage";
		}
		if (word == "merchant") {
			area_key = "merchant";
			found = 0x01;
		}
		if (word == "mill") {
			area_key = "mill";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "observatory") {
			area_key = "observatory";
			is_singular = 0x00;
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "painter") {
			area_key = "painter";
			found = 0x01;
		}
		if (word == "paladin") {
			area_key = "paladin";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "provisioner") {
			area_key = "provisioner";
			found = 0x01;
		}
		if (word == "shipwright") {
			area_key = "shipwright";
			is_landmark = 0x01;
			found = 0x01;
		}
		if ((word == "stable") || (word == "stables")) {
			area_key = "stable";
			if (word == "stables") {
				is_singular = 0x00;
			}
			found = 0x01;
		}
		if (word == "tanner") {
			area_key = "tanner";
			found = 0x01;
		}
		if ((word == "tavern") || ((word == "pub") || (word == "bar"))) {
			area_key = "tavern";
			found = 0x01;
		}
		if (word == "temple") {
			area_key = "temple";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "theater") {
			area_key = "theater";
			found = 0x01;
			is_singular = 0x00;
		}
		if (word == "tinker") {
			area_key = "tinker";
			found = 0x01;
		}
		if ((word == "vet") || (word == "veterinarian")) {
			area_key = "vet";
			found = 0x01;
		}
		if ((word == "weapons") || (word == "weaponeer")) {
			area_key = "weaponry";
			found = 0x01;
			if (word == "weapons") {
				is_singular = 0x00;
			}
		}
		if (word == "trainer") {
			area_key = "weapontrainer";
			found = 0x01;
		}
		if (word == "woodworker") {
			area_key = "woodworker";
			is_landmark = 0x01;
			found = 0x01;
		}
		if (word == "guild") {
			string first_word;
			string guild_name;
			is_landmark = 0x01;
			for (int j = 0x00; j < numInList(args); j++) {
				first_word = args[j];
				if (first_word == "bard") {
					guild_name = "bardic guild";
					area_key = "bardguild";
					found = 0x01;
				}
				if ((first_word == "fighter") || (first_word == "warrior")) {
					guild_name = "warrior's guild";
					area_key = "fighterguild";
					found = 0x01;
				}
				if (first_word == "healer") {
					guild_name = "healer's guild";
					area_key = "healer";
					found = 0x01;
				}
				if (first_word == "merchant") {
					guild_name = "merchant's guild";
					area_key = "merchantguild";
					found = 0x01;
				}
				if (first_word == "miner") {
					guild_name = "miner's guild";
					area_key = "minerguild";
					found = 0x01;
				}
				if (first_word == "ranger") {
					guild_name = "ranger's guild";
					area_key = "rangerguild";
					found = 0x01;
				}
				if (first_word == "tailor") {
					guild_name = "tailor's guild";
					area_key = "tailorguild";
					found = 0x01;
				}
				if (first_word == "tinker") {
					guild_name = "tinker's guild";
					area_key = "tinkerguild";
					found = 0x01;
				}
			}
		}
	}
	if (!found) {
		if (0x00) {
			bark(this, "Asked direction to nowhere I recognize.");
		}
		return(0x01);
	}
	string area_name;
	loc area_loc;
	loc my_loc = getLocation(this);
	found = findClosestArea(area_name, area_loc, area_key, my_loc, is_landmark);
	if (area_name == "") {
		if (guild_name == "") {
			if (is_singular == 0x00) {
				area_name = word + "s";
			} else {
				area_name = word;
			}
		} else {
			area_name = guild_name;
		}
	}
	split(args, area_name);
	first_word = args[0x00];
	if (first_word == "the") {
		word = "";
	} else {
		word = "the ";
	}
	string response = "Thou seekest " + word + area_name + "?";
	bark(this, response);
	begin_convo_pause(this);
	if (!found) {
		bark(this, "I know not where to find that.");
		return(0x00);
	}
	string direction = getDirection(my_loc, area_loc);
	string distance = getDistance(my_loc, area_loc);
	response = "'Tis " + distance + " " + direction + " from here.";
	if (distance == "right here") {
		response = "But 'tis " + distance + "! Look thee " + direction + ".";
	}
	bark(this, response);
	return(0x00);
}

trigger convofunc("GetNeed") {
	string need_str;
	if (hasObjVar(this, "CurrentNeedString")) {
		if (0x00) {
			bark(this, "I had just stored my need.");
		}
		need_str = getObjVar(this, "CurrentNeedString");
		removeObjVar(this, "CurrentNeedString");
		setConvoRet(need_str);
		return(0x00);
	}
	list food_resources;
	list desire_resources;
	list all_resources;
	int ok;
	ok = getResourcesOnObj(this, 0x00, food_resources);
	if (ok) {
		copyList(food_resources, all_resources);
	}
	ok = getResourcesOnObj(this, 0x02, desire_resources);
	string resource;
	if (ok) {
		if (numInList(all_resources) > 0x00) {
			for (int i = 0x00; i < numInList(desire_resources); i++) {
				resource = desire_resources[i];
				appendToList(all_resources, resource);
			}
		}
	}
	if (numInList(all_resources) < 0x01) {
		setConvoRet("food");
		return(0x00);
	}
	int idx;
	idx = (random(0x01, numInList(all_resources)));
	idx--;
	resource = all_resources[idx];
	int bar = getResource(ok, this, resource, 0x00, 0x00);
	if (bar) {
		resource = getResourceName(resource, 0x00);
	} else {
		resource = getResourceName(resource, 0x02);
	}
	setConvoRet(resource);
	return(0x00);
}

trigger convofunc("Leave") {
	int direction = getDirectionInternal(getLocation(talker), getLocation(this));
	faceHere(this, direction);
	removeObjVar(this, "lastSpokeTo");
	setConvoRet("");
	if (hasObjVar(this, "myBoss")) {
		list boss_list;
		getObjListVar(boss_list, this, "myBoss");
		if (!isInList(boss_list, talker)) {
			stopFollowing(this);
		}
	}
	return(0x00);
}

trigger convofunc("Attack") {
	walkTo(this, getLocation(talker), 0x09);
	attack(this, talker);
	setConvoRet("");
	return(0x00);
}

trigger convofunc("getHint") {
	setConvoRet(get_rumor(this, talker));
	return(0x00);
}

function int handle_shop_query(obj this, obj speaker, string arg) {
	if (!isShopkeeper(this)) {
		return(0x01);
	}
	loc my_loc = getLocation(this);
	loc there = getLocation(speaker);
	if (getDistanceInTiles(my_loc, there) > 0x03) {
		return(0x01);
	}
	list buy_keywords;
	list tmp_list;
	list words;
	string word;
	string keyword;
	string tmp_str;
	int tmp_int;
	int i;
	int j;
	int found;
	found = 0x00;
	buy_keywords = "buy", "trade", "commerce", "merchant", "shop", "purchase", "business", "open", "shopkeeper", "trader", "tradesman", "shopkeep";
	split(words, arg);
	for (i = 0x00; i < numInList(words); i++) {
		for (j = 0x00; j < numInList(buy_keywords); j++) {
			keyword = buy_keywords[j];
			word = words[i];
			if (word == keyword) {
				found == 0x01;
			}
		}
	}
	if (!found) {
		return(0x01);
	}
	found = 0x00;
	if (hasObjVar(this, "myJobLocation")) {
		loc myJobLocation = getObjVar(this, "myJobLocation");
		if (hasObjVar(this, "myHomeShop")) {
			string myHomeShop = getObjVar(this, "myHomeShop");
			scoreToSpace(myHomeShop);
			list home_shop_words;
			split(home_shop_words, myHomeShop);
			myHomeShop = home_shop_words[0x00];
			if (0x00) {
				bark(this, myHomeShop);
			}
			string current_area = "";
			list current_area_words;
			if (getSmallestArea(current_area, getLocation(this))) {
				scoreToSpace(current_area);
				split(current_area_words, current_area);
				current_area = current_area_words[0x00];
				if (0x00) {
					bark(this, current_area);
				}
			}
			if (current_area == myHomeShop) {
				found = 0x01;
			}
		}
		if (!found) {
			bark(this, "I am sorry, I do not have my wares here with me. Mayhap if thou didst catch me in my shop.");
			begin_convo_pause(this);
			return(0x00);
		}
	} else {
		bark(this, "Alas, I have no shop! I cannot do business with thee.");
		begin_convo_pause(this);
		return(0x00);
	}
	int guildMember = 0xFF;
	int my_guild = 0xFE;
	if (hasObjVar(this, "guildMember")) {
		my_guild = getObjVar(this, "guildMember");
	}
	if (hasObjVar(speaker, "guildMember")) {
		guildMember = getObjVar(speaker, "guildMember");
	}
	if (my_guild == guildMember) {
		bark(this, "As thou'rt of my same guild, I shall discount my wares to thee.");
		begin_convo_pause(this);
	}
	shopKeeperOpenBusiness(this, speaker);
	setObjVar(this, "wasAskedBuy", 0x01);
	begin_convo_pause(this);
	return(0x01);
}

trigger sawdeath {
	list witness_list;
	if (hasObjVar(this, "myMurderWitnessList")) {
		getObjListVar(witness_list, this, "myMurderWitnessList");
	}
	list murder_entry;
	if ((!isHuman(victim)) || (!isHuman(attacker)) || (isGuard(attacker))) {
		debugMessage("Saw death, one participant is not human, or attack is a guard.");
		return(0x00);
	}
	if (!canSeeObj(this, attacker)) {
		debugMessage("Cannot see attacker.");
		return(0x00);
	}
	if (!canSeeObj(this, victim)) {
		debugMessage("Cannot see victim.");
		return(0x00);
	}
	murder_entry = attacker, victim;
	appendToList(witness_list, murder_entry);
	if (numInList(witness_list) > 0x0A) {
		removeSpecificItem(witness_list, 0x00);
	}
	return(0x00);
}

function int check_murder_witness(string name) {
	int i;
	list witness_list;
	int match_found = 0x00;
	if (!hasObjVar(this, "myMurderWitnessList")) {
		debugMessage("No murder list.");
		return(0x00);
	}
	getObjListVar(witness_list, this, "myMurderWitnessList");
	list entry;
	string gossip_msg;
	for (i = 0x00; i < numInList(witness_list); i++) {
		copyList(entry, witness_list[i]);
		if (name == getName(entry[0x00])) {
			gossip_msg = getName(entry[0x00]) + " is a bloody murderer! I saw " + getHimHer(entry[0x00]) + " kill " + getName(entry[0x01]) + " with my own eyes!";
			match_found = 0x01;
			break;
		}
		if (name == getName(entry[0x01])) {
			gossip_msg = getName(entry[0x01]) + " was brutally slain by " + getName(entry[0x00]) + "!" + " I saw it with my own eyes!";
			match_found = 0x01;
			break;
		}
	}
	if (match_found) {
		begin_convo_pause(this);
		obj murderer = entry[0x00];
		string direction_msg = getHeShe(murderer) + " is " + getDirection(getLocation(this), getLocation(murderer)) + ".";
		bark(this, direction_msg);
		if (getDirection(getLocation(this), getLocation(murderer)) != "right here") {
			direction_msg = "It is " + getDistance(getLocation(this), getLocation(murderer)) + " from here.";
			if (getDistance(getLocation(this), getLocation(murderer)) == "right here") {
				direction_msg = "Just turn around and look.";
			}
			bark(this, direction_msg);
			return(0x01);
		}
	}
	return(0x00);
}

trigger give {
	if (mobileWillBuy(this, givenobj)) {
		bark(this, "I might be interested in buying this of thee.");
		intRet(0x00);
		return(0x01);
	}
	if (hasObjVar(this, "trainerSkillToTeach")) {
		if (0x00) {
			bark(this, "I am teaching!");
		}
		if (hasObjVar(giver, "trainingSkillToLearn")) {
			if (0x00) {
				bark(this, "And the asker is learning.");
			}
			int skill_id = getObjVar(this, "trainerSkillToTeach");
			int learn_skill = getObjVar(giver, "trainingSkillToLearn");
			removeObjVar(this, "trainerSkillToTeach");
			removeObjVar(giver, "trainingSkillToLearn");
			if (skill_id == learn_skill) {
				if (0x00) {
					bark(this, "And we agree on what to learn.");
				}
				int skill_diff;
				int has_gold = getResource(skill_diff, givenobj, "gold", 0x03, 0x02);
				if (0x00) {
					string debug_str = skill_diff;
					bark(this, debug_str);
					if (!has_gold) {
						bark(this, "Failed to get gold resource on item.");
					}
				}
				if (!has_gold) {
					bark(this, "I require gold in payment!");
					return(0x00);
				}
				if (skill_diff < 0x0A) {
					bark(this, "'Tis but a pittance! I require 10 gold at a minimum.");
					return(0x00);
				}
				skill_diff = skill_diff / 0x0A;
				if (skill_diff > 0x00) {
					if (0x00) {
						bark(this, "And I was paid.");
					}
					if (skill_diff > getSkillLevel(this, skill_id)) {
						if (0x00) {
							bark(this, "Overpaid, even.");
						}
						skill_diff = getSkillLevel(this, skill_id) - getSkillLevel(giver, skill_id);
					}
					addSkillLevel(giver, skill_id, skill_diff);
					bark(this, "Let me show thee something of how this is done.");
					begin_convo_pause(this);
					if ((isShopkeeper(this)) && (getObjType(givenobj) == 0x0EED)) {
						int deposit_ok = depositIntoBank(this, givenobj, skill_diff);
					} else {
						if (!putObjContainer(givenobj, this)) {
							if (teleport(givenobj, getLocation(this))) {
								bark(this, "A pity, I lack the hands to carry the gold!");
							} else {
								bark(this, "Here, thou mayst as well keep thy gold.");
							}
						}
					}
					systemMessage(giver, "Your skill level increases.");
					intRet(0x01);
					return(0x00);
				}
			}
		}
	}
	list item_resources;
	int magic_lvl;
	int i;
	int j;
	int result;
	int is_wanted;
	list npc_food_res;
	list npc_desire_res;
	list spare_list;
	string npc_food_key;
	string npc_desire_key;
	string spare_str;
	string item_res_key;
	string item_name;
	int is_food;
	item_name = getName(givenobj);
	if (getResourcesOnObj(givenobj, 0x03, item_resources)) {
		if (getResourcesOnObj(this, 0x00, npc_food_res)) {
			for (i = 0x00; i < numInList(npc_food_res); i++) {
				for (j = 0x00; j < numInList(item_resources); j++) {
					npc_food_key = npc_food_res[i];
					item_res_key = item_resources[j];
					if (npc_food_key == item_res_key) {
						is_food = 0x01;
						is_wanted = 0x01;
						if (0x00) {
							bark(this, "Found a food match.");
						}
						item_name = getResourceName(npc_food_key, 0x00);
					}
				}
			}
		}
		if (getResourcesOnObj(this, 0x02, npc_desire_res)) {
			for (i = 0x00; i < numInList(npc_desire_res); i++) {
				for (j = 0x00; j < numInList(item_resources); j++) {
					npc_desire_key = npc_desire_res[i];
					item_res_key = item_resources[j];
					if (npc_desire_key == item_res_key) {
						setDesireLevel(this, 0x64);
						if (0x00) {
							bark(this, "Found a desire match.");
						}
						is_wanted = 0x01;
						item_name = getResourceName(npc_desire_key, 0x02);
					}
				}
			}
		}
		string msg;
		msg = "Thou art giving me " + item_name + "?";
		bark(this, msg);
		begin_convo_pause(this);
		obj gift_obj;
		int gold_amt2;
		int ok;
		if (is_wanted) {
			if (getObjType(givenobj) == 0x0EED) {
				string gold_msg;
				ok = getResource(gold_amt2, givenobj, "gold", 0x03, 0x02);
				if (gold_amt2 > 0xFA) {
					gold_msg = "'Tis a noble gift.";
				} else {
					gold_msg = "Money is always welcome.";
				}
				bark(this, gold_msg);
			}
			begin_convo_pause(this);
			if (0x00) {
				bark(this, "Accepting item.");
			}
			if (isShopkeeper(this)) {
				if (getObjType(givenobj) == 0x0EED) {
					ok = getResource(gold_amt2, givenobj, "gold", 0x03, 0x02);
					ok = depositIntoBank(this, givenobj, gold_amt2);
					intRet(0x01);
					return(0x01);
				} else {
					result = putObjContainer(givenobj, this);
					if (!result) {
						result = teleport(givenobj, getLocation(this));
						bark(this, "Oops, I dropped it.");
					}
				}
			} else {
				result = putObjContainer(givenobj, this);
				if (!result) {
					result = teleport(givenobj, getLocation(this));
					bark(this, "Oops, I dropped it.");
				}
			}
			if (is_food) {
				bark(this, "This tasteth good.");
				list eat_sfx = 0x3C, 0x3B, 0x3A;
				sfx(getLocation(this), eat_sfx[random(0x00, 0x02)], 0x00);
			}
			list contents;
			obj item;
			obj best_magic_item;
			int best_magic_lvl = 0x00;
			list item_res;
			getContents(contents, this);
			for (i = 0x00; i < numInList(contents); i++) {
				item = contents[i];
				if (getResourcesOnObj(item, 0x03, item_res)) {
					magic_lvl = 0x00;
					result = getResource(magic_lvl, item, "magic", 0x03, 0x02);
					if (magic_lvl > best_magic_lvl) {
						best_magic_lvl = magic_lvl;
						best_magic_item = item;
					}
				}
			}
			list containers;
			getContainersOnMobile(containers, this);
			for (i = 0x00; i < numInList(containers); i++) {
				item = containers[i];
				getContents(contents, item);
				for (j = 0x00; j < numInList(contents); j++) {
					item = contents[j];
					if (getResourcesOnObj(item, 0x03, item_res)) {
						magic_lvl = 0x00;
						result = getResource(magic_lvl, item, "magic", 0x03, 0x02);
						if (magic_lvl > best_magic_lvl) {
							best_magic_lvl = magic_lvl;
							best_magic_item = item;
						}
					}
				}
			}
			gift_obj = best_magic_item;
			if (gift_obj == NULL()) {
				if (hasObjVar(this, "ScavengeLastItemGotten")) {
					obj last_item = getObjVar(this, "ScavengeLastItemGotten");
					if (hasObj(this, last_item)) {
						gift_obj = last_item;
					}
				}
			}
			if (gift_obj == NULL()) {
				i = getValue(givenobj);
				if (getObjType(givenobj) == 0x0EED) {
					i = 0x00;
				}
				if (getObjType(givenobj) == 0x0EEE) {
					i = 0x00;
				}
				if (getObjType(givenobj) == 0x0EEF) {
					i = 0x00;
				}
				if (i) {
					gift_obj = transferGenericToContainer(this, this, 0x0EED, i);
					if (gift_obj != NULL()) {
						sfx(getLocation(giver), 0x35, 0x00);
					}
				}
			}
			if (getNotoriety(this) > 0x00) {
				addNotoriety(giver, 0x05);
			} else {
				removeNotoriety(giver, 0x05);
			}
			update_fame_memory(this, giver, 0x32);
			if (hasObjVar(this, "myBoss")) {
				list boss_list;
				getObjListVar(boss_list, this, "myBoss");
				if (!isInList(boss_list, giver)) {
					stopFollowing(this);
				}
			}
			setDesireLevel(this, 0xC8);
			if (gift_obj == NULL()) {
				bark(this, "I thank thee.");
				bark(this, get_rumor(this, giver));
				intRet(0x01);
				return(0x00);
			}
			replyTo(this, giver, "@InternalAcceptItem");
			msg = "Please accept ";
			i = getObjType(gift_obj);
			msg = msg + getArticle(i);
			msg = msg + " ";
			msg = msg + getName(gift_obj);
			msg = msg + ".";
			if (giveItem(giver, gift_obj) == NULL()) {
				i = teleport(gift_obj, getLocation(giver));
			}
			bark(this, msg);
			intRet(0x01);
			return(0x00);
		}
	}
	setObjVar(this, "theItemGiven", item_name);
	if (0x00) {
		bark(this, "Refusing item.");
	}
	bark(this, "I am not interested in this.");
	replyTo(this, giver, "@InternalRefuseItem");
	if (giveItem(giver, givenobj) == NULL()) {
		bark(this, "Thy hands are full, so here 'tis, on the ground.");
		i = teleport(givenobj, getLocation(giver));
	}
	begin_convo_pause(this);
	return(0x00);
}

trigger convofunc("GetItem") {
	string theItemGiven;
	if (hasObjVar(this, "theItemGiven")) {
		theItemGiven = getObjVar(this, "theItemGiven");
		removeObjVar(this, "theItemGiven");
	} else {
		theItemGiven = "item";
	}
	setConvoRet(theItemGiven);
	return(0x00);
}

trigger gotattacked {
	update_fame_memory(this, attacker, 0x4B);
	return(0x01);
}
