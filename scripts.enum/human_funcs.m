inherits sndfx;

forward void curtsy(obj , int );

forward void bow_equipped(obj , int );

forward int is_valid_player(obj , obj );

forward void remember_target(obj , obj );

forward void update_fame_memory(obj , obj , int );

forward void begin_convo_pause(obj );

forward int is_addressed(obj , list );

forward int check_convo_eligibility(obj , obj , string );

forward string get_rumor(obj , obj );

forward int count_targets(obj );

forward int is_guarded(obj , obj );

forward int is_direct_address(string , obj );

forward int is_in_recent_memory(obj , obj );

forward int is_in_notoriety_memory(obj , obj );

forward int is_notable_target(obj , obj );

forward int is_tile_clear(obj , obj );

function void curtsy(obj this, int dir) {
	faceHere(this, dir);
	animateMobile(this, 0x20, 0x05, 0x01, 0x00, 0x03);
	return();
}

function void bow_equipped(obj this, int dir) {
	faceHere(this, dir);
	animateMobile(this, 0x21, 0x05, 0x01, 0x00, 0x01);
	return();
}

function int is_valid_player(obj this, obj target) {
	if (!isHuman(target)) {
		return(0x00);
	}
	if (isNPC(target)) {
		return(0x00);
	}
	if (isDead(target)) {
		return(0x00);
	}
	if (!canSeeObj(this, target)) {
		return(0x00);
	}
	return(0x01);
}

function void remember_target(obj this, obj target) {
	list memoryRecent;
	if (hasObjVar(this, "memoryRecent")) {
		getObjListVar(memoryRecent, this, "memoryRecent");
	}
	removeSpecificItem(memoryRecent, target);
	appendToList(memoryRecent, target);
	if (0x00) {
		bark(this, "I am remembering ");
		bark(this, getName(target));
	}
	if (0x00) {
		debugMessage("Recognizing someone from a distance.");
	}
	if (numInList(memoryRecent) > 0x1E) {
		removeItem(memoryRecent, 0x00);
	}
	setObjVar(this, "memoryRecent", memoryRecent);
	return();
}

function void update_fame_memory(obj this, obj target, int mod) {
	if (!is_valid_player(this, target)) {
		return();
	}
	loc my_loc = getLocation(this);
	loc target_loc = getLocation(target);
	int dist = getDistanceInTiles(my_loc, target_loc);
	list memoryNotoriety;
	list memoryRecent;
	if (hasObjVar(this, "memoryNotoriety")) {
		getObjListVar(memoryNotoriety, this, "memoryNotoriety");
	}
	if (hasObjVar(this, "memoryRecent")) {
		getObjListVar(memoryRecent, this, "memoryRecent");
	}
	int fame_val;
	if (!getCompileFlag(0x01)) {
		fame_val = getNotoriety(target) + mod;
	} else {
		fame_val = getFame(target) + mod;
	}
	if (fame_val < 0x00) {
		fame_val = 0x00 - fame_val;
	}
	list entry;
	list forget_indices;
	int age;
	int entry_fame;
	obj entry_target;
	list new_entry;
	setItem(new_entry, target, 0x00);
	setItem(new_entry, fame_val, 0x01);
	setItem(new_entry, 0x00, 0x02);
	obj new_target;
	int count = numInList(memoryNotoriety);
	if (0x00) {
		debugMessage("Updating memory of famous folks.");
	}
	for (int i = 0x00; i < count; i++) {
		copyList(entry, memoryNotoriety[i]);
		entry_target = entry[0x00];
		new_target = new_entry[0x00];
		if (entry_target == new_target) {
			removeItem(memoryNotoriety, i);
			count--;
			if (0x00) {
				debugMessage("Found this guy in notoriety memory, erasing.");
			}
			break;
		}
	}
	for (i = 0x00; i < count; i++) {
		copyList(entry, memoryNotoriety[i]);
		age = entry[0x02];
		entry_fame = entry[0x01];
		entry_target = entry[0x00];
		age++;
		setItem(entry, age, 0x02);
		setItem(memoryNotoriety, entry, i);
		if ((entry_fame - age) <= fame_val) {
			appendToList(forget_indices, i);
			if (0x00) {
				debugMessage("Found someone to forget.");
			}
		}
	}
	if (numInList(forget_indices) != 0x00) {
		int best_idx = 0x00;
		int min_fame = 0x0F;
		int forget_idx;
		for (i = 0x00; i < numInList(forget_indices); i++) {
			forget_idx = forget_indices[i];
			copyList(entry, memoryNotoriety[forget_idx]);
			age = entry[0x02];
			entry_fame = entry[0x01];
			if (entry_fame < min_fame) {
				best_idx = i;
				min_fame = entry_fame;
			}
		}
		int remove_idx = forget_indices[best_idx];
		removeItem(memoryNotoriety, remove_idx);
		if (0x00) {
			debugMessage("Removing a forgettable person.");
		}
		appendToList(memoryNotoriety, new_entry);
	} else {
		if (numInList(memoryNotoriety) < 0x0A) {
			appendToList(memoryNotoriety, new_entry);
		}
	}
	setObjVar(this, "memoryNotoriety", memoryNotoriety);
	return();
}

function void begin_convo_pause(obj this) {
	if (!isGuard(this)) {
		disableBehaviors(this);
	}
	if (0x00) {
		bark(this, "Starting convo pause.");
	}
	callBack(this, 0x2D, 0x38);
	return();
}

trigger callback(0x38) {
	disableBehaviors(this);
	int myLoyalty = 0x00;
	if (hasObjVar(this, "myLoyalty")) {
		myLoyalty = getObjVar(this, "myLoyalty");
	}
	if (myLoyalty < 0x01) {
		enableBehaviors(this);
		list farewell_msgs;
		farewell_msgs = "'Twas nice speaking with thee.", "I suppose I have other things to do.", "Thou seemst to be done speaking with me.", "Unless thou needest aught else, I am done with speaking.", "Unless thou needest aught else, I have my work to do.", "'A pleasure talking with thee.", "Farewell.", "Goodbye.", "Until later.", "Until we meet again.", "'Twas a pleasure.", "Farewell for now.", "Goodbye for now.", "Thou'rt done, and I have work to do.", "I have matters to attend to.", "Fare thee well.";
		if (getIntelligence(this) < 0x22) {
			farewell_msgs = "'Twas nice speakin' with ye.", "I's got other things to do, I reckon.", "Thou seemst to be done speakin' to me.", "'Less'n thou needst aught else, I's done.", "'Less'n thou needst aught else, I's got work to be doing.", "Nice talkin' with thee.", "Farewell.", "Bye!", "'Til later.", "'Til we meet again.", "Farewell for now.", "Goodbye for now.", "Thee's done, and I have work to do.", "I's got things to do.", "Fare thee well.";
		}
		if (0x00) {
			bark(this, "Ending convo pause.");
		}
		if (hasObjVar(this, "lastSpokeTo")) {
			obj last_spoke_to = getObjVar(this, "lastSpokeTo");
			removeObjVar(this, "lastSpokeTo");
			if (hasObjVar(this, "wasAskedBuy")) {
				removeObjVar(this, "wasAskedBuy");
				return(0x00);
			}
			list targets;
			getTargets(targets, this);
			if (numInList(targets) > 0x00) {
				return(0x00);
			}
			if (getDistanceInTiles(getLocation(this), getLocation(last_spoke_to)) < 0x05) {
				bark(this, farewell_msgs[random(0x00, (numInList(farewell_msgs) - 0x01))]);
			}
		}
	}
	return(0x00);
}

function int is_addressed(obj this, list args) {
	int matched = 0x00;
	if (isInList(args, getName(this))) {
		matched = 0x01;
	}
	if (isShopkeeper(this)) {
		if (isInList(args, "shopkeep")) {
			matched = 0x01;
		}
		if (isInList(args, "shopkeeper")) {
			matched = 0x01;
		}
		if (isInList(args, "merchant")) {
			matched = 0x01;
		}
		if (isInList(args, "vendor")) {
			matched = 0x01;
		}
		if (isInList(args, "vender")) {
			matched = 0x01;
		}
	}
	if (isGuard(this)) {
		if (isInList(args, "guard")) {
			matched = 0x01;
		}
	}
	return(matched);
}

function int check_convo_eligibility(obj this, obj speaker, string arg) {
	loc my_loc = getLocation(this);
	loc there = getLocation(speaker);
	int dir = getDirectionInternal(my_loc, there);

member int facing_dir = dir;
	list args;
	split(args, arg);
	int eligible = 0x00;
	int send_init = 0x01;
	if (isDead(speaker)) {
		return(0x00);
	}
	if (!canSeeObj(this, speaker)) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(this), getLocation(speaker)) > 0x05) {
		return(0x00);
	}
	obj lastSpokeTo = NULL();
	if (hasObjVar(this, "lastSpokeTo")) {
		lastSpokeTo = getObjVar(this, "lastSpokeTo");
		if (lastSpokeTo == speaker) {
			send_init = 0x00;
			if (getDistanceInTiles(getLocation(this), getLocation(speaker)) < 0x06) {
				faceHere(this, getDirectionInternal(getLocation(this), getLocation(speaker)));
			}
		}
	}
	if (!isFacingPerson(speaker, this)) {
		if (lastSpokeTo != NULL()) {
			if (getDistanceInTiles(getLocation(this), getLocation(speaker)) < 0x04) {
				if (lastSpokeTo == speaker) {
					eligible = 0x01;
					send_init = 0x00;
				}
			}
		}
		if (getDistanceInTiles(getLocation(speaker), getLocation(this)) < 0x02) {
			eligible = 0x01;
		}
		if (!is_addressed(this, args)) {
			eligible = 0x00;
		}
		if (eligible) {
			faceHere(this, getDirectionInternal(getLocation(this), getLocation(speaker)));
			if (send_init) {
				replyTo(this, speaker, "@InternalConvinit");
			}
			begin_convo_pause(this);
			setObjVar(this, "lastSpokeTo", speaker);
			return(0x01);
		}
		return(0x00);
	}
	if (!isFacingPerson(this, speaker)) {
		if (0x00) {
			bark(this, "We are not facing each other.");
		}
		string word;
		int i;
		eligible = 0x00;
		if (isInList(args, getName(this))) {
			eligible = 0x01;
			if (0x00) {
				debugMessage("Detected my name in a speech trigger.");
			}
		}
		if (getDistanceInTiles(getLocation(speaker), getLocation(this)) < 0x04) {
			if (is_addressed(this, args)) {
				eligible = 0x01;
			}
		}
		if (lastSpokeTo != NULL()) {
			if (lastSpokeTo == speaker) {
				send_init = 0x00;
				eligible = 0x01;
			}
		}
		if (!eligible) {
			return(0x00);
		}
		if (lastSpokeTo != NULL()) {
			if (lastSpokeTo != speaker) {
				if (getDistanceInTiles(getLocation(this), getLocation(lastSpokeTo)) < 0x05) {
					int dir_to_last = getDirectionInternal(getLocation(this), getLocation(lastSpokeTo));
					faceHere(this, dir_to_last);
					string excuse_msg = "Excuse me, " + getName(lastSpokeTo) + ", but " + getName(speaker) + " is calling me.";
					bark(this, excuse_msg);
					send_init = 0x01;
				}
			}
		}
		if (0x00) {
			debugMessage("Calling the convinit keyword.");
		}
		faceHere(this, dir);
		if (send_init) {
			replyTo(this, speaker, "@InternalConvinit");
		}
		int bow = 0x00;
		if (!getCompileFlag(0x01)) {
			if (getNotoriety(speaker) > 0x5A) {
				bow = 0x01;
			}
		} else {
			if (getFameLevel(speaker) > 0x03) {
				bow = 0x01;
			}
		}
		if (bow) {
			if (getSex(this) == 0x00) {
				bow_equipped(this, dir);
			} else {
				curtsy(this, dir);
			}
		}
		setObjVar(this, "lastSpokeTo", speaker);
		begin_convo_pause(this);
	}
	int can_walk = 0x01;
	if (hasObjVar(this, "myJobLocation")) {
		loc myJobLocation = getObjVar(this, "myJobLocation");
		if (getDistanceInTiles(getLocation(this), myJobLocation) > 0x10) {
			can_walk = 0x00;
		}
	}
	if (isGuard(this)) {
		can_walk = 0x00;
	}
	can_walk = 0x00;
	if (isInList(args, "come")) {
		if (can_walk) {
			walkTo(this, getLocation(speaker), 0x05);
			callback(this, 0x2D, 0x0C);
		}
	} else {
		if (getDistanceInTiles(my_loc, there) > 0x03) {
			if (can_walk) {
				walkTo(this, interpose(my_loc, there), 0x05);
				if (0x00) {
					debugMessage("Walking closer to speaker.");
				}
			}
		}
	}
	return(0x01);
}

trigger pathfound(0x05) {
	faceHere(this, facing_dir);
	return(0x00);
}

trigger pathnotfound(0x05) {
	faceHere(this, facing_dir);
	return(0x00);
}

function string get_rumor(obj this, obj talker) {
	int intel_level;
	int hint_level;
	obj hint_npc;
	int hint_value;
	string short_desc;
	string long_desc;
	loc place;
	obj rumored_person;
	string person_name;
	int hint_extra;
	loc local_loc;
	string result;
	string loc_desc;
	list phrases;
	int has_hint;
	intel_level = getIntelligence(this) / 0x0A;
	has_hint = getHint(this, intel_level, hint_level, hint_npc, hint_value, short_desc, long_desc, place, rumored_person, person_name, hint_extra);
	if ((rumored_person == this) || (rumored_person == talker)) {
		has_hint = 0x00;
	}
	if (!has_hint) {
		phrases = "I have not heard any interesting tales lately.", "I can't tell thee much that thou dost not already know.", "I haven't heard much news that would be of interest to thee.", "I haven't heard much lately.", ",I can't tell thee much. I haven't heard anything interest ing.", "No rumors of note are circulating.", "'Tis a pity, but gossip is scarce these days.", "I have heard no rumors lately.", "The rumor mill seemeth to have taken a break lately, methinks.", "Life is dull, methinks, for I have not heard interesting rumors of late.";
		if (intel_level < 0x04) {
			phrases = "I's not heard much lately.", "Has ye heard about the donkey accident?", "Ain't no good gossip hereabouts.", "No stories worth tellin' these days.", "Ho-hum.", "I ain't been hearin' nothin'.", "I ain't been party to no gossip lately.", "I's heard nothing that'd interest thee, I assure ye.", "I 'aven't 'eard nothin' interestin'.", "I haven't picked up anythin' new.";
		}
		if (intel_level > 0x06) {
			phrases = "'Tis a failing of mine, but I follow the rumors of the common folk. None seem interesting of late, however.", "Quite a shame, but I have not heard any interesting tales of late.", "No tales of folly or woe, nor indeed any of powerful magical artifacts, have reached mine ears in the last few days.", "While petty gossip is a fault, surely restrained rumormongering is not!", "Alas, no rumors bear repeating these days.", "One could wish for a livelier life, with more tales to tell.", "I cannot tell thee much, I fear. No tales of interest have crossed my path.", "No new gossip has reached mine ears, to my great regret.", "Knowing thy elevated tastes, I fear that nothing I can tell thee would be of interest.", "New rumors have been slow in coming of late. I regret that I have none to pass along to thee!";
		}
		result = phrases[random(0x00, (numInList(phrases) - 0x01))];
		return(result);
	}
	string str_a;
	string str_b;
	phrases = "Rumor has it that ", "According to tales, ", "I have heard that ", "Thou didst not hear this from me, but ", "Hast thou heard that ", "Some say that ", "According to some, ", "'Tis bandied about that ", "The word is, ", "The word is that ", "'Tis rumored that ", "'Tis said that ", "Gossip has it that ", "Tongues are wagging! They say that ", "All that rumormongerers can think about is that ", "All I hear of these days is that ", "They are saying that ";
	result = phrases[random(0x00, 0x10)];
	if (person_name == "") {
		if (random(0x00, 0x09) > intel_level) {
			result = result + short_desc;
		} else {
			result = result + long_desc;
		}
		loc_desc = loc_desc + " is ";
	} else {
		result = result + person_name;
		result = result + " has ";
		if (random(0x00, 0x09) > intel_level) {
			result = result + short_desc;
		} else {
			result = result + long_desc;
		}
		result = result + " and " + getHeShe(rumored_person);
	}
	string place_qualifier;
	int loc_result = getLocalizedDesc(loc_desc, local_loc, place, getLocation(this));
	if (loc_result > 0x00) {
		if ((loc_result == 0x02) || (loc_result == 0x04)) {
			place_qualifier = place_qualifier + " here";
		}
		place_qualifier = place_qualifier + " in";
		place_qualifier = place_qualifier + loc_desc;
		if (loc_result == 0x03) {
			place = local_loc;
		}
	}
	result = result + " ";
	loc npc_loc = getLocation(this);
	string direction = getDirection(npc_loc, place);
	clearList(phrases);
	phrases = "may be about. ", "can be found. ", "might be nearby. ", "could be around. ", "is somewhere close. ", "is nearby. ", "might be found close by. ", "may be somewhere close. ";
	loc_desc = phrases[random(0x00, (numInList(phrases) - 0x01))];
	clearList(phrases);
	phrases = "Look thee", "Hast thou looked", "Thou mightest look", "Hast thou checked", "I wonder if any have looked", "Possibly", "Perchance 'tis";
	string direction_prompt = phrases[random(0x00, (numInList(phrases) - 0x01))];
	if (place_qualifier != "") {
		result = result + " ";
		result = result + place_qualifier;
		result = result + ",";
	}
	result = result + loc_desc + direction_prompt + " " + direction + "?";
	return(result);
}

function int count_targets(obj this) {
	list targets;
	getTargets(targets, this);
	return(numInList(targets));
}

function int is_guarded(obj this, obj item) {
	if (hasObjVar(this, "guardList")) {
		list guard_list;
		getObjListVar(guard_list, this, "guardList");
		for (int i = 0x00; i < numInList(guard_list); i++) {
			obj entry = guard_list[i];
			if (entry == item) {
				return(0x01);
			}
		}
	}
	return(0x00);
}

function int is_direct_address(string arg, obj this) {
	list args;
	split(args, arg);
	if (numInList(args) < 0x02) {
		if (is_addressed(this, args)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int is_in_recent_memory(obj this, obj target) {
	list memoryRecent;
	if (hasObjVar(this, "memoryRecent")) {
		getObjListVar(memoryRecent, this, "memoryRecent");
	} else {
		return(0x00);
	}
	int found = 0x00;
	obj stored_obj;
	if (isInList(memoryRecent, target)) {
		found = 0x01;
		if (0x00) {
			debugMessage("Found target in recent memory");
		}
	}
	return(found);
}

function int is_in_notoriety_memory(obj this, obj target) {
	list memoryNotoriety;
	if (hasObjVar(this, "memoryNotoriety")) {
		getObjListVar(memoryNotoriety, this, "memoryNotoriety");
	} else {
		return(0x00);
	}
	list entry;
	obj stored_obj;
	int count = numInList(memoryNotoriety);
	for (int i = 0x00; i < count; i++) {
		copyList(entry, memoryNotoriety[i]);
		stored_obj = entry[0x00];
		if (target == stored_obj) {
			return(0x01);
			if (0x00) {
				debugMessage("Found target in fame memory.");
			}
		}
	}
	return(0x00);
}

function int is_notable_target(obj this, obj target) {
	int in_recent = is_in_recent_memory(this, target);
	int in_fame = is_in_notoriety_memory(this, target);
	if (in_recent) {
		return(0x00);
	}
	if (in_fame) {
		return(0x01);
	}
	return(0x00);
}

function int is_tile_clear(obj this, obj m_target) {
	list statics;
	getStaticObjectsAt(statics, getLocation(m_target));
	if (0x00) {
		bark(this, "Static objects at target:");
		string debug = numInList(statics);
		bark(this, debug);
	}
	if (numInList(statics) > 0x00) {
		if (0x00) {
			debugMessage("Statics at chosen item.");
			for (int i = 0x00; i < numInList(statics); i++) {
				obj static_obj = statics[i];
				string name = getName(static_obj);
				bark(this, name);
			}
		}
		return(0x00);
	}
	return(0x01);
}
