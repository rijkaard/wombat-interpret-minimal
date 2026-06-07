inherits guard;

forward void animate_ack();

forward void animate_refuse();

forward void animate_eat();

forward int isPet(obj );

forward int get_loyalty();

forward string get_boss_names();

forward int init_pet_sounds();

forward void play_ack_response(obj );

forward void play_refuse_response(obj );

forward void play_confused_response(obj );

forward void abandon_owner(obj );

forward int check_loyalty(obj , int );

forward int find_name_in_text(list , obj );

forward int parse_and_route_command(obj , obj , string );

forward int check_self_target(int , list );

forward int cmd_attack(obj , string , obj );

forward int handle_guard_command(obj , string , obj , int );

forward int cmd_friend(obj , string , obj );

forward int handle_patrol_command(obj , string , obj );

forward int handle_stay_command(obj , string , obj );

forward int handle_follow_command(obj , string , obj , int );

forward int cmd_fetch(obj , string , obj );

forward int handle_come_command(obj , string , obj );

forward int handle_drop_command(obj , string , obj );

forward int handle_report_command(obj , string , obj );

forward int handle_release_command(obj , string , obj );

forward int handle_stop_command(obj , string , obj );

forward int cmd_transfer(obj , string , obj );

forward string get_loyalty_description();

forward void add_boss(obj , obj );

forward void execute_attack_command(obj , obj , obj );

forward void execute_guard_command(obj , obj , obj );

forward void execute_follow_command(obj , obj , obj );

forward void execute_fetch_command(obj , obj , obj );

forward void execute_friend_command(obj , obj , obj );

forward void execute_transfer_command(obj , obj , obj );

forward int is_hire_speech(string , obj , obj );

forward void suppress_behaviors(obj );

forward int can_eat(obj , obj );

member int hour_tick_count;

function void animate_refuse() {
	if (getObjType(this) < 0xC8) {
		animateMobile(this, 0x11, 0x05, 0x01, 0x00, 0x00);
	} else {
		animateMobile(this, 0x09, 0x05, 0x01, 0x00, 0x00);
	}
	return();
}

function void animate_ack() {
	if (getObjType(this) < 0xC8) {
		animateMobile(this, 0x12, 0x05, 0x01, 0x00, 0x00);
	} else {
		animateMobile(this, 0x0A, 0x03, 0x01, 0x00, 0x00);
	}
	return();
}

function void animate_eat() {
	if (getObjType(this) < 0xC8) {
		animateMobile(this, 0x0B, 0x05, 0x01, 0x00, 0x00);
	} else {
		animateMobile(this, 0x03, 0x05, 0x01, 0x00, 0x00);
	}
	return();
}

function int isPet(obj this) {
	return((hasObjVar(this, "isPet")));
}

function int get_loyalty() {
	if (!hasObjVar(this, "myLoyalty")) {
		return(0x00);
	}
	int myLoyalty = getObjVar(this, "myLoyalty");
	if (myLoyalty > 0x64) {
		myLoyalty = 0x64;
		setObjVar(this, "myLoyalty", myLoyalty);
	}
	return(myLoyalty);
}

function string get_boss_names() {
	string names;
	list myBoss;
	int count;
	if (!hasObjListVar(this, "myBoss")) {
		return("myself");
	}
	getObjListVar(myBoss, this, "myBoss");
	count = numInList(myBoss);
	for (int i = 0x00; i < count; i++) {
		concat(names, getName(myBoss[i]));
		if (i < (count - 0x02)) {
			concat(names, ", ");
		} else {
			if (i == (count - 0x02)) {
				if (count == 0x02) {
					concat(names, " and ");
				} else {
					concat(names, " and ");
				}
			}
		}
	}
	return(names);
}

function int init_pet_sounds() {

member int petAckSfx = 0x00;

member int petRefuseSfx = 0x00;
	if (hasObjVar(this, "petAckSfx")) {
		petAckSfx = getObjVar(this, "petAckSfx");
	}
	if (hasObjVar(this, "petRefuseSfx")) {
		petRefuseSfx = getObjVar(this, "petRefuseSfx");
	}
	return((petAckSfx + petRefuseSfx));
}

function int isOwnedPet(obj it) {
	if (hasObjListVar(this, "myBoss")) {
		list boss_list;
		getObjListVar(boss_list, this, "myBoss");
		if (numInList(boss_list) > 0x00) {
			return(0x01);
		}
	}
	return(0x00);
}

trigger message("armageddon") {
	int flag = args[0x00];
	if (isOwnedPet(this)) {
		if (flag >= 0x01) {
			return(0x00);
		}
	}
	return(0x01);
}

trigger creation {
	string msg;
	if (0x00) {
		bark(this, "Debug mode activated on pet/hireling script.");
	}
	if (!init_pet_sounds()) {
		msg = "Failed to attach sounds to a pet/hireling named: " + getName(this);
		debugMessage(msg);
		return(0x01);
	}
	if (0x00) {
		if (!hasObjListVar(this, "myBoss")) {
			bark(this, "Failed to find myBoss list var");
		}
	}
	if (hasObjListVar(this, "myBoss")) {
		suppress_behaviors(this);
		list boss_list;
		getObjListVar(boss_list, this, "myBoss");
		obj blah = boss_list[0x00];
		if (!getCompileFlag(0x01)) {
			setNotoriety(this, getNotoriety(blah));
		}
		if (0x00) {
			msg = "Successfully found boss " + get_boss_names() + ".";
			bark(this, msg);
		}
	}
	return(0x01);
}

function void play_ack_response(obj pet) {
	if (isPet(pet)) {
		animate_ack();
		sfx(getLocation(pet), petAckSfx, 0x00);
	} else {
		bark(pet, "Very well.");
	}
	return;
}

function void play_refuse_response(obj pet) {
	if (isPet(pet)) {
		animate_refuse();
		sfx(getLocation(pet), petRefuseSfx, 0x00);
	} else {
		bark(pet, "Sorry, but no.");
	}
	return;
}

function void play_confused_response(obj pet) {
	if (isPet(pet)) {
		animate_refuse();
		sfx(getLocation(pet), petRefuseSfx, 0x00);
	} else {
		bark(pet, "I do not understand.");
	}
	return;
}

function void abandon_owner(obj this) {
	string msg;
	obj container = getTopmostContainer(this);
	if (container != NULL()) {
		int ok = teleport(this, getLocation(container));
		obj mount_item = getItemAtSlot(container, EQUIP_MOUNT);
		if (mount_item != NULL()) {
			deleteObject(mount_item);
		}
	}
	setObjVar(this, "defensive", 0x01);
	setObjVar(this, "controllerTimeout", 0x02 * 0x3C * 0x04);
	callbackAdvanced(this, 0x02 * 0x3C * 0x04, TIMER_EVENT_CTRL_TIMEOUT, 0x00);
	if (!isPet(this)) {
		bark(this, "I quit.");
	} else {
		play_refuse_response(this);
		msg = getName(this) + " appears to have decided that it is better off without a master!";
		toUpper(msg, 0x00, 0x01);
		bark(this, msg);
	}
	if (hasObjListVar(this, "myBoss")) {
		removeObjVar(this, "myBoss");
	}
	if (hasObjVar(this, "myLoyalty")) {
		removeObjVar(this, "myLoyalty");
	}
	if (hasObjVar(this, "petWhoFollow")) {
		removeObjVar(this, "petWhoFollow");
	}
	stopFollowing(this);
	clear_all_guard_protections(this);
	enableBehaviors(this);
	if (!getCompileFlag(0x01)) {
		setNotoriety(this, 0x00);
	}
	if (isPet(this)) {
		detachScript(this, "pet");
	}
	return;
}

trigger lookedat {
	if (isPet(this)) {
		barkTo(this, looker, "(tame)");
	}
	return(0x01);
}

function int check_loyalty(obj this, int difficulty) {
	int myLoyalty;
	string debug;
	myLoyalty = get_loyalty();
	if (0x00) {
		debug = myLoyalty;
		bark(this, debug);
	}
	if ((random(0x00, 0x64) + difficulty) > myLoyalty) {
		play_refuse_response(this);
		if (myLoyalty < 0x00) {
			abandon_owner(this);
		}
		return(0x00);
	}
	myLoyalty = myLoyalty + 0x01;
	setObjVar(this, "myLoyalty", myLoyalty);
	play_ack_response(this);
	return(0x01);
}

trigger speech("*") {
	if (!is_boss_of(this, speaker)) {
		return(0x01);
	}
	faceHere(this, getDirectionInternal(getLocation(this), getLocation(speaker)));
	if (isPet(this)) {
		animate_refuse();
	}
	if (parse_and_route_command(this, speaker, arg)) {
		return(0x00);
	}
	return(0x01);
}

function int find_name_in_text(list text, obj this) {
	string word;
	for (int i = 0x00; i < numInList(text); i++) {
		word = text[i];
		if (word == getName(this)) {
			return(i + 0x01);
		}
	}
	return(0xFF);
}

function int check_self_target(int cmd_idx, list text) {
	int next_idx;
	string next_word;
	int is_self;
	is_self = 0x00;
	next_idx = cmd_idx + 0x01;
	if (next_idx < numInList(text)) {
		next_word = text[next_idx];
		if (next_word == "me") {
			is_self = 0x01;
		}
	}
	return(is_self);
}

function int parse_and_route_command(obj this, obj speaker, string arg) {
	list text;
	int unused = 0x00;
	int name_idx = 0x00;
	int unused2;
	int is_me;
	string cmd;
	if (0x00) {
		bark(this, "Parsing a command.");
	}
	split(text, arg);
	name_idx = find_name_in_text(text, this);
	if (name_idx == 0xFF) {
		if (0x00) {
			bark(this, "Name not found.");
		}
		return(0x00);
	}
	if (name_idx >= numInList(text)) {
		if (0x00) {
			bark(this, "Name only thing found.");
		}
		return(0x00);
	}
	if (get_loyalty() < 0x01) {
		return(0x00);
	}
	if (!getCompileFlag(0x01)) {
		setNotoriety(this, getNotoriety(speaker));
	}
	cmd = text[name_idx];
	is_me = check_self_target(name_idx, text);
	if (handle_guard_command(this, cmd, speaker, is_me)) {
		return(0x01);
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	if (0x00) {
		bark(this, "Passed the dead check.");
	}
	if (cmd_attack(this, cmd, speaker)) {
		return(0x01);
	}
	if (cmd_friend(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_patrol_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_stay_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_follow_command(this, cmd, speaker, is_me)) {
		return(0x01);
	}
	if (cmd_fetch(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_come_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_drop_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_report_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_release_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (handle_stop_command(this, cmd, speaker)) {
		return(0x01);
	}
	if (cmd_transfer(this, cmd, speaker)) {
		return(0x01);
	}
	play_confused_response(this);
	return(0x00);
}

function int cmd_attack(obj this, string cmd, obj speaker) {
	if ((cmd != "attack") && (cmd != "kill")) {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to attack.");
	}
	setObjVar(this, "petAttack", 0x01);
	if (!isPet(this)) {
		bark(this, "Who should I attack?");
	} else {
		systemMessage(speaker, "Select the victim.");
	}
	targetObj(speaker, this);
	return(0x01);
}

function int handle_guard_command(obj this, string cmd, obj speaker, int is_me) {
	if (cmd != "guard") {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to guard.");
	}
	if (is_me) {
		if (get_loyalty() > 0x00) {
			copyControllerInfo(this, speaker);
			add_to_guard_list(speaker, this);
			play_ack_response(this);
			return(0x01);
		}
	}
	setObjVar(this, "petGuard", 0x01);
	if (!isPet(this)) {
		bark(this, "Tell me what to guard.");
	} else {
		systemMessage(speaker, "Click on the object, person, or place to guard.");
	}
	targetLoc(speaker, this);
	return(0x01);
}

function int cmd_friend(obj this, string cmd, obj speaker) {
	if (cmd != "friend") {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to befriend.");
	}
	setObjVar(this, "petFriend", 0x01);
	if (!isPet(this)) {
		bark(this, "I shall obey this person's orders as if they were your own.");
	} else {
		systemMessage(speaker, "Click on the player whom you wish to make a co-owner.");
	}
	targetObj(speaker, this);
	return(0x01);
}

function int handle_patrol_command(obj this, string cmd, obj speaker) {
	int is_patrolling = 0x00;
	if (cmd != "patrol") {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to patrol.");
	}
	if (hasObjVar(this, "continuePatrol")) {
		is_patrolling = getObjVar(this, "continuePatrol");
	}
	if (!is_patrolling) {
		setObjVar(this, "continuePatrol", 0x01);
		if (!isPet(this)) {
			bark(this, "Patrolling.");
		} else {
			play_ack_response(this);
			barkTo(this, speaker, "Your pet begins to patrol.");
		}
		do_patrol_step(this);
	} else {
		setObjVar(this, "continuePatrol", 0x00);
		if (!isPet(this)) {
			bark(this, "Stopping patrol.");
		} else {
			play_ack_response(this);
			barkTo(this, speaker, "Your pet stops patrolling.");
		}
	}
	return(0x01);
}

function int handle_stay_command(obj this, string cmd, obj speaker) {
	if (cmd != "stay") {
		return(0x00);
	}
	if (!check_loyalty(this, 0x00)) {
		return(0x01);
	}
	removeObjVar(this, "petWhoFollow");
	stopFollowing(this);
	suppress_behaviors(this);
	return(0x01);
}

function int handle_follow_command(obj this, string cmd, obj speaker, int is_me) {
	if (cmd != "follow") {
		return(0x00);
	}
	if (is_me) {
		if (is_boss_of(this, speaker)) {
			if (get_loyalty() > 0x00) {
				play_ack_response(this);
			}
			setObjVar(this, "petWhoFollow", speaker);
			followNpc(this, speaker, 0x00);
		}
		return(0x01);
	}
	setObjVar(this, "petFollow", 0x01);
	if (!isPet(this)) {
		bark(this, "Who shall I follow?");
	} else {
		systemMessage(speaker, "Click on the person to follow.");
	}
	targetObj(speaker, this);
	return(0x01);
}

function int cmd_fetch(obj this, string cmd, obj speaker) {
	if ((cmd != "fetch") && (cmd != "get") && (cmd != "bring")) {
		return(0x00);
	}
	if (getWeight(this) > 0x64) {
		if (!isPet(this)) {
			bark(this, "I am already carrying too much.");
		} else {
			systemMessage(speaker, "Your pet couldn't possibly carry any more.");
		}
		return(0x00);
	}
	setObjVar(this, "petFetch", 0x01);
	if (!isPet(this)) {
		bark(this, "What shall I get for you?");
	} else {
		systemMessage(speaker, "Click on the object to fetch.");
	}
	targetObj(speaker, this);
	return(0x01);
}

function int handle_come_command(obj this, string cmd, obj speaker) {
	if (cmd != "come") {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to come.");
	}
	if ((is_boss_of(this, speaker)) && (check_loyalty(this, 0x00))) {
		walkTo(this, getLocation(speaker), 0x0A);
	}
	return(0x01);
}

function int handle_drop_command(obj this, string cmd, obj speaker) {
	if (cmd != "drop") {
		return(0x00);
	}
	if (0x00) {
		bark(this, "Got order to drop.");
	}
	list contents;
	obj item;
	getContents(contents, this);
	play_ack_response(this);
	for (int i = 0x00; i < numInList(contents); i++) {
		item = contents[i];
		int result = teleport(item, getLocation(this));
	}
	return(0x01);
}

function int handle_report_command(obj this, string cmd, obj speaker) {
	if (cmd != "report") {
		return(0x00);
	}
	if (isPet(this)) {
		return(0x00);
	}
	callBack(this, 0x01, 0x1A);
	bark(this, "I currently accept orders from " + get_boss_names() + ".");
	bark(this, "I am " + get_loyalty_description() + " about my job.");
	if (hasObjVar(this, "petWhoFollow")) {
		obj follow_target = getObjVar(this, "petWhoFollow");
		bark(this, "I am following " + getName(follow_target) + ".");
	}
	return(0x01);
}

function int handle_release_command(obj this, string cmd, obj speaker) {
	if (cmd != "release") {
		return(0x00);
	}
	if (isPet(this)) {
		play_ack_response(this);
	} else {
		bark(this, "I thank thee for thy kindness!");
	}
	shortcallback(this, 0x08, 0x08);
	if (isPet(this)) {
		setObjVar(this, "petCanTame", 0x00);
	}
	abandon_owner(this);
	return(0x01);
}

function int handle_stop_command(obj this, string cmd, obj speaker) {
	if (cmd != "stop") {
		return(0x00);
	}
	if (isPet(this)) {
		play_ack_response(this);
	} else {
		bark(this, "Very well, I am no longer guarding or following.");
	}
	clear_all_guard_protections(this);
	stopFollowing(this);
	return(0x01);
}

function int cmd_transfer(obj this, string cmd, obj speaker) {
	if (cmd != "transfer") {
		return(0x00);
	}
	setObjVar(this, "petTransfer", 0x01);
	if (!isPet(this)) {
		bark(this, "Whom do you wish me to work for?");
	} else {
		systemMessage(speaker, "Click on the person to transfer ownership to.");
	}
	targetObj(speaker, this);
	return(0x01);
}

function string get_loyalty_description() {
	string mood_str;
	int loyalty_tier = get_loyalty() / 0x0A;
	switch(loyalty_tier) {
	default
		mood_str = "confused";
		break;
	case 0x01
		mood_str = "extremely unhappy";
		break;
	case 0x02
		mood_str = "rather unhappy";
		break;
	case 0x03
		mood_str = "unhappy";
		break;
	case 0x04
		mood_str = "content, I suppose,";
		break;
	case 0x05
		mood_str = "content";
		break;
	case 0x06
		mood_str = "happy";
		break;
	case 0x07
		mood_str = "rather happy";
		break;
	case 0x08
		mood_str = "very happy";
		break;
	case 0x09
		mood_str = "extremely happy";
		break;
	case 0x0A
		mood_str = "wonderfully happy";
		break;
	}
	return(mood_str);
}

trigger callback(0x43) {
	if (!hasObjVar(this, "askedMyLoyalty")) {
		return(0x01);
	}
	obj asker = getObjVar(this, "askedMyLoyalty");
	removeObjVar(this, "askedMyLoyalty");
	barkTo(asker, asker, "Your pet looks " + get_loyalty_description() + ".");
	return(0x01);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	if (hasObjVar(this, "petGuard")) {
		if (check_loyalty(this, 0x00)) {
			guard_location(place, this);
		}
		removeObjVar(this, "petGuard");
		return(0x00);
	}
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		removeObjVar(this, "petAttack");
		removeObjVar(this, "petGuard");
		removeObjVar(this, "petFollow");
		removeObjVar(this, "petFetch");
		removeObjVar(this, "petFriend");
		removeObjVar(this, "petTransfer");
		return(0x00);
	}
	if (hasObjVar(this, "petAttack")) {
		execute_attack_command(this, usedon, user);
		return(0x00);
	}
	if (hasObjVar(this, "petGuard")) {
		execute_guard_command(this, usedon, user);
		return(0x00);
	}
	if (hasObjVar(this, "petFollow")) {
		execute_follow_command(this, usedon, user);
		return(0x00);
	}
	if (hasObjVar(this, "petFetch")) {
		execute_fetch_command(this, usedon, user);
		return(0x00);
	}
	if (hasObjVar(this, "petFriend")) {
		execute_friend_command(this, usedon, user);
		return(0x00);
	}
	if (hasObjVar(this, "petTransfer")) {
		execute_transfer_command(this, usedon, user);
		return(0x00);
	}
	return(0x01);
}

function void add_boss(obj pet, obj new_boss) {
	list myBoss;
	if (!hasObjListVar(pet, "myBoss")) {
		setObjVar(pet, "myBoss", myBoss);
	}
	getObjListVar(myBoss, pet, "myBoss");
	if (!isInList(myBoss, new_boss)) {
		appendToList(myBoss, new_boss);
	}
	setObjVar(pet, "myBoss", myBoss);
	return();
}

function void execute_friend_command(obj this, obj usedon, obj user) {
	debugMessage("I are here");
	if (check_loyalty(this, 0x00)) {
		string msg;
		if (hasObjVar(this, "isPet")) {
			msg = "I shall obey the orders given me by " + getName(usedon) + " and treat " + getHimHer(usedon) + " as a friend.";
			bark(this, msg);
		} else {
			msg = getName(this) + " will not guard against " + getName(usedon) + " and will obey " + getHisHer(usedon) + " orders as if they were your own.";
			systemMessage(user, msg);
			if (isPlayer(usedon)) {
				msg = getName(user) + " has granted you the ability to give orders to " + getHisHer(user) + " pet " + getName(this) + ". This creature will now consider you a friend.";
				systemMessage(usedon, msg);
			}
		}
		debugMessage("I are here2");
		receiveHelpfulActionFrom(usedon, user);
		add_boss(this, usedon);
	}
	return();
}

function void execute_fetch_command(obj this, obj usedon, obj user) {
	if (check_loyalty(this, 0x00)) {
		loc place = getLocation(usedon);
		walkTo(this, place, 0x0B);

member obj fetch_target = usedon;

member obj fetch_recipient = user;
	}
	removeObjVar(this, "petFetch");
	return();
}

function void execute_follow_command(obj this, obj usedon, obj user) {
	if (is_boss_of(this, usedon)) {
		play_ack_response(this);
	} else {
		if (!check_loyalty(this, 0x00)) {
			return();
		}
	}
	if (usedon == this) {
		removeObjVar(this, "petWhoFollow");
		stopFollowing(this);
	} else {
		setObjVar(this, "petWhoFollow", usedon);
		followNpc(this, usedon, 0x00);
	}
	removeObjVar(this, "petFollow");
	return();
}

function void execute_guard_command(obj this, obj usedon, obj user) {
	if (is_boss_of(this, usedon)) {
		copyControllerInfo(this, user);
		add_to_guard_list(usedon, this);
	} else {
		if (check_loyalty(this, 0x00)) {
			obj target_multi = isAnyMultiBelow(getLocation(usedon));
			if (!mobile_owns_house(target_multi, user)) {
				bark(this, "Items in other people's houses or ships cannot be guarded.");
				play_refuse_response(this);
				return();
			}
			if (isInContainer(usedon)) {
				bark(this, "Items in containers cannot be guarded.");
				play_refuse_response(this);
				return();
			}
			if (thinksItsAtHome(usedon)) {
				bark(this, "Other people's items cannot be guarded.");
				play_refuse_response(this);
				return();
			}
			if (isMobile(usedon)) {
				if (!isPlayer(usedon)) {
					if (!is_boss_of(usedon, user)) {
						bark(this, "Living things other than pets cannot be guarded.");
						play_refuse_response(this);
						return();
					}
				}
			}
			copyControllerInfo(this, user);
			add_to_guard_list(usedon, this);
		}
	}
	if (0x00) {
		bark(this, "done any guarding I'd do, returning.");
	}
	removeObjVar(this, "petGuard");
	return();
}

function void execute_attack_command(obj this, obj usedon, obj user) {
	int difficulty;
	difficulty = getStrength(usedon) + getDexterity(usedon) + getSkillLevel(usedon, SKILL_PARRYING) + getSkillLevel(usedon, SKILL_TACTICS);
	difficulty = difficulty - (getStrength(this) + getDexterity(this) + getSkillLevel(this, SKILL_PARRYING) + getSkillLevel(this, SKILL_TACTICS));
	difficulty = difficulty / 0x0A;
	if ((isHuman(usedon)) && (isNPC(usedon)) && (isHuman(this))) {
		bark(this, "I am no murderer!");
		return();
	}
	if (check_loyalty(this, difficulty)) {
		if (0x00) {
			bark(this, "Attacking!");
		}
		copyControllerInfo(this, user);
		clear_all_guard_protections(this);
		setObjVar(this, "controllerTimeout", 0x02 * 0x3C * 0x04);
		callbackAdvanced(this, 0x02 * 0x3C * 0x04, TIMER_EVENT_CTRL_TIMEOUT, 0x00);
		setObjVar(this, "victim", usedon);
		setObjVar(this, "user", user);
		walkTo(this, getLocation(usedon), 0x10);
		attack(this, usedon);
		if (!getCompileFlag(0x01)) {
			criminalAct(user, usedon, 0x01, 0x0A);
			callGuards(user, getLocation(user), 0x02);
		}
	}
	removeObjVar(this, "petAttack");
	return();
}

function void execute_transfer_command(obj this, obj usedon, obj user) {
	if (!isPlayer(usedon)) {
		if (isPet(this)) {
			play_refuse_response(this);
		} else {
			bark(this, "Uhh... Sure. If you say so. Uh-huh. No problem. Soon as it gives an order, I'll obey...");
		}
		removeObjVar(this, "petTransfer");
		return();
	}
	removeObjVar(this, "myBoss");
	add_boss(this, usedon);
	receiveHelpfulActionFrom(usedon, user);
	removeObjVar(this, "petTransfer");
	if (isPet(this)) {
		play_ack_response(this);
	} else {
		bark(this, "Very well, I transfer my allegiance.");
	}
	if (hasObjVar(this, "petWhoFollow")) {
		removeObjVar(this, "petWhoFollow");
	}
	stopFollowing(this);
	clear_all_guard_protections(this);
	return();
}

trigger pathnotfound(0x0A) {
	if (isPet(this)) {
		play_confused_response(this);
		return(0x00);
	}
	bark(this, "I see no way to reach thee!");
	return(0x00);
}

trigger pathfound(0x0B) {
	if (!isMoveable(fetch_target, this)) {
		play_refuse_response(this);
		return(0x00);
	}
	if (containedBy(fetch_target) != NULL()) {
		play_refuse_response(this);
		return(0x00);
	}
	if (isAtHome(fetch_target)) {
		play_refuse_response(this);
		return(0x00);
	}
	if (getWeight(fetch_target) > (getStrength(this) / 0x02)) {
		play_refuse_response(this);
		return(0x00);
	}
	if (!putObjContainer(fetch_target, this)) {
		play_refuse_response(this);
		return(0x00);
	}
	loc place = getLocation(fetch_recipient);
	walkTo(this, place, 0x0C);
	return(0x00);
}

trigger pathfound(0x0C) {
	if (!canHold(fetch_recipient, fetch_target)) {
		if (!isPet(this)) {
			bark(this, "I can't give you " + getName(fetch_target));
		} else {
			play_refuse_response(this);
		}
		return(0x00);
	}
	if (giveItem(fetch_recipient, fetch_target) == NULL()) {
		if (!isPet(this)) {
			bark(this, "I can't give you " + getName(fetch_target));
		} else {
			play_refuse_response(this);
		}
	}
	play_ack_response(this);
	return(0x00);
}

trigger pathnotfound(0x0C) {
	if (isPet(this)) {
		play_confused_response(this);
		return(0x00);
	}
	bark(this, "I see no way to reach you!");
	return(0x00);
}

trigger pathnotfound(0x10) {
	obj victim = getObjVar(this, "victim");
	obj user = getObjVar(this, "user");
	removeObjVar(this, "victim");
	removeObjVar(this, "user");
	attack(this, victim);
	return(0x00);
}

trigger pathfound(0x10) {
	obj victim = getObjVar(this, "victim");
	obj user = getObjVar(this, "user");
	removeObjVar(this, "victim");
	removeObjVar(this, "user");
	attack(this, victim);
	return(0x00);
}

function int is_hire_speech(string arg, obj speaker, obj this) {
	list text;
	split(text, arg);
	int found = 0x00;
	int pos = 0x00;
	string word;
	list hire_words = "hire", "hireling", "hiring", "mercenary", "servant", "work";
	for (int i = 0x00; i < numInList(text); i++) {
		word = text[i];
		if (isInList(hire_words, word)) {
			return(0x01);
		}
	}
	return(0x00);
}

trigger speech("*") {
	if (hasObjListVar(this, "myBoss") && (get_loyalty() > 0x00)) {
		return(0x01);
	}
	if (!isHuman(this)) {
		return(0x01);
	}
	if (!is_hire_speech(arg, speaker, this)) {
		return(0x01);
	}
	string hire_msg = "I am available for hire for ";
	int wages = getObjVar(this, "hirelingWages");
	wages = wages * 0x0A;
	string wages_str = wages;
	concat(hire_msg, wages_str);
	concat(hire_msg, " gold coins a day. If thou dost give me gold, I will work for thee.");
	bark(this, hire_msg);
	add_boss(this, speaker);
	setObjVar(this, "myLoyalty", 0x00);
	return(0x00);
}

function void suppress_behaviors(obj pet) {
	disableBehaviors(pet);
	clearBehavior(pet, 0x02);
	clearBehavior(pet, 0x40);
	return();
}

function int can_eat(obj this, obj givenobj) {
	int i;
	int j;
	string my_res;
	string given_res;
	list my_resources;
	list given_resources;
	if (!getResourcesOnObj(givenobj, 0x03, given_resources)) {
		return(0x00);
	}
	if (!getResourcesOnObj(this, 0x00, my_resources)) {
		return(0x00);
	}
	for (i = 0x00; i < numInList(my_resources); i++) {
		for (j = 0x00; j < numInList(given_resources); j++) {
			my_res = my_resources[i];
			given_res = given_resources[j];
			if (my_res == given_res) {
				return(0x01);
			}
		}
	}
	return(0x00);
}

trigger give {
	int ok;
	int gold;
	int daily_cost;
	int myLoyalty;
	string days_str;
	string msg;
	string plural = "s";
	if (!is_boss_of(this, giver)) {
		return(0x01);
	}
	if (isPet(this)) {
		if (!can_eat(this, givenobj)) {
			return(0x01);
		}
		setObjVar(this, "myLoyalty", 0x64);
		int ate = eatObject(this, givenobj);
		animate_eat();
		deleteObject(givenobj);
		barkTo(this, giver, "Your pet looks happier.");
		suppress_behaviors(this);
		return(0x00);
	}
	if (getObjType(givenobj) != 0x0EED) {
		return(0x01);
	}
	ok = getResource(gold, givenobj, "gold", 0x03, 0x02);
	if (!ok) {
		bark(this, "This is counterfeit gold!");
		return(0x00);
	}
	if (hasObjVar(this, "hirelingWages")) {
		daily_cost = getObjVar(this, "hirelingWages");
		daily_cost = daily_cost * 0x0A;
		gold = gold / daily_cost;
	}
	if (gold < 0x01) {
		bark(this, "Thou must pay me more than this!");
		return(0x00);
	}
	int loyalty = get_loyalty();
	if (loyalty < 0x4B) {
		loyalty = 0x4B + gold;
	} else {
		loyalty = loyalty + gold;
	}
	myLoyalty = loyalty;
	setObjVar(this, "myLoyalty", myLoyalty);
	myLoyalty = myLoyalty - 0x4B;
	days_str = myLoyalty;
	if (myLoyalty < 0x02) {
		plural = "";
	}
	msg = "I thank thee for paying me. I will work for thee for the next " + days_str + " day" + plural + ".";
	bark(this, msg);
	suppress_behaviors(this);
	deleteObject(givenobj);
	return(0x00);
}

trigger time("hour:**") {
	string complaint_msg;
	if (hour_tick_count < 0x03) {
		hour_tick_count++;
		return(0x01);
	}
	hour_tick_count = 0x00;
	if (hasObjVar(this, "isInStables")) {
		return(0x01);
	}
	if (get_loyalty() > 0x0A) {
		return(0x01);
	}
	if (!isPet(this)) {
		list complaint_phrases = "I am considering quitting.", "This job doth not pay enough.", "'Tis time to be thinking about a new master.", "Should I not be paid soon?", "I think more gold is required to keep me around much longer.", "If my master wisheth me near, payment would be needed!", "Soon I shall be free of this employment.", "My loyalty hath eroded, for lack of pay.", "My term of service is ending, unless I be paid more.", "'Tis crass of me, but I want gold.", "Methinks I shall quit my job soon.";
		complaint_msg = complaint_phrases[random(0x00, (numInList(complaint_phrases) - 0x01))];
		bark(this, complaint_msg);
		return(0x01);
	}
	list nearby_players;
	getPlayersInRange(nearby_players, getLocation(this), 0x10);
	for (int i = 0x00; i < numInList(nearby_players); i++) {
		obj player = nearby_players[i];
		if (is_boss_of(this, player)) {
			barkTo(this, player, "Your pet looks rather unhappy.");
			play_refuse_response(this);
		}
	}
	return(0x01);
}

trigger time("hour:12") {
	int myLoyalty;
	if (!hasObjListVar(this, "myBoss")) {
		return(0x01);
	}
	if (hasObjVar(this, "isInStables")) {
		return(0x01);
	}
	myLoyalty = get_loyalty();
	myLoyalty = myLoyalty - 0x01;
	if (myLoyalty == 0x00) {
		abandon_owner(this);
		return(0x01);
	}
	setObjVar(this, "myLoyalty", myLoyalty);
	return(0x01);
}

trigger seekfood {
	if (hasObjListVar(this, "myBoss") && (get_loyalty() < 0x01)) {
		return(0x00);
	}
	return(0x01);
}

trigger seekdesire {
	if (hasObjListVar(this, "myBoss") && (get_loyalty() < 0x01)) {
		return(0x00);
	}
	return(0x01);
}

trigger seekshelter {
	if (hasObjListVar(this, "myBoss") && (get_loyalty() < 0x01)) {
		return(0x00);
	}
	return(0x01);
}

trigger death {
	list equipment;
	obj obj_reveal;
	getEquipment(equipment, this);
	for (int i = 0x00; i < numInList(equipment); i++) {
		obj_reveal = equipment[i];
		deleteObject(obj_reveal);
	}
	return(0x01);
}
