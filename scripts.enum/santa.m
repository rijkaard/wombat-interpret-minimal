inherits sndfx;

trigger 0x01F4 enterrange(0x05) {
	list greetings = "Ho ho ho!", "Happy holidays!", "A merry season to thee!", "Enjoy the holidays!", "Ho ho ho! Happy holidays!", "May thy holidays be joyful!", "Enjoy the season!", "I wish thee the joy of the season!", "I wish thee joy! Ho ho ho!", "Naughty or nice? Hmm.", "Where IS Rudolph? He's never this late.", "Dancer, Prancer, don't wander off.", "If I only had a sleigh...", "I think I'm going to cause a worldwide shortage of coal this year.", "British? Coal or a fruitcake? Hmm.", "Hmm, coal, or a fruitcake for Blackthorn?", "Hmm, I seem to have lost some weight.";
	string greeting = greetings[random(0x00, numInList(greetings) - 0x01)];
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(target)));
	animateMobile(this, 0x21, 0x05, 0x01, 0x00, 0x01);
	ebarkTo(this, target, greeting);
	return(0x01);
}

trigger give {
	list item_resources;
	int k;
	int i;
	int j;
	int put_result;
	int wanted;
	list food_wants;
	list desire_wants;
	list reserve_wants;
	string food_res;
	string desire_res;
	string reserve_res;
	string item_res;
	string item_name;
	int is_food;
	item_name = getName(givenobj);
	if (getResourcesOnObj(givenobj, 0x03, item_resources)) {
		if (getResourcesOnObj(this, 0x00, food_wants)) {
			for (i = 0x00; i < numInList(food_wants); i++) {
				for (j = 0x00; j < numInList(item_resources); j++) {
					food_res = food_wants[i];
					item_res = item_resources[j];
					if (food_res == item_res) {
						is_food = 0x01;
						wanted = 0x01;
						item_name = getResourceName(food_res, 0x00);
					}
				}
			}
		}
		if (getResourcesOnObj(this, 0x02, desire_wants)) {
			for (i = 0x00; i < numInList(desire_wants); i++) {
				for (j = 0x00; j < numInList(item_resources); j++) {
					desire_res = desire_wants[i];
					item_res = item_resources[j];
					if (desire_res == item_res) {
						setDesireLevel(this, 0x64);
						wanted = 0x01;
						item_name = getResourceName(desire_res, 0x02);
					}
				}
			}
		}
		string greeting;
		greeting = "Thou art giving me " + item_name + "?";
		bark(this, greeting);
		obj placed_obj;
		int gold_amt;
		int res_ok;
		if (wanted) {
			if (getObjType(givenobj) == 0x0EED) {
				string gold_msg;
				res_ok = getResource(gold_amt, givenobj, "gold", 0x03, 0x02);
				if (gold_amt > 0xFA) {
					gold_msg = "'Tis a noble gift.";
				} else {
					gold_msg = "Money is always welcome.";
				}
				bark(this, gold_msg);
			}
			put_result = putObjContainer(givenobj, this);
			if (!put_result) {
				put_result = teleport(givenobj, getLocation(this));
				bark(this, "Oops, I dropped it.");
			}
			if (is_food) {
				bark(this, "This tasteth good.");
				list sfx_list = 0x3C, 0x3B, 0x3A;
				sfx(getLocation(this), sfx_list[random(0x00, 0x02)], 0x00);
			}
			if (!getCompileFlag(0x01)) {
				if (getNotorietyLevel(giver) <= 0x01) {
					addNotoriety(giver, 0x01);
				}
			} else {
				changeFame(giver, getValue(givenobj));
				if (getKarmaLevel(giver) < 0x00) {
					changeKarma(giver, (0x00 - getValue(givenobj)));
				} else {
					changeKarma(giver, getValue(givenobj));
				}
			}
			deleteObject(givenobj);
			intRet(0x01);
			return(0x00);
		}
	}
	bark(this, "I am not interested in this.");
	replyTo(this, giver, "@InternalRefuseItem");
	if (giveItem(giver, givenobj) == NULL()) {
		bark(this, "Thy hands are full, so here 'tis, on the ground.");
		i = teleport(givenobj, getLocation(giver));
	}
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
