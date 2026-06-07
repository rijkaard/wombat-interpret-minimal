inherits tilesets;

trigger creation {

member int greeted = 0x00;

member int needs_hammer = 0x00;

member int needs_sword = 0x00;

member int sword_given = 0x00;

member int quest_active = 0x00;

member obj sword;
	return(0x01);
}

trigger enterrange(0x05) {
	if (isPlayer(target)) {
		list args = 0x03;
		multimessage(target, "foundme", args);
		if (sword_given) {
			ebark(this, "It is good to have you back sir, but I have done all I can for thee, it is now up to you to save our village.");
			return(0x01);
		}
		if (needs_hammer) {
			ebark(this, "Hello again! Have you found a smith's hammer for me yet?  I can't make that sword without it!");
			return(0x01);
		}
		if (needs_sword) {
			ebark(this, "Greetings my friend, have you brought me a longsword?");
			return(0x01);
		}
		if (greeted) {
			ebark(this, "Greetings again, sir.  Have you had any luck on your quest?");
			return(0x01);
		}
		bark(this, "Ah, a guest in my home, greetings my friend!");
		greeted = 0x01;
		return(0x01);
	}
	return(0x01);
}

trigger speech("*") {
	if (!isPlayer(speaker)) {
		return(0x00);
	}
	list args = 0x03;
	list text;
	string word;
	split(text, arg);
	for (int i = 0x00; i < numInList(text); i++) {
		word = text[i];
		if ((word == "dragon") || (word == "slay")) {
			if (needs_hammer) {
				message(speaker, "hammerquest", args);
				ebark(this, "The dragon won't be a problem after I make you an enchanted sword, but I need a smith's hammer to do so.");
				return(0x00);
			}
			if (needs_sword) {
				message(speaker, "swordquest", args);
				ebark(this, "The dragon won't be a problem after I make you an enchanted sword, but I need an ordinary longsword to do so.");
				return(0x00);
			}
			if (sword_given) {
				ebark(this, "With the sword I gave you, you should be able to kill the dragon, perhaps in a single blow!");
				return(0x00);
			}
			ebark(this, "Ahh, a young dragonslayer are you?  Well you will need help.  Bring me a smith's hammer, and I can make you an enchanted sword to slay the beast with!");
			message(speaker, "hammerquest", args);
			needs_hammer = 0x01;
			needs_sword = 0x01;
			quest_active = 0x01;
			return(0x00);
		}
		if (word == "hammer") {
			ebark(this, "You should be able to get a smith's hammer from the blacksmith in town for a modest price.");
			return(0x00);
		}
		if ((word == "sword") || (word == "longsword")) {
			ebark(this, "You should be able to get a longsword from the blacksmith in town for a modest price.");
			return(0x00);
		}
		if (word == "quest") {
			ebark(this, "Well, if you got bored, you could always go slay that cursed dragon!");
			return(0x00);
		}
		if ((word == "help") || (word == "assistance")) {
			if (needs_hammer) {
				ebark(this, "You should be able to get a smith's hammer from the blacksmith in town for a modest price.");
				return(0x00);
			}
			if (needs_sword) {
				ebark(this, "You should be able to get a longsword from the blacksmith in town for a modest price.");
				return(0x00);
			}
			if (sword_given) {
				ebark(this, "The sword I gave you is all the help I can render you.");
				return(0x00);
			}
			ebark(this, "What was it you needed help with?");
			return(0x00);
		}
		if ((word == "sword") || (word == "glass") || (word == "enchanted") || (word == "longsword")) {
			if (needs_hammer) {
				ebark(this, "Given a smith's hammer and an ordinary longsword, I can make an enchanted sword!");
				return(0x00);
			}
			if (needs_sword) {
				ebark(this, "I'll need a regular longsword to make an enchanted sword of.");
				return(0x00);
			}
			if (sword_given) {
				ebark(this, "That sword does potent damage, but has very limited use.");
				return(0x00);
			}
			ebark(this, "I can make an enchanted sword, but I'll need a smith's hammer and an ordinary longsword to do so.");
			return(0x00);
			needs_hammer = 0x01;
			needs_sword = 0x01;
			quest_active = 0x01;
			return(0x00);
		}
	}
	return(0x01);
}

trigger give {
	int obj_type;
	obj_type = getObjType(givenobj);
	int ok;
	int tmp;
	obj where;
	list args;
	if ((obj_type == 0x0FB4) || (obj_type == 0x0FB5) || (obj_type == 0x13E3) || (obj_type == 0x13E4)) {
		if (sword_given) {
			ebark(this, "I have already made you a glass sword, that is all I can do for you.");
			return(0x01);
		}
		if (needs_hammer) {
			if (quest_active) {
				needs_hammer = 0x00;
			}
			ok = putObjContainer(givenobj, this);
			if (!ok) {
				ok = teleport(givenobj, getLocation(this));
				ebark(this, "Oops, I dropped it.");
			}
			if (needs_sword) {
				ebark(this, "Yes, with this I can make you an enchanted sword to slay the dragon with!  All I need now is your longsword... you do have one don't you?");
				multimessage(giver, "swordquest", args);
			}
		}
		if ((!needs_hammer) && (!needs_sword) && quest_active) {
			ebark(this, "Good, now I will make your glass sword.  Remember you can only use it once, and I can not make another!");
			attachScript(sword, "glasssword");
			sfx(getLocation(this), 0x3E, 0x3E);
			systemMessage(giver, "The sage chants for a moment, and hits your longsword with the hammer shattering the steel and revealing a blade of glass!");
			where = giveItem(giver, sword);
			message(giver, "givenglass", args);
			sword_given = 0x01;
		}
		return(0x00);
	}
	if (((obj_type > 0x0F5D) && (obj_type < 0x0F62)) || ((obj_type > 0x13B6) && (obj_type < 0x13BB))) {
		if (sword_given) {
			ebark(this, "I have already made you a glass sword, that is all I can do for you.");
			return(0x01);
		}
		if (needs_sword) {
			if (quest_active) {
				needs_sword = 0x00;
			}
			ok = putObjContainer(givenobj, this);
			if (!ok) {
				ok = teleport(givenobj, getLocation(this));
				ebark(this, "Oops, I dropped it.");
			}
			sword = givenobj;
			if (needs_hammer) {
				ebark(this, "I can make an enchanted sword from this, but I still need a hammer.");
				message(giver, "hammerquest", args);
			}
		}
		if ((!needs_hammer) && (!needs_sword) && quest_active) {
			ebark(this, "Good, now I will make your glass sword.  Remember you can only use it once, and I can not make another!");
			attachScript(sword, "glasssword");
			sfx(getLocation(this), 0x3E, 0x3E);
			systemMessage(giver, "The sage chants for a moment, and hits your longsword with the hammer shattering the steel and revealing a blade of glass!");
			where = giveItem(giver, sword);
			message(giver, "givenglass", args);
			sword_given = 0x01;
		}
		return(0x00);
	}
	return(0x01);
}
