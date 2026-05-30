inherits globals;

member list bounty_list;

function void register_board() {
	list args;
	multiMessageToLoc(getMasterObjLoc(0x00), "registerBoard", args);
	return();
}

trigger callback(0x2F) {
	register_board();
	return(0x01);
}

trigger objectloaded {
	callback(this, 0x01, 0x2F);
	list contents;
	getContents(contents, this);
	for (int i = numInList(contents); i; i--) {
		deleteObject(contents[0x00]);
		removeItem(contents, 0x00);
	}
	return(0x00);
}

trigger creation {
	register_board();
	return(0x01);
}

trigger lookedat {
	list contents;
	getContents(contents, this);
	int count = 0x00;
	for (int i = numInList(contents); i; i--) {
		if (hasObjVar(contents[0x00], "killer")) {
			count++;
		}
		removeItem(contents, 0x00);
	}
	barkTo(this, looker, "a bounty board with " + count + " posted bounties");
	return(0x00);
}

forward void postKillerToBB(list args);

trigger message("clearBounties") {
	list contents;
	getContents(contents, this);
	for (int i = numInList(contents); i; i--) {
		deleteObject(contents[0x00]);
		removeItem(contents, 0x00);
	}
	return(0x01);
}

trigger message("setBounty") {
	postKillerToBB(args);
	return(0x01);
}

function string get_hair_color(int hue) {
	if (!hue) {
		return("");
	}
	hue = hue - 0x044C;
	switch(hue) {
	case 0x00
		return("indeterminate color");
		break;
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

function string get_hair_style(int hair_type) {
	string style;
	switch(hair_type) {
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

function string get_skin_tone(int hue) {
	string result;
	hue = hue - 0x03E8;
	hue = hue - 0x8000;
	switch(hue) {
	case 0x0F
	case 0x16
	case 0x1D
	case 0x1E
	case 0x24
	case 0x25
		result = "pale";
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
		result = "fair";
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
		result = "tanned";
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
		result = "copper";
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
		result = "dark";
		break;
	case 0x33
	case 0x34
	case 0x35
		result = "yellow";
		break;
	default
		result = "deathly";
		break;
	}
	return(result);
}

function string get_killer_phrase(int murderCount) {
	list phrases = "hath murdered one too many!", "shall not slay again!", "hath slain too many!", "cannot continue to kill!", "must be stopped.", "is a bloodthirsty monster.", "is a killer of the worst sort.", "hath no conscience!", "hath cowardly slain many.", "must die for all our sakes.", "sheds innocent blood!", "must fall to preserve us.", "must be taken care of.", "is a thug and must die.", "cannot be redeemed.", "is a shameless butcher.", "is a callous monster.", "is a cruel, casual killer.";
	string result = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(result);
}

function string get_bounty_intro(int bounty) {
	list phrases = "  A bounty is hereby offered", "  Lord British sets a price", "  Claim the reward! 'Tis", "  Lord Blackthorn set a price", "  The Paladins set a price", "  The Merchants set a price", "  Lord British's bounty ";
	string result = phrases[random(0x00, numInList(phrases) - 0x01)];
	return(result);
}

function obj find_posting_for_killer(obj board, obj target_killer) {
	obj posting;
	obj killer;
	obj posted_killer;
	list contents;
	getContents(contents, board);
	int count = numInList(contents);
	for (int i = 0x00; i < count; i++) {
		posting = contents[i];
		if (getObjType(posting) == 0x0EB0) {
			if (hasObjVar(posting, "killer")) {
				killer = getObjVar(posting, "killer");
				if (killer == target_killer) {
					return(posting);
				}
			}
		}
	}
	return(NULL());
}

function void postKillerToBB(list args) {
	debugMessage("postKillerToBB:  args=");
	printList(args);
	obj killer = args[0x00];
	int bounty = args[0x01];
	string killer_name = args[0x02];
	list postText = killer_name + ":  " + bounty + "gold.                      ";
	if (numInList(args) > 0x03) {
		int murderCount = oprlist(args[0x03], 0x00);
		int is_female = oprlist(args[0x03], 0x01);
		int hair_type = oprlist(args[0x03], 0x02);
		int hair_hue = oprlist(args[0x03], 0x03);
		int skin_hue = oprlist(args[0x03], 0x04);
		obj bounty_post = find_posting_for_killer(this, killer);
		if (bounty_post == NULL()) {
			bounty_post = createNoResObjectIn(0x0EB0, this);
		}
		setObjVar(bounty_post, "killer", killer);
		string title_prefix;
		string title_suffix;
		string unused_a;
		string unused_b;
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
		string obj_pronoun;
		string poss_pronoun;
		string subj_pronoun;
		if (is_female) {
			obj_pronoun = "her";
			poss_pronoun = "her";
			subj_pronoun = "she";
		} else {
			obj_pronoun = "him";
			poss_pronoun = "his";
			subj_pronoun = "he";
		}
		int wrap_count = wordWrap(postText, "The foul scum known as " + killer_name + " " + get_killer_phrase(murderCount) + "  For " + subj_pronoun + " is responsible for " + murderCount + " murders.  " + get_bounty_intro(bounty) + " of " + bounty + " gold pieces for " + poss_pronoun + " head!", 0x1C);
		appendToList(postText, "  A description:");
		if (hair_hue) {
			appendToList(postText, "    - " + get_hair_color(hair_hue) + " hair");
		}
		appendToList(postText, "    - " + get_hair_style(hair_type));
		appendToList(postText, "    - " + get_skin_tone(skin_hue) + " skin");
		appendToList(postText, "If you kill " + obj_pronoun + ", remove the");
		appendToList(postText, "head, and give it to a guard");
		appendToList(postText, "to claim your reward.");
	} else {
		appendToList(postText, "No information available.");
	}
	setObjVar(bounty_post, "postText", postText);
	setPostTime(bounty_post);
	return();
}
