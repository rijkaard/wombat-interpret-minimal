inherits globals;

function int start_loot(obj looter, obj corpse) {
	setObjVar(looter, "looter", looter);
	setObjVar(looter, "corpse", corpse);
	if (0x00) {
		bark(looter, "Issuing callback.");
	}
	shortCallback(looter, 0x0F, 0xEA);
	return(0x00);
}

trigger callback(0xEA) {
	if (0x00) {
		bark(this, "Callback received.");
	}
	obj looter = getObjVar(this, "looter");
	obj corpse = getObjVar(this, "corpse");
	if (corpse == NULL()) {
		if (0x00) {
			bark(looter, "The corpse is null!");
		}
	}
	list targets;
	getTargets(targets, looter);
	if (numInList(targets)) {
		if (0x00) {
			bark(looter, "Too busy fighting to loot.");
		}
		shortCallback(looter, 0x1E, 0xEA);
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(looter), getLocation(corpse)) > 0x02) {
		setObjVar(looter, "corpseToLoot", corpse);
		if (0x00) {
			bark(looter, "Walking over to loot now.");
		}
		if (isHuman(looter)) {
			ebark(looter, "Let's see what there is to loot!");
		}
		walkTo(looter, getLocation(corpse), 0x16);
		return(0x01);
	}
	list contents;
	getContents(contents, corpse);
	if (numInList(contents) < 0x01) {
		if (0x00) {
			bark(looter, "The corpse is empty!");
		}
		return(0x00);
	}
	obj best_item;
	obj item;
	if (0x00) {
		int b;
		string count_str;
		b = numInList(contents);
		count_str = b;
		bark(looter, count_str);
	}
	for (int i = 0x00; i < numInList(contents); i++) {
		item = contents[i];
		if (getValue(item) > getValue(best_item)) {
			if ((getObjType(item) < 0x203B) || (getObjType(item) > 0x204F)) {
				if (0x00) {
					bark(looter, "Found an item in the valid range.");
				}
				best_item = item;
			}
		}
	}
	if (best_item == NULL()) {
		if (0x00) {
			bark(looter, "Nothing worth taking.");
		}
		return(0x00);
	}
	obj backpack = getBackpack(looter);
	if (backpack == NULL()) {
		backpack = looter;
	}
	int put_result = putObjContainer(best_item, backpack);
	if (0x00) {
		string msg;
		msg = "Ha ha! I grabbed " + getName(best_item) + " from this corpse!!";
		bark(looter, msg);
	}
	if (isHuman(looter)) {
		list phrases = "Ah, look what I get! ", "Hmm, let me see what they had... ", "And now for the spoils...! ", "The spoils of war... let me see... ", "And what pretties dost thou carry, eh? ", "Hmm, did they have anything interesting? ", "I wonder what they had that is now mine? ", "Mine! Mine! ", "Hmm... ", "Aha! ", "Well, look here... ", "Finders keepers! ", "Ah, booty! ", "Plundering corpses is SO distasteful! ", "Hm, messy. Ah... ", "A bit untidy. Let's see what they had... ", "What did you have on you? ", "Anything worthwhile here? ", "Hmm, this looks good. ", "", "", "", "", "", "", "", "", "", "", "";
		msg = phrases[random(0x00, numInList(phrases) - 0x01)];
		string suffix = getName(best_item) + ".";
		toUpper(suffix, 0x00, 0x01);
		msg = msg + suffix;
		phrases = " Nice.", " Hmph.", " Not bad!", " A paltry reward.", " What am I supposed to do with this?", " The best they had. Oh well.", " Goodie!", " Excellent!", " I can make use of this!", " Useful indeed.", " Quite nice!", " Hmm.", " Might be worth something.";
		suffix = phrases[random(0x00, numInList(phrases) - 0x01)];
		msg = msg + suffix;
		ebark(looter, msg);
		animateMobile(looter, 0x20, 0x05, 0x01, 0x00, 0x03);
	} else {
		msg = "*" + getName(looter) + " rummages through " + getName(corpse) + " and takes " + getName(best_item) + "*";
		ebark(looter, msg);
		if (getObjType(looter) < 0xC8) {
			animateMobile(looter, 0x0B, 0x05, 0x01, 0x00, 0x00);
		} else {
			animateMobile(looter, 0x03, 0x05, 0x01, 0x00, 0x00);
		}
	}
	if (random(0x00, 0x01) == 0x00) {
		if (0x00) {
			bark(looter, "This was so much fun, I'm going to do it again!");
		}
		start_loot(looter, corpse);
	}
	return(0x01);
}

trigger pathfound(0x16) {
	if (!hasObjVar(this, "corpseToLoot")) {
		return(0x01);
	}
	obj corpse = getObjVar(this, "corpseToLoot");
	removeObjVar(this, "corpseToLoot");
	if (0x00) {
		bark(this, "I made it to the corpse, so let's loot!");
	}
	start_loot(this, corpse);
	return(0x01);
}

trigger sawdeath {
	if (0x00) {
		bark(this, "I saw a death!");
	}
	if (isHuman(this)) {
		if (attacker != this) {
			if (0x00) {
				bark(this, "But I wasn't the killer, so never mind.");
			}
			return(0x00);
		}
	}
	start_loot(this, corpse);
	return(0x00);
}
