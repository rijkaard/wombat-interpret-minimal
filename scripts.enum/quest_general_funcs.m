inherits human_funcs;

forward int is_valid_target(obj , obj );

forward void approach_target(obj , obj );

forward string get_intro_opener(obj );

forward string get_reward_phrase(obj );

forward void stop_and_wait(obj );

forward string build_reward_response(obj , list );

forward string get_item_refusal_speech(obj , list );

forward string build_fetch_item_response(obj , list );

forward string get_holder_location_reply(obj , list );

forward string build_delivery_object_response(obj , list );

forward void complete_quest_and_reward(obj , obj , int );

forward string get_murder_suffix();

function int is_valid_target(obj this, obj target) {
	if (!isPlayer(target)) {
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

function void approach_target(obj this, obj target) {
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(target)));
	string greeting = getName(target) + "!";
	bark(this, greeting);
	setObjVar(this, "questTarget", target);
	walkTo(this, interpose(getLocation(this), getLocation(target)), 0x13);
	return();
}

trigger pathfound(0x13) {
	if (!hasObjVar(this, "questTarget")) {
		return(0x01);
	}
	obj target = getObjVar(this, "questTarget");
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(target)));
	string intro_msg = getObjVar(this, "questIntroMessage");
	bark(this, intro_msg);
	removeObjVar(this, "questTarget");
	stop_and_wait(this);
	return(0x01);
}

function string get_intro_opener(obj target) {
	list phrases = "Thou dost look like a likely sort. ", "Thou hast the look of an adventurer to thee. ", "I am in need of aid, and thou hast the look of an adventurer. ", "Mightest thou be able to help me? ", "Mightest thou be able to aid me? ", "Mightest thou be able to assist me? ", "I am in need of assistance! ", "I am in need of aid! ", "I am in need of help! ", "Dost thou suppose thou canst help me? ", "Dost thou suppose thou canst assist me? ", "Dost thou suppose thou canst aid me? ", "Couldst thou help me? ", "Couldst thou aid me? ", "Couldst thou assist me? ", "Thou seemst to be one who relishes a difficult task... ", "Surely thou wilt help me! ", "Surely thou wilt aid me! ", "Surely thou wilt assist me!", "Hmm, if thou hast a moment... ", "Couldst thou spare some of thy time? ", "If thou couldst find the time... ";
	string opener = phrases[random(0x00, (numInList(phrases) - 0x01))];
	if ((getNotoriety(target) > 0x64) || (getNotoriety(target) < (0x00 - 0x64))) {
		phrases = "I have heard of thy deeds. ", "Thy name precedes thee. ", "I have heard of thee. ", "I have heard of thy deeds. ", "I recognized thy face, for oft thou art mentioned by folk. ", "I recognized thee from descriptions and tales of thy doings. ", "Thou'rt the sort of powerful person who can best help me. ", "Thou'rt well-known as the sort of person who can help me. ", "Thy deeds make thee the best to be able to aid me. ", "I hope that my poor problem is not beneath thee. ", "My small problem may be beneath thy notice, but... ", "Given thy prowess, I am sure that thou canst solve my problem. ", "Given what thou hast accomplished, I am sure that thou canst help me. ";
		string addendum = phrases[random(0x00, numInList(phrases) - 0x01)];
		opener = opener + addendum;
	}
	return(opener);
}

function string get_reward_phrase(obj this) {
	string phrase;
	list phrases;
	obj reward;
	reward = getObjVar(this, "questReward");
	if (reward == NULL()) {
		phrases = "Alas, I have naught to offer thee in payment save rumors.", "Sadly, all I can offer thee in return is rumors.", "Rumors and news are all I can offer in payment.", "I have no reward to give thee, though.", "I have nothing to offer thee as a reward save rumors.", "I wish that I had aught to entice thee with, but all I can offer is rumors.", "Sadly, rumors and news are all I have to give thee in return.";
		phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
		return(phrase);
	}
	phrases = "I can pay thee.", "I can reward thee.", "I have some small payment to offer.", "I have some small reward to give.", "I can give thee a reward.", "I can give thee some payment.", "I can offer thee a small reward.", "I can offer thee some small payment.";
	phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	phrases = " As reward, I have ", " I can give thee ", " I would give thee ", " I could give thee ", " I might give thee ", " As reward, mayhap I have ", " Mayhap I can give thee ", " Mayhap I would give thee ", " Mayhap I could give thee ";
	phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	phrase = phrase + getName(reward) + ".";
	return(phrase);
}

function void stop_and_wait(obj this) {
	disableBehaviors(this);
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
		}
	}
	return(0x00);
}

function string build_reward_response(obj this, list args) {
	string response;
	int keyword_found;
	string name;
	list reward_keywords = "payment", "reward", "pay", "give";
	int i;
	if (!hasObjVar(this, "questReward")) {
		return(response);
	}
	keyword_found = 0x00;
	for (i = 0x00; i < numInList(reward_keywords); i++) {
		name = reward_keywords[i];
		if (isInList(args, name)) {
			keyword_found = 0x01;
		}
	}
	if (keyword_found) {
		response = get_reward_phrase(this) + " ";
	}
	return(response);
}

function string get_item_refusal_speech(obj this, list args) {
	obj reward;
	string name;
	list name_words;
	int matched = 0x00;
	list refusals;
	int i;
	string result;
	if (!hasObjVar(this, "questReward")) {
		return(result);
	}
	reward = getObjVar(this, "questReward");
	name = getName(reward);
	split(name_words, name);
	for (i = 0x00; i < numInList(name_words); i++) {
		name = name_words[i];
		if (isInList(args, name)) {
			matched = 0x01;
		}
	}
	if (matched) {
		refusals = "Ah! I shan't give thee ", "Thou canst not have the ", "I will not simply give thee the ", "I shan't just give thee the ", "What? Nay, I will not just give thee ", "Ah! I will not simply hand thee ";
		result = refusals[random(0x00, numInList(refusals) - 0x01)];
		result = result + getName(reward) + " lest thou dost as I ask." + " ";
		string reason = getObjVar(this, "questFetchReason");
		int obj_type = getObjVar(this, "questFetchObjType");
		result = result + reason + getNameByType(obj_type) + ". ";
		if (hasObjVar(this, "questItemHolder")) {
			obj holder = getObjVar(this, "questItemHolder");
			if (holder != NULL()) {
				result = result + getName(holder) + " hath one, I hear. ";
			}
		}
	}
	return(result);
}

function string build_fetch_item_response(obj this, list args) {
	int fetch_obj_type;
	int keyword_found = 0x00;
	string name;
	list item_name_words;
	int i;
	obj holder;
	string response;
	if (!hasObjVar(this, "questFetchObjType")) {
		return(response);
	}
	fetch_obj_type = getObjVar(this, "questFetchObjType");
	keyword_found = 0x00;
	name = getNameByType(fetch_obj_type);
	split(item_name_words, name);
	for (i = 0x00; i < numInList(item_name_words); i++) {
		name = item_name_words[i];
		if (isInList(args, name)) {
			keyword_found = 0x01;
		}
	}
	if (keyword_found) {
		name = getObjVar(this, "questFetchReason");
		if (hasObjVar(this, "questItemHolder")) {
			holder = getObjVar(this, "questItemHolder");
			name = getName(holder);
			response = getNameByType(fetch_obj_type) + "s? Hast thou spoken to " + name + "? " + get_reward_phrase(this);
		} else {
			response = getNameByType(fetch_obj_type) + "s? " + name + "one. " + get_reward_phrase(this);
		}
		toUpper(response, 0x00, 0x01);
		response = response + " ";
	}
	return(response);
}

function string get_holder_location_reply(obj this, list args) {
	string response;
	obj holder;
	int obj_type;
	string name;
	if (!hasObjVar(this, "questItemHolder")) {
		return(response);
	}
	if (!hasObjVar(this, "questFetchObjType")) {
		return(response);
	}
	holder = getObjVar(this, "questItemHolder");
	obj_type = getObjVar(this, "questFetchObjType");
	name = getName(holder);
	if (isInList(args, name)) {
		response = "Yes, " + getName(holder) + " hath my " + getNameByType(obj_type) + " and " + getHeShe(holder) + " is " + getDirection(getLocation(this), getLocation(holder)) + ".";
		toUpper(response, 0x00, 0x01);
		if (getDistance(getLocation(this), getLocation(holder)) == "right here") {
			response = response + " Just turn around and look.";
		} else {
			if (getDistance(getLocation(this), getLocation(holder)) == "a long journey") {
				response = response + " Just turn around and look.";
			} else {
				response = response + getHeShe(holder) + " is " + getDistance(getLocation(this), getLocation(holder)) + " from here.";
				toUpper(response, 0x00, 0x01);
			}
		}
	}
	return(response);
}

function string build_murder_victim_response(obj this, list args) {
	string response;
	if (!hasObjVar(this, "questMurderVictim")) {
		return(response);
	}
	if (!hasObjVar(this, "questMurderReason")) {
		return(response);
	}
	obj victim = getObjVar(this, "questMurderVictim");
	if (!isInList(args, getName(victim))) {
		return(response);
	}
	response = getName(victim) + "? Aye" + get_murder_suffix();
	return(response);
}

function string build_delivery_object_response(obj this, list args) {
	string name;
	string word;
	list name_words;
	string response;
	obj deliver_obj;
	string reason;
	obj destination;
	int has_deliver_obj = 0x00;
	if (hasObjVar(this, "questDeliverObject")) {
		deliver_obj = getObjVar(this, "questDeliverObject");
		reason = getObjVar(this, "questDeliverReason");
		destination = getObjVar(this, "questItemDestination");
		has_deliver_obj = 0x01;
	}
	if (hasObjVar(this, "questDeliverObjectRec")) {
		deliver_obj = getObjVar(this, "questDeliverObjectRec");
	}
	if (deliver_obj == NULL()) {
		return(response);
	}
	name = getName(deliver_obj);
	split(name_words, name);
	int matched = 0x00;
	for (int i = 0x00; i < numInList(name_words); i++) {
		word = name_words[i];
		if (isInList(args, word)) {
			matched = 0x01;
		}
	}
	if (!matched) {
		return(response);
	}
	response = "Ah, " + name + ". ";
	if (has_deliver_obj) {
		response = response + reason + name + ". Couldst thou take this one to " + getName(destination) + "? " + get_reward_phrase(destination);
	} else {
		response = response + "I am expecting one delivered.";
	}
	return(response);
}

trigger speech("*") {
	list args;
	string response;
	split(args, arg);
	if (isInList(args, "quest")) {
		if (hasObjVar(this, "questIntroMessage")) {
			string intro_msg = getObjVar(this, "questIntroMessage");
			bark(this, intro_msg);
			stop_and_wait(this);
			return(0x00);
		}
	}
	response = response + build_reward_response(this, args);
	response = response + get_item_refusal_speech(this, args);
	response = response + build_fetch_item_response(this, args);
	response = response + get_holder_location_reply(this, args);
	response = response + build_murder_victim_response(this, args);
	response = response + build_delivery_object_response(this, args);
	if (response != "") {
		bark(this, response);
		stop_and_wait(this);
		return(0x00);
	}
	return(0x01);
}

function void complete_quest_and_reward(obj this, obj giver, int add_notoriety) {
	list thanks_phrases = "I shall tell all of thy deed.", "Thy reputation shall be cemented by what I shall tell!", "I thank thee kindly!", "I cannot tell thee how much this helps me!", "I thank thee indeed!", "I confess I never expected thee to aid me!", "I admit that I never expected thee to help me!", "Thou'rt amazing! I thank thee.", "My gratitude hath no bounds!", "I shall tell all my friends of thee!", "My thanks.", "I owe thee many thanks.", "Thou hast accomplished what I sought!", "From the bottom of my heart, I thank thee.";
	string response = thanks_phrases[random(0x00, numInList(thanks_phrases) - 0x01)];
	response = response + " ";
	if (add_notoriety) {
		addNotoriety(giver, 0x01);
	} else {
		removeNotoriety(giver, 0x01);
	}
	obj reward = getObjVar(this, "questReward");
	if (reward == NULL()) {
		response = response + "I have no item to give thee, only news... " + get_rumor(this, giver);
	} else {
		if (!hasObj(this, reward)) {
			response = response + " Alas, the reward I was to give thee has been lost! + But... " + get_rumor(this, giver);
		} else {
			if (giveItem(giver, reward) == NULL()) {
				int teleport_result = teleport(reward, getLocation(giver));
			}
			response = response + " Please accept this " + getName(reward) + " as a reward.";
		}
	}
	bark(this, response);
	stop_and_wait(this);
	return();
}

function string get_murder_suffix() {
	string result;
	list phrases;
	if (random(0x00, 0x01)) {
		phrases = ", someone nobody shall miss", ", whom even their mother disliketh", ", well-known as scum", ", a scab upon the face of the earth", ", who clearly deserveth to die", ", who is unworthy of thy blade, perhaps... but worthy of someone's", ". I am not the sort to dirty my hands", ", but I have standing in this town and dare not jeopardize it", "; I fear I cannot do it myself", "; I dare not do it myself", "; suspicion would fall 'pon me were I to do it myself", "; all would suspect me immediately";
		result = phrases[random(0x00, numInList(phrases) - 0x01)];
	}
	phrases = ". I'd like thee to kill them.", ". Thou shouldst kill them for me.", " and I'd like thee to kill them.", " and thou'rt a good choice for the murderer.", ". Thou mightest be a good choice for the murderer.", ". Kill them for me.";
	string kill_phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	result = result + kill_phrase;
	return(result);
}
