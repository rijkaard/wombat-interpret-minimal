inherits globals;

forward void run_step();

forward void set_hint_text();

forward void destroy_wisp();

forward void spawn_wisp();

forward void bark_via_wisp(string msg);

forward void create_board_post();

member int state;

trigger death {
	setCurHP(this, 0x03);
	attack(this, attacker);
	return(0x00);
}

trigger online {
	loc spawn_loc = 0x0D6D, 0x0A56, 0x27;
	obj backpack = getBackpack(this);
	obj wisp = createGlobalNPCAt(0x05E0, spawn_loc, 0x05);
	int result = putObjContainer(wisp, backpack);
	state = 0x01;
	callback(this, 0x09, 0x0001046C);
	return(0x01);
}

trigger creation {
	loc spawn_loc = 0x0E56, 0x0A3A, 0x00;
	int teleport_result = teleport(this, spawn_loc);
	faceHere(this, 0x04);
	state = 0x01;

member string hint_msg = "";

member int hint_repeat_count;

member obj pack = getBackpack(this);
	attachScript(pack, "tutpack");

member loc sage_loc = 0x0E9B, 0x0A7A, 0x28;

member loc armorer_loc = 0x0E38, 0x0A23, 0x00;

member loc blacksmith_loc = 0x0E38, 0x0A23, 0x00;

member loc ranger_loc = 0x0E1C, 0x09AB, 0x00;

member loc waypoint_loc;

member loc dragon_loc = 0x0D6D, 0x0A56, 0x27;

member loc board_loc = 0x0E56, 0x0A60, (0x00 - 0x02);

member obj sage = createGlobalNPCAt(0x4C, sage_loc, 0x01);

member obj armorer = createGlobalNPCAt(0x35, blacksmith_loc, 0x01);

member obj provisioner = armorer;

member obj ranger = createGlobalNPCAt(0x4B, ranger_loc, 0x01);

member obj dragon = createGlobalNPCAt(0x0221, dragon_loc, 0x01);

member obj board = createGlobalObjectAt(0x1E5E, board_loc);
	loc door_search_loc = 0x0E54, 0x0A3F, 0x00;
	obj door1;
	obj door2;
	list doors;
	getObjectsInRange(doors, door_search_loc, 0x02);
	if (numInList(doors) > 0x00) {
		door1 = doors[0x00];
	}
	if (numInList(doors) > 0x01) {
		door2 = doors[0x01];
	}
	faceHere(sage, 0x04);
	setMaxFatigue(sage, 0x00);
	setCurFatigue(sage, 0x00);
	setMaxFatigue(armorer, 0x00);
	setCurFatigue(armorer, 0x00);
	setMaxFatigue(ranger, 0x00);
	setCurFatigue(ranger, 0x00);
	setMaxFatigue(dragon, 0x00);
	setCurFatigue(dragon, 0x00);
	attachScript(sage, "tutsage");
	attachScript(armorer, "tutarmorer");
	attachScript(armorer, "tutprovisioner");
	attachScript(ranger, "tutranger");
	attachScript(dragon, "tutdragon");
	attachScript(board, "tutboard");
	if (door1 != NULL()) {
		attachScript(door1, "tutdoor");
	}
	if (door2 != NULL()) {
		attachScript(door2, "tutdoor");
	}
	create_board_post();
	return(0x01);
}

trigger message("givenglass") {
	state = 0x11;
	run_step();
	return(0x00);
}

trigger message("hammerquest") {
	if ((hasObjType(this, 0x0FB4)) || (hasObjType(this, 0x0FB5)) || (hasObjType(this, 0x13E3)) || (hasObjType(this, 0x13E4))) {
		state = 0x0B;
		hint_msg = "You need to open your inventory to give the hammer to the sage, open it by pressing Alt-I.";
		callback(this, 0x0A, 0x0001046A);
		return(0x00);
	} else {
		state = 0x08;
	}
	run_step();
	return(0x00);
}

trigger message("swordquest") {
	if ((hasObjType(this, 0x0F5E)) || (hasObjType(this, 0x0F5F)) || (hasObjType(this, 0x0F60)) || (hasObjType(this, 0x0F61)) || (hasObjType(this, 0x13B7)) || (hasObjType(this, 0x13B9)) || (hasObjType(this, 0x13B9)) || (hasObjType(this, 0x13BA))) {
		state = 0x10;
		hint_msg = "Drag your sword from your inventory to the sage to give it to him, if you have it wielded, drag it from your 'paper doll,' which you open by pressing Alt-P.";
		callback(this, 0x0A, 0x0001046A);
		return(0x00);
	} else {
		state = 0x0D;
	}
	run_step();
	return(0x00);
}

trigger message("usedme") {
	switch(args[0x00]) {
	case 0x01
		if (state == 0x02) {
			state = 0x03;
			run_step();
		}
		break;
	case 0x02
		if (state == 0x04) {
			state = 0x05;
			run_step();
		}
		break;
	case 0x08
		if (state == 0x0B) {
			state = 0x0C;
			run_step();
		}
		break;
	case 0x06
		if (state == 0x12) {
			state = 0x13;
			callback(this, 0x03, 0x000182AD);
			run_step();
		}
		break;
	case 0x0A
		if (getSkillLevel(this, SKILL_TRACKING) > 0x46) {
			state = 0x16;
			run_step();
		}
		break;
	case 0x07
		state = 0x18;
		break;
	case 0x09
		hint_msg = "Well, I have helped you all I can, I hope your adventures are as pleasant as they will be exciting!";
		bark_via_wisp(hint_msg);
		obj w = getObjVar(this, "curWisp");
		stopFollowing(w);
		detachScript(this, "tutwisp");
		return(0x00);
		break;
	}
	return(0x01);
}

trigger speech("*") {
	list text;
	string word;
	split(text, arg);
	word = text[0x00];
	if (0x00) {
		if (word == "face") {
			systemMessage(this, "Dir:" + getFacing(this));
		}
		if (numInList(text) == 0x02) {
			systemMessage(this, "2 in list");
			word = text[0x00];
			if (word == "state") {
				word = text[0x01];
				int new_state = strtoi(word);
				state = new_state;
				set_hint_text();
				systemMessage(this, "New State: " + state);
				return(0x00);
			}
		}
	}
	for (int i = 0x00; i < numInList(text); i++) {
		word = text[i];
		if (word == "help") {
			set_hint_text();
			bark_via_wisp(hint_msg);
			return(0x00);
		}
	}
	return(0x01);
}

trigger message("leftme") {
	int arg = args[0x00];
	if (arg == 0x02) {
		if (state == 0x05) {
			state = 0x06;
			run_step();
		}
	}
	return(0x01);
}

trigger message("foundme") {
	switch(args[0x00]) {
	case 0x01
		if (state == 0x01) {
			state = 0x02;
			run_step();
		}
		break;
	case 0x02
		if (state <= 0x03) {
			state = 0x04;
			run_step();
		}
		break;
	case 0x03
		if (state == 0x06) {
			state = 0x07;
			run_step();
		}
		if (state == 0x0A) {
			state = 0x0B;
			run_step();
		}
		if (state == 0x0F) {
			state = 0x10;
			run_step();
		}
		break;
	case 0x04
		if (state == 0x08) {
			state = 0x09;
			callback(this, 0x03, 0x00010469);
			run_step();
		}
	case 0x05
		if (state == 0x0D) {
			state = 0x0E;
			callback(this, 0x03, 0x00010469);
			run_step();
		}
		break;
	case 0x06
		if (state == 0x11) {
			state = 0x12;
			run_step();
		}
		break;
	case 0x07
		if (state == 0x16) {
			state = 0x17;
			run_step();
		}
		if (state == 0x13) {
			state = 0x14;
			run_step();
		}
		break;
	}
	return(0x01);
}

trigger use {
	if (state == 0x14) {
		state = 0x15;
		run_step();
	}
	return(0x01);
}

trigger killedtarget {
	if (hasScript(attacker, "tutdragon")) {
		state = 0x19;
		run_step();
	}
	return(0x01);
}

trigger callback(0x000182AD) {
	int dist = getDistanceInTiles(getLocation(this), dragon_loc);
	if ((dist < 0x16) && (state == 0x13)) {
		if (hasScript(getItemAtSlot(this, EQUIP_RIGHT_HAND), "tutwisp")) {
			state = 0x16;
		} else {
			state = 0x14;
		}
		run_step();
		return(0x00);
	}
	if (0x00) {
		systemMessage(this, "Dist:" + dist + ":" + getLocation(this) + ":" + getLocation(dragon));
	}
	callback(this, 0x03, 0x000182AD);
	return(0x00);
}

trigger callback(0x00010469) {
	if (state == 0x09) {
		if ((hasObjType(this, 0x0FB4)) || (hasObjType(this, 0x0FB5)) || (hasObjType(this, 0x13E3)) || (hasObjType(this, 0x13E4))) {
			state = 0x0A;
			run_step();
			return(0x00);
		}
	}
	if (state == 0x0E) {
		if ((hasObjType(this, 0x0F5E)) || (hasObjType(this, 0x0F5F)) || (hasObjType(this, 0x0F60)) || (hasObjType(this, 0x0F61)) || (hasObjType(this, 0x13B7)) || (hasObjType(this, 0x13B8)) || (hasObjType(this, 0x13B9)) || (hasObjType(this, 0x13BA))) {
			state = 0x0F;
			run_step();
			return(0x00);
		}
	}
	callback(this, 0x03, 0x00010469);
	return(0x00);
}

trigger callback(0x0001046A) {
	bark_via_wisp(hint_msg);
	set_hint_text();
	callback(this, 0x2D, 0x0001046B);
	return(0x00);
}

trigger callback(0x0001046B) {
	hint_repeat_count++;
	if (hint_repeat_count > 0x02) {
		string msg = "Remember, you can ask me for 'help' if you need it.";
		bark_via_wisp(msg);
		return(0x00);
	}
	bark_via_wisp(hint_msg);
	callback(this, 0x3C * hint_repeat_count, 0x0001046B);
	return(0x00);
}

trigger callback(0x0001046C) {
	bark_via_wisp("Welcome to Ultima Online! I am thy guide wisp, and will help thee as thou dost explore the world of Britannia. Ask for 'help' if you need it!");
	run_step();
	return(0x00);
}

function void run_step() {
	string msg;
	hint_repeat_count = 0x00;
	switch(state) {
	case 0x01
		hint_msg = "Lets get out of the inn, shall we?  Walk to the door by moving your cursor so the arrow points at it, and then hold down the right mouse button.";
		callback(this, 0x1E, 0x0001046A);
		return();
		break;
	case 0x02
		hint_msg = "Now double click on the door to open it and then walk through.";
		break;
	case 0x03
		hint_msg = "Lets go find the town bulletin board and see whats going on.  Its " + getDirection(getLocation(this), board_loc) + " of here.  You might want to open your map to help navigate by pressing Alt-R.";
		break;
	case 0x04
		hint_msg = "Lets read the board and see whats going on in the area.  Double click the bulletin board to read the messages on it.";
		break;
	case 0x05
		hint_msg = "";
		break;
	case 0x06
		hint_msg = "That dragon sounds dangerous.  We should seek the aide of the sage in town to see if he can help us out, he is " + getDirection(getLocation(this), sage_loc) + ".";
		break;
	case 0x07
		hint_msg = "There's the sage, ask him about the dragon and see if he can help.";
		break;
	case 0x08
		hint_msg = "That sword is sure to help, lets find the blacksmith, they're " + getDirection(getLocation(this), blacksmith_loc) + ".";
		callback(this, 0x0A, 0x0001046A);
		return();
		break;
	case 0x09
		hint_msg = "There's the shopkeeper, say 'shopkeeper' near him to get his attention and you'll be shown his inventory to shop from.";
		break;
	case 0x0A
		hint_msg = "Okay, we have the hammer for the sage, lets head " + getDirection(getLocation(this), sage_loc) + ", back to the sage's home.";
		break;
	case 0x0B
		hint_msg = "You need to open your inventory to give the hammer to the sage, open it by pressing Alt-I.";
		break;
	case 0x0C
		hint_msg = "There's the hammer in your pack, while very close to the sage click on the hammer and drag it on top of the sage to give it to him, then right click on the inventory window to close it.";
		break;
	case 0x0D
		hint_msg = "Sheesh, a sword too eh?  Lets go back to the blacksmith's to buy one - " + getDirection(getLocation(this), blacksmith_loc) + ".";
		callback(this, 0x0A, 0x0001046A);
		return();
		break;
	case 0x0E
		hint_msg = "Shop now just like you did before.";
		break;
	case 0x0F
		hint_msg = "Okay, lets head back to the sage's home and hope this is all we need.";
		break;
	case 0x10
		hint_msg = "Drag your sword from your inventory to the sage to give it to him, if you have it wielded, drag it from your 'paper doll,' which you open by pressing Alt-P.";
		break;
	case 0x11
		hint_msg = "Well now that we finally have our enchanted sword, lets find the ranger to learn how to track the dragon down, he's most likely at the library, " + getDirection(getLocation(this), ranger_loc) + ".";
		callback(this, 0x0A, 0x0001046A);
		return();
		break;
	case 0x12
		hint_msg = "There is the ranger now, ask him to 'teach tracking', and see how much he wants to teach you how to track.";
		break;
	case 0x13
		hint_msg = "You're as ready as you're going to be to take on the dragon, lets head out into the woods!";
		callback(this, 0x0A, 0x0001046A);
		return();
		break;
	case 0x14
		hint_msg = "I have a feeling the dragon is near, you'd better wield your glass sword.  First open your 'paperdoll' by pressing Alt-P now.";
		break;
	case 0x15
		hint_msg = "Unwield anything you're wielding by dragging it from your paperdoll to your pack.  Now drag the sword from your inventory to the picture of you in the paperdoll and you will wield it!";
		break;
	case 0x16
		hint_msg = "Time to kill us a dragon.  Click on the skills button on your paperdoll, then the arrow next to 'actions'.  You should now see the tracking skill in the list if you scroll down with the red ribbon some, click on that, and then select 'creatures'.  A box will appear with the monsters nearby in it, click on the dragon in that box.  If there isn't a dragon, wander some more and try again.";
		break;
	case 0x17
		hint_msg = "There's the dragon!  Click on the button labeled 'peace' on your paperdoll.  This will change you to war mode.  Now walk VERY close to the dragon and double click on it to begin combat!";
		break;
	case 0x18
		hint_msg = "Combat has begun!  Slay the wicked beast!!";
		break;
	case 0x19
		hint_msg = "Congratulations!!  Take the items on the dragon's body and dragging them to your inventory.";
		break;
	}
	bark_via_wisp(hint_msg);
	set_hint_text();
	callback(this, 0x78, 0x0001046B);
	return();
}

function void set_hint_text() {
	if (0x00) {
		systemMessage(this, "STATE:" + state);
	}
	switch(state) {
	case 0x01
		hint_msg = "Walk by holding down the right mouse button in the world around you.";
		break;
	case 0x02
		hint_msg = "Open the door by double clicking on it while standing next to it.";
		break;
	case 0x03
		hint_msg = "The bulletin board is " + getDirection(getLocation(this), board_loc) + ".";
		break;
	case 0x04
		hint_msg = "Double click the board to read the messages on it.";
		break;
	case 0x05
		hint_msg = "";
		break;
	case 0x06
		hint_msg = "The sage that can help us lives " + getDirection(getLocation(this), sage_loc) + ".";
		break;
	case 0x07
		hint_msg = "Ask the sage about the 'dragon.'  Talk by typing in what you want so say and press enter.";
		break;
	case 0x08
		hint_msg = "The blacksmith's shoppe is " + getDirection(getLocation(this), blacksmith_loc) + ".";
		break;
	case 0x09
		hint_msg = "Get the shopkeep's attention by saying 'shopkeep', and follow the menus to purchase items.";
	case 0x0A
		hint_msg = "Lets head " + getDirection(getLocation(this), sage_loc) + ", back towards the sage's home.";
		break;
	case 0x0B
		hint_msg = "Press Alt-I to open your inventory window.";
		break;
	case 0x0C
		hint_msg = "Drag the hammer from your inventory window to the sage to give it to him.";
		break;
	case 0x0D
		hint_msg = "The blacksmith's is " + getDirection(getLocation(this), blacksmith_loc) + ".";
		break;
	case 0x0E
		hint_msg = "Get the shopkeep's attention by saying 'shopkeep.'";
		break;
	case 0x0F
		hint_msg = "Lets go back to the sage's home, " + getDirection(getLocation(this), sage_loc) + ".";
		break;
	case 0x10
		hint_msg = "Drag the sword from your inventory window to the sage to give it to him.";
		break;
	case 0x11
		hint_msg = "The ranger is " + getDirection(getLocation(this), ranger_loc) + ".";
		break;
	case 0x12
		hint_msg = "Ask the ranger to 'teach tracking.'";
		break;
	case 0x13
		hint_msg = "Be careful!";
		break;
	case 0x14
		hint_msg = "Press Alt-P to open your 'paperdoll' window.";
		break;
	case 0x15
		hint_msg = "Drag the sword from your inventory to your paperdoll to wield it.";
		break;
	case 0x16
		hint_msg = "Press the skills button on your paper doll, click on the arrow by actions.  Select 'tracking' and try tracking creatures by double clicking the two-headed ettin in the window that just opened, and then select the dragon in the window following that to track it.";
		break;
	case 0x17
		hint_msg = "Attack the dragon by clicking on the 'peace' button on your paperdoll window, and then double clicking the dragon when near it.";
		break;
	case 0x18
		hint_msg = "You can do it!  Fear not my brave friend!!";
		break;
	case 0x19
		hint_msg = "Double click the dragon's body to see whats on it, and then drag things you want to your inventory.";
		break;
	}
	return();
}

function void destroy_wisp() {
	if (!hasObjVar(this, "curWisp")) {
		return();
	}
	obj w = getObjVar(this, "curWisp");
	deleteObject(w);
	removeObjVar(this, "curWisp");
	return();
}

function void spawn_wisp() {
	loc spawn_loc = getLocation(this);
	obj w = createGlobalNPCAt(0x021F, spawn_loc, 0x03);
	makeInvulnerable(w);
	detachScript(w, "nonhuman");
	followNpc(w, this, 0x00);
	setObjVar(this, "curWisp", w);
	return();
}

function void bark_via_wisp(string msg) {
	if (!hasObjVar(this, "curWisp")) {
		spawn_wisp();
	}
	obj wisp = getObjVar(this, "curWisp");
	if (getDistanceInTiles(getLocation(this), getLocation(wisp)) > 0x08) {
		destroy_wisp();
		bark_via_wisp(msg);
		return();
	}
	ebarkTo(wisp, this, msg);
	return();
}

function void create_board_post() {
	obj post = createNoResObjectIn(0x0EB0, board);
	list postText;
	list lineTimes;
	string hero_word;
	if (getSex(this) == 0x01) {
		hero_word = "heroine";
	} else {
		hero_word = "hero";
	}
	appendToList(postText, "We need your help!");
	appendToList(postText, "A horrible dragon hath");
	appendToList(postText, "been terrorizing our");
	appendToList(postText, "forests of late, and a");
	appendToList(postText, "valiant " + hero_word + " is");
	appendToList(postText, "needed to rid us of the");
	appendToList(postText, "scourge!");
	appendToList(postText, "");
	appendToList(postText, "Prithee, if thou canst");
	appendToList(postText, "offer any aid, venture");
	appendToList(postText, "forth into the forest");
	appendToList(postText, "and slay this terrible");
	appendToList(postText, "beast! Our best warriors");
	appendToList(postText, "have tried and failed,");
	appendToList(postText, "for their swords merely");
	appendToList(postText, "bounced off the draconian");
	appendToList(postText, "hide... mayhap a special");
	appendToList(postText, "weapon is required, or");
	appendToList(postText, "merely a stouter arm!");
	appendToList(postText, "");
	appendToList(postText, "Abandon us not in times");
	appendToList(postText, "of need...");
	appendToList(postText, "");
	appendToList(postText, "-the citizens of Ocllo");
	setObjVar(post, "postText", postText);
	return();
}

trigger speech("*dismiss*") {
	bark_via_wisp("Very well, I will leave thee to thy exploration of Ocllo. I wish thee the best of luck!i Farewell!");
	obj w = getObjVar(this, "curWisp");
	stopFollowing(w);
	detachScript(this, "tutwisp");
	return(0x00);
}
