inherits globals;

function int get_kill_count(obj killer) {
	if (!hasObjListVar(killer, "killcount")) {
		return(0x00);
	}
	list kills;
	getObjListVar(kills, killer, "killcount");
	return(numInList(kills));
}

function void record_kill(obj killer, obj victim) {
	list kills;
	if (hasObjListVar(killer, "killcount")) {
		getObjListVar(kills, killer, "killcount");
	}
	if (!0x00) {
		if (isInList(kills, getName(victim))) {
			return();
		}
	}
	if (0x00) {
		bark(killer, "Adding victim to the bounty list.");
	}
	appendToList(kills, getName(victim));
	setObjVar(killer, "killcount", kills);
	return();
}

function void prompt_report_murder(obj killer, obj victim) {
	if (hasObjVar(this, "bountyKiller")) {
		removeObjVar(this, "bountyKiller");
	}
	list options;
	setObjVar(victim, "myLastKiller", killer);
	appendToList(options, 0x00);
	appendToList(options, "YES - You report them to Lord British's guards. This will increase the recorded murders under this person's name and may result in a bounty placed on their head.");
	appendToList(options, 0x01);
	appendToList(options, "NO - you forgive this person for killing you and do not report them to Lord British's guards.");
	selectType(victim, victim, 0x01, "You have been murdered! Do you wish to report this crime to Lord British's guards?", options);
	if (0x00) {
		bark(killer, "Opening reporting menu.");
	}
	return();
}

trigger typeselected(0x01) {
	if (listindex == 0x00) {
		systemMessage(this, "You have cancelled the bounty reporting process.");
		detachScript(this, "bounty");
		return(0x01);
	}
	switch(objtype) {
	case 0x00
		if (!hasObjVar(this, "myLastKiller")) {
			systemMessage(this, "An error has occurred and your murder cannot be reported.");
			detachScript(this, "bounty");
			return(0x01);
		}
		obj killer = getObjVar(this, "myLastKiller");
		removeObjVar(this, "myLastKiller");
		record_kill(killer, this);
		break;
	case 0x01
		systemMessage(this, "You have cancelled the bounty reporting process.");
		break;
	default
		systemMessage(this, "You have cancelled the bounty reporting process.");
		break;
	}
	return(0x01);
}

function int can_report_death(obj killer, obj victim) {
	int killer_kill_count = get_kill_count(killer);
	int victim_kill_count = get_kill_count(victim);
	if (!isPlayer(killer)) {
		return(0x00);
	}
	if (!isPlayer(victim)) {
		return(0x00);
	}
	if (killer_kill_count < victim_kill_count) {
		if (0x00) {
			bark(victim, "Killer's killcount lower than victim's");
		}
		systemMessage(victim, "You cannot report this death because the person who killed you has slain less people than you have.");
		return(0x00);
	}
	if (getNotorietyLevel(victim) < (0x00 - 0x01)) {
		if (0x00) {
			bark(victim, "Victim's notoriety too low to report.");
		}
		systemMessage(victim, "You cannot report this death to Lord British's guards because your notoriety is too low.");
		return(0x00);
	}
	if (isCriminal(victim)) {
		if (0x00) {
			bark(victim, "Victim flagged criminal");
		}
		systemMessage(victim, "You cannot report this death to Lord British's guards because you are flagged as a criminal because of your recent deeds.");
		return(0x00);
	}
	if (!hasObjVar(victim, "lastCriminal")) {
		if (0x00) {
			bark(victim, "Victim doesn't have lastCriminal attached");
		}
		return(0x00);
	}
	obj last_criminal = getObjVar(victim, "lastCriminal");
	if (last_criminal != killer) {
		if (0x00) {
			bark(victim, "Victim's last criminal doesn't match killer");
		}
		return(0x00);
	}
	return(0x01);
}

function int process_kill_report(obj killer, obj victim) {
	if (can_report_death(killer, victim)) {
		shortCallback(victim, 0x01, 0x8C);
		if (0x00) {
			bark(victim, "Allowed to report!");
		}
	}
	if (0x00) {
		bark(killer, "Returning killcount.");
		string kill_count_str;
		int count = get_kill_count(killer);
		kill_count_str = count;
		bark(killer, kill_count_str);
	}
	return(get_kill_count(killer));
}

trigger callback(0x8C) {
	if (getMobFlag(this, 0x02)) {
		shortCallback(this, 0x01, 0x8C);
		return(0x01);
	}
	obj killer = getObjVar(this, "bountyKiller");
	prompt_report_murder(killer, this);
	return(0x01);
}

function string get_hair_color(obj killer) {
	obj hair = getItemAtSlot(killer, 0x0B);
	if (hair == NULL()) {
		return("indeterminate color");
	}
	int hue = getHue(hair);
	hue = hue - 0x044C;
	switch(hue) {
	case 0x01
	case 0x02
	case 0x03
		return("white");
		break;
	case 0x04
	case 0x05
	case 0x06
		return("graying");
		break;
	case 0x07
	case 0x08
		return("black hair");
	case 0x09
	case 0x0A
	case 0x0B
		return("copper");
		break;
	case 0x0C
	case 0x0D
	case 0x0E
	case 0x0F
		return("brown");
		break;
	case 0x10
		return("reddish brown");
		break;
	case 0x11
	case 0x12
	case 0x13
		return("blonde");
		break;
	case 0x14
	case 0x15
	case 0x16
		return("light brown");
		break;
	case 0x17
	case 0x18
		return("golden brown");
		break;
	case 0x19
	case 0x1A
	case 0x1B
		return("golden");
		break;
	case 0x1C
	case 0x1D
	case 0x1E
		return("bronze");
		break;
	case 0x1F
	case 0x20
		return("dark brown");
		break;
	case 0x21
	case 0x22
		return("sandy");
		break;
	case 0x23
	case 0x24
	case 0x25
		return("honey-colored");
		break;
	case 0x26
	case 0x27
	case 0x28
		return("red");
		break;
	case 0x29
	case 0x2A
	case 0x2B
		return("nut brown");
		break;
	case 0x2C
	case 0x2D
	case 0x2E
		return("rich brown");
		break;
	case 0x2F
	case 0x30
		return("very dark brown");
		break;
	}
	return("outlandishly colored");
}

function string get_hair_style(obj killer) {
	obj hair = getItemAtSlot(killer, 0x0B);
	string style;
	switch(getObjType(hair)) {
	case 0x2049
		style = "hair in two pigtails";
		break;
	case 0x2047
		style = "curly hair";
		break;
	case 0x2046
		style = "hair tied in buns";
		break;
	case 0x204A
		style = "shaved head and topknot";
		break;
	case 0x203C
		style = "hair worn long";
		break;
	case 0x2044
		style = "a mohawk hairstyle";
		break;
	case 0x203D
		style = "hair tied back";
		break;
	case 0x2045
		style = "pageboy hair";
		break;
	case 0x2048
		style = "receding hairline";
		break;
	case 0x203B
		style = "hair worn short";
		break;
	default
		style = "bald";
		break;
	}
	return(style);
}

function string get_skin_tone(obj killer) {
	string tone;
	int hue = getHue(killer);
	hue = hue - 0x03E8;
	hue = hue - 0x8000;
	if (0x00) {
		string hue_str = hue;
		bark(killer, hue_str);
	}
	switch(hue) {
	case 0x0F
	case 0x16
	case 0x1D
	case 0x1E
	case 0x24
	case 0x25
		tone = "pale";
		break;
	case 0x08
	case 0x09
	case 0x17
	case 0x1F
	case 0x2C
	case 0x2D
	case 0x01
	case 0x02
	case 0x10
	case 0x11
	case 0x12
	case 0x2E
		tone = "fair";
		break;
	case 0x0A
	case 0x0B
	case 0x13
	case 0x18
	case 0x19
	case 0x20
	case 0x26
	case 0x27
	case 0x28
	case 0x2F
		tone = "tanned";
		break;
	case 0x03
	case 0x04
	case 0x05
	case 0x0C
	case 0x1A
	case 0x29
	case 0x2A
	case 0x30
	case 0x38
		tone = "copper";
		break;
	case 0x06
	case 0x07
	case 0x0D
	case 0x0E
	case 0x14
	case 0x15
	case 0x1B
	case 0x1C
	case 0x21
	case 0x22
	case 0x23
	case 0x2B
	case 0x31
	case 0x32
	case 0x39
		tone = "dark";
		break;
	case 0x33
	case 0x34
	case 0x35
		tone = "yellow";
		break;
	default
		tone = "pimply";
		break;
	}
	return(tone);
}

function string rand_accusation(obj killer) {
	list phrases = "hath murdered one too many!", "hath killed " + getHisHer(killer) + " last!", "shall not slay again!", "hath slain too many!", "cannot continue to kill!", "must be stopped.", "is a bloodthirsty monster.", "is a killer of the worst sort.", "hath no conscience!", "hath cowardly slain many.", "must die for all our sakes.", "sheds innocent blood!", "must fall to preserve us.", "must be taken care of.", "is a thug and must die.", "cannot be redeemed.", "is a shameless butcher.", "is a callous monster.", "is a cruel, casual killer.";
	string phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(phrase);
}

function string rand_preamble(obj killer) {
	list phrases = "  A bounty is hereby offered", "  Lord British sets a price", "  Claim the reward! 'Tis", "  Lord Blackthorn set a price", "  The Paladins set a price", "  The Merchants set a price", "  Lord British's bounty ";
	string phrase = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(phrase);
}

function obj find_post_for_killer(obj board, obj m_target) {
	obj post;
	obj killer;
	obj tmp;
	list contents;
	getContents(contents, board);
	int count = numInList(contents);
	for (int i = 0x00; i < count; i++) {
		post = contents[i];
		if (getObjType(post) == 0x0EB0) {
			if (hasObjVar(post, "killer")) {
				killer = getObjVar(post, "killer");
				if (killer == m_target) {
					return(post);
				}
			}
		}
	}
	return(NULL());
}

function void postKillerToBB(obj killer) {
	if (!hasObjListVar(killer, "killcount")) {
		detachScript(this, "bounty");
		return();
	}
	list kill_list;
	getObjListVar(kill_list, killer, "killcount");
	obj bboard = findClosestBBoard(getLocation(this));
	obj parchment;
	parchment = find_post_for_killer(bboard, killer);
	if (parchment == NULL()) {
		parchment = createNoResObjectIn(0x0EB0, bboard);
	}
	setObjVar(parchment, "killer", killer);
	obj bank = getItemAtSlot(killer, 0x1D);
	obj gold = doTakeMoney(bank, 0x0EED, 0xC350);
	if (gold == NULL()) {
		if (0x00) {
			bark(killer, "NULL reward!");
		}
	}
	string reward = "alas, zero";
	if (gold != NULL()) {
		int tp_result = teleport(gold, getLocation(killer));
		int gold_amount;
		int blah = getResource(gold_amount, gold, "gold", 0x03, 0x02);
		if (0x00) {
			reward = gold_amount;
			systemMessage(killer, "Gold resource from bank:");
			systemMessage(killer, reward);
		}
		transferResources(parchment, gold, gold_amount, "gold");
		if (0x00) {
			blah = getResource(gold_amount, gold, "gold", 0x03, 0x02);
			reward = gold_amount;
			systemMessage(killer, "Gold resource on gold after transfer:");
			systemMessage(killer, reward);
		}
		blah = getResource(gold_amount, parchment, "gold", 0x03, 0x02);
		if (0x00) {
			reward = gold_amount;
			systemMessage(killer, "Gold resource from board:");
			systemMessage(killer, reward);
		}
		reward = gold_amount;
		if (0x00) {
			bark(killer, "reward!");
			bark(killer, reward);
		}
		deleteObject(gold);
	}
	string title_prefix;
	string title_suffix;
	string victim_name_a;
	string victim_name_b;
	switch(random(0x00, 0x05)) {
	case 0x00
		default
		title_prefix = "Bounty for ";
		title_suffix = "!";
		break;
	case 0x01
		title_prefix = "";
		title_suffix = " must die!";
		break;
	case 0x02
		title_prefix = "A price on ";
		title_suffix = "!";
		break;
	case 0x03
		title_prefix = "";
		title_suffix = " outlawed!";
		break;
	case 0x04
		title_prefix = "Execute ";
		title_suffix = "!";
		break;
	case 0x05
		title_prefix = "WANTED: ";
		title_suffix = "!";
		break;
	}
	victim_name_a = kill_list[random(0x00, numInList(kill_list) - 0x01)];
	victim_name_b = kill_list[random(0x00, numInList(kill_list) - 0x01)];
	int kill_count = get_kill_count(killer);
	string dead = kill_count;
	list postText = title_prefix + getName(killer) + title_suffix, "  The foul scum known as", getName(killer), rand_accusation(killer), "For " + getHeShe(killer) + " is guilty of " + dead, "murders, among them those", "of " + victim_name_a + " and ", victim_name_b + ".", rand_preamble(killer), "of " + reward + " gold pieces", "for " + getHisHer(killer) + " head!", "  A description:", "    - " + get_hair_color(killer) + " hair", "    - " + get_hair_style(killer), "    - " + get_skin_tone(killer) + " skin", "  If you kill " + getHimHer(killer) + ", bring the", "head to a guard here in this", "city to claim your reward.";
	setObjVar(parchment, "postText", postText);
	return();
}

function void setBounty(obj killer) {
	string debug_msg;
	postKillerToBB(killer);
	attachScript(killer, "bountymark");
	setNotoriety(killer, (0x00 - 0x7F));
	barkTo(killer, killer, "A bounty hath been issued for thee, and thy worldly goods are hereby confiscated!");
	obj bank = getItemAtSlot(killer, 0x1D);
	list bank_contents;
	getContents(bank_contents, bank);
	for (int i = 0x00; i < numInList(bank_contents); i++) {
		bank = bank_contents[i];
		if (0x00) {
			debug_msg = "Deleting bank item: " + getName(bank);
			systemMessage(killer, debug_msg);
		}
		deleteObject(bank);
	}
	return();
}

function void apply_bounty_on_kill(obj killer, obj victim) {
	if (process_kill_report(killer, victim) > 0x0A) {
		setBounty(killer);
	}
	return();
}

trigger creation {
	if (!hasObjVar(this, "bountyKiller")) {
		if (0x00) {
			bark(this, "Error attaching bounty script.");
		}
		detachScript(this, "bounty");
		return(0x01);
	}
	obj killer = getObjVar(this, "bountyKiller");
	apply_bounty_on_kill(killer, this);
	return(0x01);
}

trigger speech("add") {
	if (0x00) {
		apply_bounty_on_kill(speaker, this);
	}
	return(0x01);
}

trigger speech("count") {
	if (0x00) {
		string kill_count_str;
		int bar = get_kill_count(this);
		kill_count_str = bar;
		bark(this, kill_count_str);
	}
	return(0x01);
}
