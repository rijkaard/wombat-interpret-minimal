inherits human_funcs;

forward int check_murder_witness(string );

forward int has_scavenge_target(obj );

forward void scavenge_nearby_item(obj );

forward int handle_train_speech(obj , obj , string );

forward int handle_name_speech(obj , obj , string );

forward int handle_need_speech(obj , obj , string );

forward int handle_time_speech(obj , obj , string );

forward int handle_whereis_speech(obj , obj , string );

forward int handle_shopkeeper_speech(obj , obj , string );

forward int handle_move_speech(obj , obj , string );

function int handle_armageddon(int level) {
	if (level < 0x02) {
		return(0x01);
	}
	if (hasScript(this, "stables")) {
		return(0x01);
	}
	if (isShopkeeper(this)) {
		return(0x00);
	}
	return(0x01);
}

trigger message("armageddon") {
	return(handle_armageddon(args[0x00]));
}

trigger message("getMyPriceModifier") {
	int hue_factor = 0x00;
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
	int karma_adj;
	if (!getCompileFlag(0x01)) {
		karma_adj = getNotoriety(sender);
		karma_adj = karma_adj / 0x05;
	} else {
		karma_adj = getKarmaLevel(sender);
		karma_adj = karma_adj * 0x05;
	}
	hue_factor = hue_factor - karma_adj;
	int abs_modifier = hue_factor;
	if (abs_modifier < 0x00) {
		abs_modifier = abs_modifier * (0x00 - 0x01);
	}
	string x = abs_modifier;
	if (hue_factor > 0x00) {
		bark(this, "Thou'rt not welcome as a customer here. I shall charge thee a premium of " + x + " above my normal price.");
	}
	if (hue_factor < 0x00) {
		bark(this, "'Tis an honor to have thee as a patron. Please accept a discount of " + x + " on my wares!");
	}
	intRet(hue_factor);
	return(0x01);
}

trigger speech("*") {
	if (speaker == this) {
		return(0x00);
	}
	if (count_targets(this)) {
		bark(this, "I am too busy fighting to deal with thee!");
		return(0x00);
	}
	int is_direct = 0x00;
	debugMessage("Starting stock convo trigger.");
	if (0x00) {
		bark(this, "Standard convo trigger executing.");
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	is_direct = is_direct_address(arg, this);
	int unused;
	int i;
	if (!check_convo_eligibility(this, speaker, arg)) {
		if (0x00) {
			bark(this, "Failed convo facing check");
		}
		return(0x01);
	}
	debugMessage("Doing recognition of speaker.");
	if (is_notable_target(this, speaker)) {
		if (0x00) {
			debugMessage("Internal recognition keyword called.");
		}
		replyTo(this, speaker, "@InternalRecognition");
		begin_convo_pause(this);
	}
	if (!handle_shopkeeper_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_move_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_whereis_speech(this, speaker, arg)) {
		return(0x00);
	}
	if (!handle_time_speech(this, speaker, arg)) {
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
		return(0x01)}
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
	obj crowder = getObjVar(this, "StandingOnMe");
	loc crowder_loc = getLocation(crowder);
	loc my_loc = getLocation(this);
	removeObjVar(this, "StandingOnMe");
	if (getDistanceInTiles(my_loc, crowder_loc) < 0x02) {
		if (0x00) {
			bark(this, "You're standing too close, go away.");
		}
		replyTo(this, crowder, "@InternalPersonalSpace");
		setObjVar(this, "StandingOnMe", crowder);
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

trigger pathnotfound(0x06) {
	if (!hasObjVar(this, "myJobLocation")) {
		return(0x00);
	}
	loc place = getObjVar(this, "myJobLocation");
	int ok = teleport(this, place);
	return(0x00);
}

trigger creation {
	callBack(this, 0xFA, 0x0B);
	if (0x00) {
		debugMessage("Initializing scavenger behavior.");
	}
	return(0x01);
}

function int has_scavenge_target(obj this) {
	loc here = getLocation(this);
	int in_range = objIsInRange(here, 0x04);
	if (!in_range) {
		if (0x00) {
			debugMessage("Nothing nearby to scavenge.");
		}
		return(0x00);
	}
	return(0x01);
}

trigger callback(0x0B) {
	callback(this, 0x3C, 0x0B);
	if (!has_scavenge_target(this)) {
		return(0x01);
	}
	scavenge_nearby_item(this);
	return(0x01);
}

function void scavenge_nearby_item(obj this) {
	list nearby_objects;
	getObjectsInRange(nearby_objects, getLocation(this), 0x04);
	int idx = random(0x00, numInList(nearby_objects) - 0x01);
	obj m_target = nearby_objects[idx];
	if (!is_tile_clear(this, m_target)) {
		return();
	}
	if (getWeight(m_target) > 0x14) {
		if (0x00) {
			bark(this, "Tried to scavenge something too heavy. :P");
		}
		return();
	}
	if (!isMoveable(m_target, this)) {
		return();
	}
	if (is_guarded(this, m_target)) {
		return();
	}
	if (getObjType(m_target) < 0x03) {
		return();
	}
	if (hasObjVar(this, "ScavengeLastItemGotten")) {
		obj last_item = getObjVar(this, "ScavengeLastItemGotten");
		if (hasObj(this, last_item)) {
			deleteObject(last_item);
		}
	}

member obj scavenge_target = m_target;
	walkTo(this, getLocation(m_target), 0x08);
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

trigger enterrange(0x07) {
	if (!is_valid_player(this, target)) {
		return(0x01);
	}
	if (0x00) {
		debugMessage("Someone is approaching.");
	}
	update_fame_memory(this, target, 0x00);
	int scum = 0x00;
	if (!getCompileFlag(0x01)) {
		if (getNotoriety(target) < (0x00 - 0x64)) {
			scum = 0x01;
		}
	} else {
		if (isMurderer(target)) {
			scum = 0x01;
		}
	}
	if (scum) {
		faceHere(this, getDirectionInternal(getLocation(this), getLocation(target)));
		list guard_shouts = "Thou'rt scum! Guards!", "Guards! A villain!", "'Tis a villain! Guards!", "Guards! Help!", "Help! Guards! Flood, fire, famine!", "Aaaah! They will kill me! Guards!", "Arrest this scum!", "Look! 'Tis that evil one! Guards!", "Beware! 'Tis that scoundrel! Guards!", "Look thee, a criminal! Guards!", "Thy like is not welcome here! Guards! Arrest this person!", "Scum like thee is not welcome here. Guards!", "To think I saw thee and lived! Guards!", "We tolerate not those like thee! Guards!", "Get out of here, scum! Guards!", "Guards! Guards!";
		string blah = guard_shouts[random(0x00, numInList(guard_shouts) - 0x01)];
		bark(this, blah);
		callGuards(target, getLocation(target), 0x02);
	}
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
		int bow = 0x00;
		if (!getCompileFlag(0x01)) {
			if (getNotoriety(target) > 0x5A) {
				bow = 0x01;
			}
		} else {
			if (getFameLevel(target) > 0x03) {
				bow = 0x01;
			}
		}
		if (bow) {
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
	goLoiter(this, home_loc, 0x03E8);
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
	list words;
	split(words, arg);
	int is_train_request = 0x00;
	if (isInList(words, "train")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "training")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "teach")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "teaching")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "learn")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "learning")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "practice")) {
		is_train_request = 0x01;
	}
	if (isInList(words, "practicing")) {
		is_train_request = 0x01;
	}
	if (!is_train_request) {
		return(0x01);
	}
	if (isGuard(this)) {
		bark(this, "I am too busy to teach thee.");
		return(0x01);
	}
	if (hasObjListVar(this, "myBoss")) {
		bark(this, "I do not train whilst I am working.");
		return(0x01);
	}
	int found_skill = 0x00;
	list skill_keywords = "parrying", "parry", "battle", "defense", "first", "aid", "heal", "healing", "medicine", "hide", "hiding", "steal", "stealing", "alchemy", "anatomy", "animal", "lore", "appraising", "identifying", "appraise", "item", "identification", "identify", "armslore", "arms", "beg", "begging", "blacksmith", "smith", "blacksmithy", "smithing", "blacksmithing", "bowyer", "bow", "arrow", "fletcher", "bowcraft", "fletching", "calm", "peace", "peacemaking", "camp", "camping", "carpentry", "woodwork", "woodworking", "cartography", "map", "mapmaking", "cooking", "cook", "detect", "hidden", "entice", "enticement", "enticing", "evaluate", "intelligence", "evaluating", "fish", "fishing", "incite", "provoke", "provoking", "provocation", "lockpicking", "lock", "pick", "picking", "locks", "magic", "magery", "sorcery", "wizardry", "mage", "resist", "resisting", "spells", "battle", "tactic", "tactics", "fight", "fighting", "peek", "peeking", "snoop", "snooping", "play", "instrument", "playing", "musician", "musicianship", "poisoning", "poison", "ranged", "missile", "missiles", "shoot", "shooting", "archery", "archer", "spirit", "ghost", "seance", "spiritualism", "tailoring", "tailor", "clothier", "tame", "taming", "taste", "tasting", "tinker", "tinkering", "vet", "veterinarian", "forensic", "forensics", "herd", "herding", "tracking", "track", "hunt", "hunting", "inscribe", "scroll", "inscribing", "inscription", "sword", "swords", "blade", "blades", "swordsman", "swordsmanship", "club", "clubs", "mace", "maces", "dagger", "daggers", "fence", "fencing", "hand", "wrestle", "wrestlinglumberjack", "lumberjacking", "woodcutting", "mining", "mine", "smelt";
	string keyword;
	string matched_keyword;
	for (int i = 0x00; i < numInList(skill_keywords); i++) {
		keyword = skill_keywords[i];
		if (isInList(words, keyword)) {
			found_skill = 0x01;
			matched_keyword = keyword;
		}
	}
	if (!found_skill) {
		list no_skill_responses;
		no_skill_responses = "If thy desire is to learn, thou must say what thou wishest to learn.", "I cannot teach thee if thou dost not name what to learn!", "Without the name of a skill, 'tis difficult for me to teach thee.", "If thou namest a skill or ability, perhaps I can aid thee.", "If thou art desirous of practice in a craft or skill, name it when thou askest for aid.";
		if (getIntelligence(this) > 0x46) {
			no_skill_responses = "'Tis a noble endeavor to seek to improve thyself. Perhaps if thou couldst name the particular skill thou seekest to improve?", "If thou failest to name what thou desirest me to teach, I cannot fulfill thy desire!", "'Tis a difficult task to instruct thee in mine arts, if thou dost not specify which of said arts thou seekest to master.", "If thou wouldst name the skill when thou askest, I could, perchance, aid thee.", "I presume that thou art on a quest to locate teachers of some ability. If this is indeed thy desire, name the skill as part of thy inquiry.";
		}
		if (getIntelligence(this) < 0x23) {
			no_skill_responses = "I dunno what thou wishest to learn.", "If thou dost not tell me what thou'rt wantin' to learn, well...", "'Tis hard to teach thee without the name of the skill.", "I mebbe could help thee, methinks, if thou namest what thou'rt wishin' to learn.", "If thou wantest to learn a skill, thou needest name it when thou'rt askin'.";
		}
		string response = no_skill_responses[random(0x00, 0x04)];
		bark(this, response);
		begin_convo_pause(this);
		list teachable_skills;
		list teachable_levels;
		int teachable_count = 0x00;
		string teach_msg = "I can teach thee of ";
		if (0x00) {
			bark(this, "All known skill slots...");
		}
		for (int skill_idx = 0x00; skill_idx < (0x2E - 0x01); skill_idx++) {
			if (0x00) {
				string slot_str = skill_idx;
				if (getSkillLevelNoStat(this, skill_idx) > 0x01) {
					bark(this, "Have slot #" + slot_str);
				}
			}
			int npc_skill_level = getSkillLevelNoStat(this, skill_idx);
			if (npc_skill_level > (getSkillLevelNoStat(speaker, skill_idx) * 0x03)) {
				if (teachable_count < 0x05) {
					appendToList(teachable_skills, skill_idx);
					appendToList(teachable_levels, npc_skill_level);
					teachable_count++;
				} else {
					int min_idx = 0x00;
					for (int j = 0x01; j < 0x05; j++) {
						if ((teachable_levels[j]) < (teachable_levels[min_idx])) {
							min_idx = j;
						}
					}
					if ((teachable_levels[min_idx]) < npc_skill_level) {
						setItem(teachable_skills, skill_idx, min_idx);
						setItem(teachable_levels, npc_skill_level, min_idx);
					}
				}
			}
		}
		if (teachable_count == 0x00) {
			bark(this, "Alas, I cannot teach thee anything.");
			begin_convo_pause(this);
			return(0x00);
		}
		for (skill_idx = 0x00; skill_idx < teachable_count; skill_idx++) {
			if (skill_idx != 0x00) {
				teach_msg = teach_msg + ", ";
			}
			if (skill_idx == (teachable_count - 0x01)) {
				teach_msg = teach_msg + "and ";
			}
			switch(teachable_skills[skill_idx]) {
			case 0x00
				teach_msg = teach_msg + "alchemy";
				break;
			case 0x01
				teach_msg = teach_msg + "anatomy";
				break;
			case 0x02
				teach_msg = teach_msg + "animal lore";
				break;
			case 0x03
				teach_msg = teach_msg + "appraising and identifying items";
				break;
			case 0x04
				teach_msg = teach_msg + "arms lore";
				break;
			case 0x05
				teach_msg = teach_msg + "parrying attacks";
				break;
			case 0x06
				teach_msg = teach_msg + "begging";
				break;
			case 0x07
				teach_msg = teach_msg + "blacksmithing";
				break;
			case 0x08
				teach_msg = teach_msg + "the making of bows and fletching of arrows";
				break;
			case 0x09
				teach_msg = teach_msg + "peacemaking";
				break;
			case 0x0A
				teach_msg = teach_msg + "camping in the wilderness";
				break;
			case 0x0B
				teach_msg = teach_msg + "carpentry";
				break;
			case 0x0C
				teach_msg = teach_msg + "cartography and the making of maps";
				break;
			case 0x0D
				teach_msg = teach_msg + "cooking";
				break;
			case 0x0E
				teach_msg = teach_msg + "detecting hidden people";
				break;
			case 0x0F
				teach_msg = teach_msg + "enticing folk with music";
				break;
			case 0x10
				teach_msg = teach_msg + "evaluating people's intelligence";
				break;
			case 0x11
				teach_msg = teach_msg + "basic healing";
				break;
			case 0x12
				teach_msg = teach_msg + "fishing";
				break;
			case 0x13
				teach_msg = teach_msg + "forensic evaluation";
				break;
			case 0x14
				teach_msg = teach_msg + "herding animals";
				break;
			case 0x15
				teach_msg = teach_msg + "hiding in plain sight";
				break;
			case 0x16
				teach_msg = teach_msg + "provoking anger and causing fights";
				break;
			case 0x17
				teach_msg = teach_msg + "inscribing scrolls and books";
				break;
			case 0x18
				teach_msg = teach_msg + "picking locks";
				break;
			case 0x19
				teach_msg = teach_msg + "magery";
				break;
			case 0x1A
				teach_msg = teach_msg + "resisting magic spells";
				break;
			case 0x1B
				teach_msg = teach_msg + "battle tactics";
				break;
			case 0x1C
				teach_msg = teach_msg + "snooping in backpacks";
				break;
			case 0x1D
				teach_msg = teach_msg + "musicianship";
				break;
			case 0x1E
				teach_msg = teach_msg + "the deadly art of poisoning";
				break;
			case 0x1F
				teach_msg = teach_msg + "archery";
				break;
			case 0x20
				teach_msg = teach_msg + "spirit talking";
				break;
			case 0x21
				teach_msg = teach_msg + "stealing";
				break;
			case 0x22
				teach_msg = teach_msg + "tailoring";
				break;
			case 0x23
				teach_msg = teach_msg + "taming wild animals";
				break;
			case 0x24
				teach_msg = teach_msg + "food tasting";
				break;
			case 0x25
				teach_msg = teach_msg + "tinkering";
				break;
			case 0x26
				teach_msg = teach_msg + "tracking";
				break;
			case 0x27
				teach_msg = teach_msg + "veterinary healing";
				break;
			case 0x28
				teach_msg = teach_msg + "swordsmanship";
				break;
			case 0x29
				teach_msg = teach_msg + "clubs and maces";
				break;
			case 0x2A
				teach_msg = teach_msg + "fencing and daggers";
				break;
			case 0x2B
				teach_msg = teach_msg + "hand to hand combat and wrestling";
				break;
			case 0x2C
				teach_msg = teach_msg + "lumberjacking";
				break;
			case 0x2D
				teach_msg = teach_msg + "mining";
				break;
			default
				teach_msg = teach_msg + "idle chattering";
				break;
			}
		}
		teach_msg = teach_msg + ".";
		bark(this, teach_msg);
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
	if (matched_keyword == "appraising") {
		skill_id = 0x03;
	}
	if (matched_keyword == "identifying") {
		skill_id = 0x03;
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
	if (matched_keyword == "lumberjack") {
		skill_id = 0x2C;
	}
	if (matched_keyword == "lumberjacking") {
		skill_id = 0x2C;
	}
	if (matched_keyword == "woodcutting") {
		skill_id = 0x2C;
	}
	if (matched_keyword == "mining") {
		skill_id = 0x2D;
	}
	if (matched_keyword == "mine") {
		skill_id = 0x2D;
	}
	if (matched_keyword == "smelt") {
		skill_id = 0x2D;
	}
	if (skill_id == 0xFF) {
		if (0x00) {
			bark(this, "Somehow I recognized a skill keyword but didn't see it the second time I checked...");
		}
		return(0x00);
	}
	if (getSkillLevelNoStat(this, skill_id) < 0x64) {
		if (0x00) {
			bark(this, matched_keyword);
		}
		bark(this, "'Tis not something I can teach thee of.");
		begin_convo_pause(this);
		return(0x00);
	}
	if (getSkillLevelNoStat(this, skill_id) < getSkillLevelNoStat(speaker, skill_id)) {
		bark(this, "I cannot teach thee, for thou knowest more than I!");
		begin_convo_pause(this);
		return(0x00);
	}
	int train_cost = (getSkillLevelNoStat(this, skill_id) / 0x03) - getSkillLevelNoStat(speaker, skill_id);
	if (train_cost < 0x0B) {
		bark(this, "I cannot teach thee, for thou knowest all I can teach!");
		begin_convo_pause(this);
		return(0x00);
	}
	string cost_str = train_cost;
	string offer_msg = "I can teach thee, for a fee. For " + cost_str + " gold coins, I can teach thee all I know. For less, I shall teach thee less.";
	bark(this, offer_msg);
	begin_convo_pause(this);
	setObjVar(this, "trainerSkillToTeach", skill_id);
	setObjVar(speaker, "trainingSkillToLearn", skill_id);
	return(0x00);
}

function int handle_name_speech(obj this, obj speaker, string arg) {
	list args;
	int i;
	int found_name;
	if (!check_convo_eligibility(this, speaker, arg)) {
		return(0x01);
	}
	split(args, arg);
	list known_objs;
	list memoryRecent;
	list memoryNotoriety;
	if (hasObjVar(this, "memoryRecent")) {
		getObjListVar(memoryRecent, this, "memoryRecent");
	}
	if (hasObjVar(this, "memoryNotoriety")) {
		getObjListVar(memoryNotoriety, this, "memoryNotoriety");
	}
	copyList(known_objs, memoryRecent);
	if (0x00) {
		debugMessage("Added recent memory to the names check list.");
	}
	list notoriety_entry;
	obj noted_obj;
	int notoriety_count = numInList(memoryNotoriety);
	for (i = 0x00; i < notoriety_count; i++) {
		copyList(notoriety_entry, memoryNotoriety[i]);
		noted_obj = notoriety_entry[0x00];
		appendToList(known_objs, noted_obj);
		if (0x00) {
			debugMessage("Added a name from fame memory to the names check list.");
		}
	}
	int j;
	found_name = 0x00;
	string word;
	string known_name;
	for (i = 0x00; i < numInList(args); i++) {
		word = args[i];
		for (j = 0x00; j < numInList(known_objs); j++) {
			known_name = getName(known_objs[j]);
			if (word == known_name) {
				found_name = 0x01;
				break;
			}
		}
	}
	if (!found_name) {
		found_name = check_murder_witness(arg);
	}
	if (found_name) {
		if (0x00) {
			debugMessage("Recognized a name in speech.");
		}
		word = getName(known_objs[j]);
		string speaker_name = getName(speaker);
		if (word != speaker_name) {
			replyTo(this, known_objs[j], "@InternalNameRecognition");
			begin_convo_pause(this);
			if (0x00) {
				debugMessage("doing Convo Pause");
			}
			obj matched_obj = known_objs[j];
			string direction_str = getHeShe(matched_obj) + " is " + getDirection(getLocation(this), getLocation(matched_obj)) + ".";
			toUpper(direction_str, 0x00, 0x01);
			bark(this, direction_str);
			if (getDistance(getLocation(this), getLocation(matched_obj)) == "right here") {
				direction_str = "Just turn around and look.";
			} else {
				if (getDistance(getLocation(this), getLocation(matched_obj)) == "a long journey") {
					direction_str = "Just turn around and look.";
				} else {
					direction_str = getHeShe(matched_obj) + " is " + getDistance(getLocation(this), getLocation(matched_obj)) + " from here.";
					toUpper(direction_str, 0x00, 0x01);
					bark(this, direction_str);
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
	int resource_level;
	string bar;
	list resource_list;
	list resources;
	string resource_name;
	if (getResourcesOnObj(this, 0x00, resources)) {
		copyList(resource_list, resources);
	}
	if (getResourcesOnObj(this, 0x02, resources)) {
		for (int i = 0x00; i < (numInList(resources) - 0x01); i++) {
			bar = resources[i];
			appendToList(resource_list, bar);
		}
	}
	string word;
	for (i = 0x00; i < numInList(resource_list); i++) {
		for (int j = 0x00; j < numInList(args); j++) {
			bar = resource_list[i];
			word = args[j];
			if (bar == word) {
				found = 0x01;
				resource_name = resource_list[i];
			}
		}
	}
	if (found) {
		if (0x00) {
			bark(this, "Found something!");
			bark(this, resource_name);
		}
		bar = resource_name;
		if (getResource(resource_level, this, resource_name, 0x00, 0x02)) {
			bar = getResourceName(resource_name, 0x00);
		} else {
			if (getResource(resource_level, this, resource_name, 0x02, 0x02)) {
				bar = getResourceName(resource_name, 0x02);
			}
		}
		setObjVar(this, "CurrentNeedString", bar);
		replyTo(this, speaker, "@InternalNeedResponse");
		begin_convo_pause(this);
		return(0x00);
	}
	return(0x01);
}

function int handle_time_speech(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	if (isInList(args, "time")) {
		string time_msg;
		int hour;
		string hour_str;
		int minute_bucket;
		string minute_str;
		int on_hour = 0x00;
		minute_bucket = getMinute();
		hour = getHour();
		minute_bucket = minute_bucket / 0x05;
		switch(minute_bucket) {
		case 0x00
			minute_str = "";
			on_hour = 0x01;
			break;
		case 0x01
			minute_str = "a few minutes past";
			break;
		case 0x02
			minute_str = "ten past";
			break;
		case 0x03
			minute_str = "quarter past";
			break;
		case 0x04
			minute_str = "twenty minutes past";
			break;
		case 0x05
			minute_str = "a few minutes shy of half-past";
			break;
		case 0x06
			minute_str = "half-past";
			break;
		case 0x07
			minute_str = "just over half-past";
			break;
		case 0x08
			minute_str = "lacking twenty minutes until";
			hour = hour + 0x01;
			break;
		case 0x09
			minute_str = "quarter of";
			hour = hour + 0x01;
			break;
		case 0x0A
			minute_str = "ten of";
			hour = hour + 0x01;
			break;
		case 0x0B
			minute_str = "almost";
			hour = hour + 0x01;
			on_hour = 0x01;
			break;
		case 0x0C
			minute_str = "";
			on_hour = 0x01;
			break;
		default
			minute_str = "no known minutes!";
			break;
		}
		if (hour > 0x17) {
			hour = 0x00;
		}
		switch(hour) {
		default
			hour_str = "no known hour!";
			break;
		case 0x00
			hour_str = "midnight";
			on_hour = 0x00;
			break;
		case 0x0C
			hour_str = "noon";
			on_hour = 0x00;
			break;
		case 0x01
		case 0x0D
			hour_str = "one";
			break;
		case 0x02
		case 0x0E
			hour_str = "two";
			break;
		case 0x03
		case 0x0F
			hour_str = "three";
			break;
		case 0x04
		case 0x10
			hour_str = "four";
			break;
		case 0x05
		case 0x11
			hour_str = "five";
			break;
		case 0x06
		case 0x12
			hour_str = "six";
			break;
		case 0x07
		case 0x13
			hour_str = "seven";
			break;
		case 0x08
		case 0x14
			hour_str = "eight";
			break;
		case 0x09
		case 0x15
			hour_str = "nine";
			break;
		case 0x0A
		case 0x16
			hour_str = "ten";
			break;
		case 0x0B
		case 0x17
			hour_str = "eleven";
			break;
		}
		if (on_hour) {
			hour_str = hour_str + " o'clock";
		}
		if ((hour > 0x00) && (hour < 0x0B)) {
			hour_str = hour_str + " in the morning";
		}
		if ((hour > 0x0C) && (hour < 0x15)) {
			hour_str = hour_str + " in the afternoon";
		}
		if (hour > 0x14) {
			hour_str = hour_str + " at night";
		}
		time_msg = "It is " + minute_str + " " + hour_str + ".";
		bark(this, time_msg);
		begin_convo_pause(this);
		return(0x00);
	}
	return(0x01);
}

function int handle_move_speech(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	if (isInList(args, "move")) {
		if (!walk(this, random(0x00, 0x07))) {
			bark(this, "Excuse me?");
		}
		return(0x00)}
	return(0x01);
}

function int handle_whereis_speech(obj this, obj speaker, string arg) {
	list args;
	split(args, arg);
	int found_where = 0x00;
	string word;
	list args_copy;
	int where_idx;
	for (int i = 0x00; i < numInList(args); i++) {
		word = args[i];
		if (word == "where") {
			found_where = 0x01;
			if (0x00) {
				bark(this, "Being asked where something is.");
			}
			where_idx = i;
		}
	}
	if (!found_where) {
		return(0x01);
	}
	;
	string area_key = "nothing";
	int exact_match = 0x00;
	found_where = 0x00;
	int is_singular = 0x01;
	for (i = where_idx; i < numInList(args); i++) {
		word = args[i];
		if (word == "shrine") {
			area_key = "shrine";
			exact_match = 0x01;
			is_singular = 0x00;
			found_where = 0x01;
		}
		if (word == "britain") {
			area_key = "city_britain";
			word = "city of Britain";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "buccaneer") {
			area_key = "city_bucden";
			word = "island known as Buccaneer's Den";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "jhelom") {
			area_key = "city_jhelom";
			word = "city of Jhelom";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "magincia") {
			area_key = "city_magincia";
			word = "city of Magincia";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "vesper") {
			area_key = "city_vesper";
			word = "lovely city of Vesper";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "minoc") {
			area_key = "city_minoc";
			word = "rustic town of Minoc";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "moonglow") {
			area_key = "city_moonglow";
			word = "magical city of Moonglow";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "nujel") {
			area_key = "city_nujelm";
			word = "city of Nujel'm";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "ocllo") {
			area_key = "city_ocllo";
			word = "strange land called Ocllo";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "serpent") {
			area_key = "city_serphold";
			word = "fortress called Serpent's Hold";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "skara") {
			area_key = "city_skara";
			word = "town of Skara Brae";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "trinsic") {
			area_key = "city_trinsic";
			word = "walled city of Trinsic";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "yew") {
			area_key = "city_yew";
			word = "city of Yew";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "cove") {
			area_key = "city_cove";
			word = "township of Cove";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "abbey") {
			area_key = "abbey";
			word = "Empath Abbey";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "alchemist") {
			area_key = "alchemist";
			found_where = 0x01;
		}
		if (word == "animal") {
			area_key = "animaltrainer";
			word = "animal trainer";
			found_where = 0x01;
		}
		if ((word == "armorer") || (word == "armourer")) {
			area_key = "armorer";
			found_where = 0x01;
		}
		if ((word == "artisans") || (word == "artisan")) {
			area_key = "artisansguild";
			word = "artisans guild";
			exact_match = 0x01;
			if (word == "artisans") {
				is_singular = 0x00;
			}
			found_where = 0x01;
		}
		if ((word == "baker") || (word == "bakery")) {
			area_key = "baker";
			if (word == "bakery") {
				is_singular = 0x00;
			}
			found_where = 0x01;
		}
		if (word == "bank") {
			area_key = "bank";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if ((word == "bard") || (word == "bards")) {
			area_key = "bard";
			if (word == "bards") {
				is_singular = 0x00;
			}
			found_where = 0x01;
		}
		if ((word == "bath") || (word == "baths")) {
			area_key = "bath";
			if (word == "baths") {
				is_singular = 0x00;
			}
			found_where = 0x01;
		}
		if (word == "beekeeper") {
			area_key = "beekeeper";
			found_where = 0x01;
		}
		if ((word == "smith") || (word == "blacksmith")) {
			area_key = "blacksmith";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "blackthorn") {
			area_key = "blackthornkeep";
			word == "Blackthorn's keep";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if ((word == "bowyer") || (word == "fletcher")) {
			area_key = "bowyer";
			found_where = 0x01;
		}
		if (word == "butcher") {
			area_key = "butcher";
			found_where = 0x01;
		}
		if (word == "carpenter") {
			area_key = "carpenter";
			found_where = 0x01;
		}
		if (word == "casino") {
			area_key = "casino";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "cemetery") {
			area_key = "cemetery";
			is_singular = 0x00;
			found_where = 0x01;
		}
		if (word == "clothier") {
			area_key = "clothier";
			found_where = 0x01;
		}
		if (word == "cobbler") {
			area_key = "cobbler";
			found_where = 0x01;
		}
		if (word == "court") {
			area_key = "court";
			found_where = 0x01;
			exact_match = 0x01;
		}
		if (word == "customs") {
			area_key == "customs";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if ((word == "docks") || (word == "dock")) {
			area_key = "docks";
			found_where = 0x01;
			if (word == "docks") {
				is_singular = 0x00;
			}
			exact_match = 0x01;
		}
		if ((word == "duel") || (word == "pit")) {
			area_key = "duelpit";
			word == "dueling pit";
			found_where = 0x01;
		}
		if (word == "farm") {
			area_key = "farm";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "fish") {
			area_key = "fishery";
			found_where = 0x01;
		}
		if (word == "glassblower") {
			area_key = "glassblower";
			found_where = 0x01;
		}
		if ((word == "gypsy") || (word == "gypsies")) {
			area_key = "gypsy";
			if (word == "gypsies") {
				is_singular = 0x00;
			}
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "healer") {
			area_key = "healer";
			found_where = 0x01;
		}
		if (word == "herbalist") {
			area_key = "herbalist";
			found_where = 0x01;
		}
		if ((word == "inn") || (word == "hostel")) {
			area_key = "inn";
			exact_match = 0x01;
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "jail") {
			area_key = "jail";
			found_where = 0x01;
		}
		if (word == "jeweler") {
			area_key = "jeweler";
			found_where = 0x01;
		}
		if (word == "castle") {
			area_key = "lbcastle";
			exact_match = 0x01;
			is_singular = 0x00;
			found_where = 0x01;
		}
		if (word == "library") {
			area_key = "library";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "lighthouse") {
			area_key = "lighthouse";
			exact_match = 0x01;
			is_singular = 0x00;
			found_where = 0x01;
		}
		if ((word == "magic") || (word == "mage")) {
			area_key = "magic";
			found_where = 0x01;
			word = "mage";
		}
		if (word == "merchant") {
			area_key = "merchant";
			found_where = 0x01;
		}
		if (word == "mill") {
			area_key = "mill";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "observatory") {
			area_key = "observatory";
			is_singular = 0x00;
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "painter") {
			area_key = "painter";
			found_where = 0x01;
		}
		if (word == "paladin") {
			area_key = "paladin";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "provisioner") {
			area_key = "provisioner";
			found_where = 0x01;
		}
		if (word == "shipwright") {
			area_key = "shipwright";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if ((word == "stable") || (word == "stables")) {
			area_key = "stable";
			if (word == "stables") {
				is_singular = 0x00;
			}
			found_where = 0x01;
		}
		if (word == "tanner") {
			area_key = "tanner";
			found_where = 0x01;
		}
		if ((word == "tavern") || ((word == "pub") || (word == "bar"))) {
			area_key = "tavern";
			found_where = 0x01;
		}
		if (word == "temple") {
			area_key = "temple";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "theater") {
			area_key = "theater";
			found_where = 0x01;
			is_singular = 0x00;
		}
		if (word == "tinker") {
			area_key = "tinker";
			found_where = 0x01;
		}
		if ((word == "vet") || (word == "veterinarian")) {
			area_key = "vet";
			found_where = 0x01;
		}
		if ((word == "weapons") || (word == "weaponeer")) {
			area_key = "weaponry";
			found_where = 0x01;
			if (word == "weapons") {
				is_singular = 0x00;
			}
		}
		if (word == "trainer") {
			area_key = "weapontrainer";
			found_where = 0x01;
		}
		if (word == "woodworker") {
			area_key = "woodworker";
			exact_match = 0x01;
			found_where = 0x01;
		}
		if (word == "guild") {
			string first_word;
			string guild_name;
			exact_match = 0x01;
			for (int j = 0x00; j < numInList(args); j++) {
				first_word = args[j];
				if (first_word == "bard") {
					guild_name = "bardic guild";
					area_key = "bardguild";
					found_where = 0x01;
				}
				if ((first_word == "fighter") || (first_word == "warrior")) {
					guild_name = "warrior's guild";
					area_key = "fighterguild";
					found_where = 0x01;
				}
				if (first_word == "healer") {
					guild_name = "healer's guild";
					area_key = "healer";
					found_where = 0x01;
				}
				if (first_word == "merchant") {
					guild_name = "merchant's guild";
					area_key = "merchantguild";
					found_where = 0x01;
				}
				if (first_word == "miner") {
					guild_name = "miner's guild";
					area_key = "minerguild";
					found_where = 0x01;
				}
				if (first_word == "ranger") {
					guild_name = "ranger's guild";
					area_key = "rangerguild";
					found_where = 0x01;
				}
				if (first_word == "tailor") {
					guild_name = "tailor's guild";
					area_key = "tailorguild";
					found_where = 0x01;
				}
				if (first_word == "tinker") {
					guild_name = "tinker's guild";
					area_key = "tinkerguild";
					found_where = 0x01;
				}
			}
		}
	}
	if (!found_where) {
		if (0x00) {
			bark(this, "Asked direction to nowhere I recognize.");
		}
		return(0x01);
	}
	string area_name;
	loc area_loc;
	loc my_loc = getLocation(this);
	found_where = findClosestArea(area_name, area_loc, area_key, my_loc, exact_match);
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
	string direction_msg = "Thou seekest " + word + area_name + "?";
	bark(this, direction_msg);
	begin_convo_pause(this);
	if (!found_where) {
		bark(this, "I know not where to find that.");
		return(0x00);
	}
	string direction = getDirection(my_loc, area_loc);
	string distance = getDistance(my_loc, area_loc);
	direction_msg = "'Tis " + distance + " " + direction + " from here.";
	if (distance == "right here") {
		direction_msg = "But 'tis " + distance + "! Look thee " + direction + ".";
	}
	bark(this, direction_msg);
	return(0x00);
}

trigger convofunc("GetNeed") {
	string cached_need;
	if (hasObjVar(this, "CurrentNeedString")) {
		if (0x00) {
			bark(this, "I had just stored my need.");
		}
		cached_need = getObjVar(this, "CurrentNeedString");
		removeObjVar(this, "CurrentNeedString");
		setConvoRet(cached_need);
		return(0x00);
	}
	list food_resources;
	list desire_resources;
	list all_resources;
	int has_resources;
	has_resources = getResourcesOnObj(this, 0x00, food_resources);
	if (has_resources) {
		copyList(food_resources, all_resources);
	}
	has_resources = getResourcesOnObj(this, 0x02, desire_resources);
	string resource_name;
	if (has_resources) {
		if (numInList(all_resources) > 0x00) {
			for (int i = 0x00; i < numInList(desire_resources); i++) {
				resource_name = desire_resources[i];
				appendToList(all_resources, resource_name);
			}
		}
	}
	if (numInList(all_resources) < 0x01) {
		setConvoRet("food");
		return(0x00);
	}
	int rand_idx;
	rand_idx = (random(0x01, numInList(all_resources)));
	rand_idx--;
	resource_name = all_resources[rand_idx];
	int bar = getResource(has_resources, this, resource_name, 0x00, 0x00);
	if (bar) {
		resource_name = getResourceName(resource_name, 0x00);
	} else {
		resource_name = getResourceName(resource_name, 0x02);
	}
	setConvoRet(resource_name);
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

function int handle_shopkeeper_speech(obj this, obj speaker, string arg) {
	if (!isShopkeeper(this)) {
		return(0x01);
	}
	loc my_loc = getLocation(this);
	loc there = getLocation(speaker);
	if (getDistanceInTiles(my_loc, there) > 0x03) {
		return(0x01);
	}
	list words;
	string word;
	string str_arg;
	string sell_word;
	int loop_idx;
	int i;
	int j;
	int has_buy_keyword;
	int has_sell_keyword;
	has_buy_keyword = 0x00;
	has_sell_keyword = 0x00;
	split(words, arg);
	if (hasShopKeyword(words)) {
		has_buy_keyword = 0x01;
	}
	if (isInList(words, "sell")) {
		if (0x01) {
			has_sell_keyword = 0x01;
		}
	}
	if ((!has_buy_keyword) && (!has_sell_keyword)) {
		return(0x01);
	}
	if (!getCompileFlag(0x01)) {
		if (getNotoriety(speaker) < (0x00 - 0x5A)) {
			bark(this, "I shall not treat with scum like thee!");
			return(0x00);
		}
	} else {
		if (isMurderer(speaker)) {
			bark(this, "I shall not treat with scum like thee!");
			return(0x00);
		}
		if (getKarmaLevel(speaker) < (0x00 - 0x04)) {
			bark(this, "I shall not treat with scum like thee!");
			return(0x00);
		}
	}
	has_buy_keyword = 0x00;
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
				has_buy_keyword = 0x01;
			}
		}
		if (hasObjVar(this, "NoRegion")) {
			has_buy_keyword = 0x01;
		}
		if (!has_buy_keyword) {
			bark(this, "I am sorry, I do not have my wares here with me. Let us go back to my shop.");
			if (hasObjVar(this, "myJobLocation")) {
				loc job_loc = getObjVar(this, "myJobLocation");
				walkTo(this, job_loc, 0x06);
			}
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
	if (has_sell_keyword) {
		shopKeeperOpenBuying(this, speaker);
	} else {
		shopKeeperOpenBusiness(this, speaker);
	}
	setObjVar(this, "wasAskedBuy", 0x01);
	begin_convo_pause(this);
	return(0x00);
}

trigger sawdeath {
	if (attacker == NULL()) {
		return(0x00);
	}
	if ((!isHuman(victim)) || (!isHuman(attacker)) || (isGuard(attacker))) {
		return(0x00);
	}
	if (!canSeeObj(this, attacker)) {
		return(0x00);
	}
	if (!canSeeObj(this, victim)) {
		return(0x00);
	}
	list witness_list;
	if (hasObjVar(this, "myMurderWitnessList")) {
		getObjListVar(witness_list, this, "myMurderWitnessList");
	}
	list death_entry = attacker, victim;
	appendToList(witness_list, death_entry);
	if (numInList(witness_list) > 0x0A) {
		removeItem(witness_list, 0x00);
	}
	setObjVar(this, "myMurderWitnessList", witness_list);
	return(0x00);
}

function int check_murder_witness(string name) {
	int i;
	list witness_list;
	int found = 0x00;
	if (!hasObjVar(this, "myMurderWitnessList")) {
		debugMessage("No murder list.");
		return(0x00);
	}
	getObjListVar(witness_list, this, "myMurderWitnessList");
	list entry;
	string msg;
	for (i = 0x00; i < numInList(witness_list); i++) {
		copyList(entry, witness_list[i]);
		if (name == getName(entry[0x00])) {
			msg = getName(entry[0x00]) + " is a bloody murderer! I saw " + getHimHer(entry[0x00]) + " kill " + getName(entry[0x01]) + " with my own eyes!";
			found = 0x01;
			break;
		}
		if (name == getName(entry[0x01])) {
			msg = getName(entry[0x01]) + " was brutally slain by " + getName(entry[0x00]) + "!" + " I saw it with my own eyes!";
			found = 0x01;
			break;
		}
	}
	if (found) {
		begin_convo_pause(this);
		obj attacker = entry[0x00];
		string loc_desc = getHeShe(attacker) + " is " + getDirection(getLocation(this), getLocation(attacker)) + ".";
		bark(this, loc_desc);
		if (getDirection(getLocation(this), getLocation(attacker)) != "right here") {
			loc_desc = "It is " + getDistance(getLocation(this), getLocation(attacker)) + " from here.";
			if (getDistance(getLocation(this), getLocation(attacker)) == "right here") {
				loc_desc = "Just turn around and look.";
			}
			bark(this, loc_desc);
			return(0x01);
		}
	}
	return(0x00);
}

trigger give {
	if (isGuard(this)) {
		bark(this, "Art thou trying to bribe me?");
		return(0x00);
	}
	if (mobileWillBuy(this, givenobj)) {
		if (!0x01) {
			bark(this, "I might be interested in buying this of thee.");
			intRet(0x00);
			return(0x01);
		}
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
			int learner_skill = getObjVar(giver, "trainingSkillToLearn");
			removeObjVar(this, "trainerSkillToTeach");
			removeObjVar(giver, "trainingSkillToLearn");
			if (skill_id == learner_skill) {
				if (0x00) {
					bark(this, "And we agree on what to learn.");
				}
				int train_cost;
				int has_gold = getResource(train_cost, givenobj, "gold", 0x03, 0x02);
				if (0x00) {
					string debug_str = train_cost;
					bark(this, debug_str);
					if (!has_gold) {
						bark(this, "Failed to get gold resource on item.");
					}
				}
				if (!has_gold) {
					bark(this, "I require gold in payment!");
					return(0x00);
				}
				if (train_cost < 0x0A) {
					bark(this, "'Tis but a pittance! I require 10 gold at a minimum.");
					return(0x00);
				}
				if (train_cost > 0x00) {
					if (0x00) {
						bark(this, "And I was paid.");
					}
					int max_gain = (getSkillLevelNoStat(this, skill_id) / 0x03) - getSkillLevelNoStat(giver, skill_id);
					if (train_cost > max_gain) {
						if (0x00) {
							bark(this, "Overpaid, even.");
						}
						train_cost = max_gain;
					}
					addSkillLevel(giver, skill_id, train_cost);
					bark(this, "Let me show thee something of how this is done.");
					begin_convo_pause(this);
					if ((isShopkeeper(this)) && (getObjType(givenobj) == 0x0EED)) {
						int deposited = depositIntoBank(this, givenobj, train_cost);
					} else {
						deleteObject(givenobj);
					}
					systemMessage(giver, "Your skill level increases.");
					intRet(0x01);
					return(0x00);
				}
			}
		}
	}
	list item_res;
	int n;
	int i;
	int j;
	int put_ok;
	int item_wanted;
	list npc_food_res;
	list npc_desire_res;
	list extra_res;
	string npc_food;
	string npc_desire;
	string extra_str;
	string res;
	string item_name;
	int is_food;
	item_name = getName(givenobj);
	if (getResourcesOnObj(givenobj, 0x03, item_res)) {
		if (getResourcesOnObj(this, 0x00, npc_food_res)) {
			for (i = 0x00; i < numInList(npc_food_res); i++) {
				for (j = 0x00; j < numInList(item_res); j++) {
					npc_food = npc_food_res[i];
					res = item_res[j];
					if (npc_food == res) {
						is_food = 0x01;
						item_wanted = 0x01;
						if (0x00) {
							bark(this, "Found a food match.");
						}
						item_name = getResourceName(npc_food, 0x00);
					}
				}
			}
		}
		if (getResourcesOnObj(this, 0x02, npc_desire_res)) {
			for (i = 0x00; i < numInList(npc_desire_res); i++) {
				for (j = 0x00; j < numInList(item_res); j++) {
					npc_desire = npc_desire_res[i];
					res = item_res[j];
					if (npc_desire == res) {
						setDesireLevel(this, 0x64);
						if (0x00) {
							bark(this, "Found a desire match.");
						}
						item_wanted = 0x01;
						item_name = getResourceName(npc_desire, 0x02);
					}
				}
			}
		}
		string phrases;
		phrases = "Thou art giving me " + item_name + "?";
		bark(this, phrases);
		begin_convo_pause(this);
		obj give_back;
		int gold_amt;
		int ok;
		if (item_wanted) {
			int c = getValue(givenobj);
			if (!getCompileFlag(0x01)) {
				if (getNotorietyLevel(giver) <= 0x01) {
					addNotoriety(giver, 0x01);
				}
			} else {
				if (c > 0x03E8) {
					c = 0x03E8;
				}
				changeFame(giver, c);
				if (getKarmaLevel(this) < 0x00) {
					changeKarma(giver, (0x00 - c));
				} else {
					changeKarma(giver, c);
				}
			}
			if (getObjType(givenobj) == 0x0EED) {
				string gold_msg;
				ok = getResource(gold_amt, givenobj, "gold", 0x03, 0x02);
				if (gold_amt > 0xFA) {
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
					ok = getResource(gold_amt, givenobj, "gold", 0x03, 0x02);
					ok = depositIntoBank(this, givenobj, gold_amt);
					intRet(0x01);
					return(0x01);
				} else {
					put_ok = putObjContainer(givenobj, this);
					if (!put_ok) {
						put_ok = teleport(givenobj, getLocation(this));
						bark(this, "Oops, I dropped it.");
					}
				}
			} else {
				put_ok = putObjContainer(givenobj, this);
				if (!put_ok) {
					put_ok = teleport(givenobj, getLocation(this));
					bark(this, "Oops, I dropped it.");
				}
			}
			if (is_food) {
				bark(this, "This tasteth good.");
				list sound_ids = 0x3C, 0x3B, 0x3A;
				sfx(getLocation(this), sound_ids[random(0x00, 0x02)], 0x00);
			}
			deleteObject(givenobj);
			list gift_list;
			obj candidate;
			obj gift;
			int gift_val = 0x00;
			list eligible;
			list pool;
			give_back = NULL();
			if (give_back == NULL()) {
				if (hasObjVar(this, "ScavengeLastItemGotten")) {
					obj last_scavenged = getObjVar(this, "ScavengeLastItemGotten");
					if (hasObj(this, last_scavenged)) {
						give_back = last_scavenged;
					}
				}
			}
			if (give_back == NULL()) {
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
					give_back = transferGenericToContainer(this, this, 0x0EED, i);
					if (give_back != NULL()) {
						sfx(getLocation(giver), 0x35, 0x00);
					}
				}
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
			if (give_back == NULL()) {
				bark(this, "I thank thee.");
				bark(this, get_rumor(this, giver));
				intRet(0x01);
				return(0x00);
			}
			replyTo(this, giver, "@InternalAcceptItem");
			phrases = "Please accept ";
			i = getObjType(give_back);
			phrases = phrases + getArticle(i);
			phrases = phrases + " ";
			phrases = phrases + getName(give_back);
			phrases = phrases + ".";
			if (giveItem(giver, give_back) == NULL()) {
				i = teleport(give_back, getLocation(giver));
			}
			bark(this, phrases);
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
	if (!canHold(giver, givenobj)) {
		bark(this, "Thy hands are full, so here 'tis, on the ground.");
		i = teleport(givenobj, getLocation(giver));
		begin_convo_pause(this);
		return(0x00);
	}
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

function void say_random(list phrases) {
	string x = phrases[random(0x00, numInList(phrases) - 0x01)];
	bark(this, x);
	return();
}

trigger 0x64 death {
	list death_phrases = "I shall be avenged!", "NOOooo!", "I... I...", "No, I don't want to die...", "Argh! I am slain!", "Must stay... on feet...", "Oooh, that doth hurt...", "Am I dying?";
	if (isShopkeeper(this)) {
		death_phrases = "Whatever shall my family do without me?", "I hope the guards catch thee, scum!", "Ooh... that doth hurt.", "Must I die?", "Curse thee!", "I shall be avenged...", "I shall haunt thee for this deed!", "I spit on thee...";
	}
	say_random(death_phrases);
	return(0x01);
}

trigger 0x64 killedtarget {
	list phrases = "Ha! I knew that I could do it!", "Thou shouldst not have messed with me!", "Die, pathetic fool!", "Thou deservest to die!", "There, that taketh care of thee.", "So perish those who challenge me!", "Thou shouldst not have fought me.", "May thy soul rest in peace.", "May thy shade wander the wilderness forever!", "Have done with thee!";
	say_random(phrases);
	return(0x01);
}

trigger 0x64 washit {
	list phrases;
	if (damamt < 0x01) {
		phrases = "Ha! Thou art inept!", "Thou didst miss, fool!", "Thy aim is bad...", "Surely thou canst do better than that blow!", "Thou dost hit only air!", "Thou art no match for me!";
		say_random(phrases);
		return(0x01);
	}
	if (damamt < 0x05) {
		phrases = "Ouch! Thou didst scratch me!", "Barely a flesh wound. Canst thou not do better?", "Pfft, thou fightest badly.", "Surely thou canst hit harder than that!", "A bare touch... Thou dost not wield thy weapon well!";
	} else {
		phrases = "Ouch! A touch indeed!", "'Twill take more than that to kill me!", "Ow, thou didst get past my defenses!", "Away with thee, scum!", "Oof! That didst hurt!", "Aaah! I do bleed badly...", "A good blow on thy part... but not enough!";
	}
	say_random(phrases);
	return(0x01);
}
