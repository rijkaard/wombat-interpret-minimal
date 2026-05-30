forward void check_inventory();

inherits globals;

function void check_inventory() {
	list args;
	message(getBackpack(this), "checkStatus", args);
	return();
}

function obj get_owner() {
	return(getObjVar(this, "owner"));
}

function void update_murder_count(obj owner) {
	if (isMurderer(owner)) {
		int ownerMurderCount = 0x00;
		if (hasObjVar(this, "ownerMurderCount")) {
			ownerMurderCount = getObjVar(this, "ownerMurderCount");
		}
		int murderCount = getMurderCount(owner);
		if (murderCount > ownerMurderCount) {
			setObjVar(this, "ownerMurderCount", murderCount);
		}
	}
	return();
}

trigger message("armageddon") {
	int depth = args[0x00];
	if (depth >= 0x01) {
		return(0x00);
	}
	return(0x01);
}

trigger creation {
	callback(this, 0x7080, 0x90);
	makeInvulnerable(this);
	if (!hasObjVar(this, "myAccount")) {
		setObjVar(this, "myAccount", 0x03E8);
	}
	if (!hasObjVar(this, "goldOwnerList")) {
		list empty_list;
		setObjVar(this, "goldOwnerList", empty_list);
		setObjVar(this, "goldQuantityList", empty_list);
	}
	if (!hasObjVar(this, "myAccount")) {
		setObjVar(this, "myAccount", 0x03E8);
	}
	if (!hasObjVar(this, "myAccount")) {
		setObjVar(this, "myAccount", 0x03E8);
	}
	attachScript(getBackpack(this), "vended");
	if (hasObjVar(this, "owner")) {
		bark(this, "Greetings " + getName(get_owner()) + ", I am " + getName(this) + " and will be working for you.");
		update_murder_count(get_owner());
	}
	check_inventory();
	return(0x00);
}

trigger use {
	if (isDead(user)) {
		return(0x00);
	}
	if (!hasObjVar(this, "owner")) {
		setObjVar(this, "owner", user);
		bark(this, "I am now working for " + getName(user) + ".");
		update_murder_count(user);
	}
	barkTo(this, user, "Take a look at my goods.");
	int result = openContainer(user, getBackpack(this));
	return(0x00);
}

trigger give {
	if (giver != get_owner()) {
		barkTo(this, giver, "I can only accept items from the shop owner.");
		return(0x00);
	}
	update_murder_count(giver);
	if (getObjType(givenobj) == 0x0EED) {
		int quantity = getQuantity(givenobj);
		deleteObject(givenobj);
		int myAccount = quantity + getObjVar(this, "myAccount");
		setObjVar(this, "myAccount", myAccount);
		barkTo(this, giver, "I'll take that to fund my services.");
		return(0x01);
	}
	if (!canHold(this, givenobj)) {
		barkTo(this, giver, "I can't carry anymore.");
		return(0x00);
	}
	setObjVar(givenobj, "vendedOwner", giver);
	attachScript(givenobj, "vended");
	int ok = putObjContainer(givenobj, getBackpack(this));
	return(0x01);
}

function void prompt_buy_item(obj speaker) {
	if (speaker == get_owner()) {
		update_murder_count(speaker);
		barkTo(this, speaker, "You own this shop, just take what you want.");
		return();
	}
	systemMessage(speaker, "Select the item you wish to buy. ");
	targetobj(speaker, this);
	return();
}

function obj withdraw_gold(obj user, obj owner, int limit) {
	list goldOwnerList;
	list goldQuantityList;
	getObjListVar(goldOwnerList, this, "goldOwnerList");
	getObjListVar(goldQuantityList, this, "goldQuantityList");
	obj result = NULL();
	for (int i = 0x00; 0x01; i++) {
		if (i >= numInList(goldOwnerList)) {
			return(result);
		}
		obj list_owner = goldOwnerList[i];
		if (owner == list_owner) {
			int amount = goldQuantityList[i];
			if (amount > limit) {
				setItem(goldQuantityList, amount - limit, i);
				amount = limit;
			} else {
				removeItem(goldOwnerList, i);
				removeItem(goldQuantityList, i);
			}
			obj gold = containsObjType(this, 0x0EED);
			if (gold != NULL()) {
				int available = getQuantity(gold);
				if (amount > available) {
					debugMessage("Tried to transfer " + amount + " gold from vendor with only " + available + " gold.");
					amount = available;
					clearList(goldOwnerList);
					clearList(goldQuantityList);
				}
				result = createNoResObjectIn(0x0EED, getBackpack(user));
				transferGeneric(result, gold, amount);
				break;
			}
		}
	}
	setObjVar(this, "goldOwnerList", goldOwnerList);
	setObjVar(this, "goldQuantityList", goldQuantityList);
	return(result);
}

function void collect_gold(obj user) {
	int max_carry_amount = (getCanCarry(user) - getWeight(user)) * 0x32;
	if (max_carry_amount <= 0x00) {
		barkTo(this, user, "You are overloaded already.");
		return();
	}
	obj gold = withdraw_gold(user, user, max_carry_amount);
	if (gold == NULL()) {
		barkTo(this, user, "I am holding no gold for you.");
		return();
	}
	int quantity = getQuantity(gold);
	if (quantity >= max_carry_amount) {
		barkTo(this, user, "Here is " + quantity + " gold, all you can carry.");
	} else {
		barkTo(this, user, "Here is " + quantity + " gold, all I've collected.");
	}
	return();
}

trigger oortargetobj {
	if (isDead(user)) {
		return(0x01);
	}
	list args;
	if (usedon == NULL()) {
		return(0x00);
	}
	obj top_container = getTopmostContainer(usedon);
	if (top_container == NULL()) {
		barkTo(this, user, "You can't buy that.");
		return(0x00);
	}
	if (top_container != this) {
		barkTo(this, user, "You can't buy that.");
		return(0x00);
	}
	if (usedon == getBackpack(this)) {
		barkTo(this, user, "You can't buy that.");
		return(0x00);
	}
	if (!hasScript(usedon, "vended")) {
		barkTo(this, user, "This item is not for sale individually.");
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		barkTo(this, user, "You can't buy that.");
		return(0x00);
	}
	args = user;
	bark(this, getName(user));
	message(usedon, "purchase", args);
	return(0x00);
}

trigger objaccess(0x05) {
	if (isEditing(user)) {
		return(0x00);
	}
	if (user == get_owner()) {
		update_murder_count(user);
		return(0x00);
	}
	barkTo(this, user, "If you'd like to purchase an item, just say so.");
	return(0x01);
}

trigger objaccess(0x07) {
	if (isEditing(user)) {
		return(0x00);
	}
	if (user == get_owner()) {
		update_murder_count(user);
		return(0x00);
	}
	barkTo(this, user, "I can only accept items from the shop owner.");
	return(0x01);
}

trigger objaccess(0x08) {
	if (isDead(user)) {
		return(0x01);
	}
	if (this == usedon) {
		return(0x01);
	}
	if (isRealContainer(usedon)) {
		int result = openContainer(user, usedon);
	}
	return(0x00);
}

function int get_item_value(obj item) {
	int val = 0x00;
	if (isContainer(item)) {
		list contents;
		getContents(contents, item);
		for (int i = numInList(contents); i > 0x00; i--) {
			val = val + get_item_value(contents[0x00]);
			removeItem(contents, 0x00);
		}
	} else {
		val = getValue(item);
	}
	int vended_price = 0x00;
	if (hasObjVar(item, "vendedPrice")) {
		vended_price = getObjVar(item, "vendedPrice");
	}
	if (vended_price > val) {
		val = vended_price;
	}
	return(val);
}

function int get_daily_charge() {
	int charge = get_item_value(getBackpack(this)) / 0x01F4 + 0x14;
	if (hasObjVar(this, "ownerMurderCount")) {
		charge = charge * getObjVar(this, "ownerMurderCount");
	}
	return(charge);
}

function int get_gold_held_for(obj owner) {
	list goldOwnerList;
	getObjListVar(goldOwnerList, this, "goldOwnerList");
	int quantity = 0x00;
	for (int i = 0x00; i < numInList(goldOwnerList); i++) {
		obj entry = goldOwnerList[i];
		if (owner == entry) {
			list goldQuantityList;
			getObjListVar(goldQuantityList, this, "goldQuantityList");
			quantity = goldQuantityList[i];
			break;
		}
	}
	return(quantity);
}

function void report_finances(obj user) {
	if (!isEditing(user)) {
		if (get_owner() != user) {
			barkTo(this, user, "Why would you care?  You don't run this shop.");
			return();
		}
	}
	update_murder_count(user);
	int quantity = get_gold_held_for(user);
	int myAccount = getObjVar(this, "myAccount");
	barkTo(this, user, "I am holding " + quantity + " gold for you.");
	int daily_charge = get_daily_charge();
	barkTo(this, user, "My current charge is " + daily_charge + " gold per day.");
	int days_remaining = (quantity + myAccount) / daily_charge;
	int earth_days = days_remaining / 0x0C;
	if (days_remaining > 0x00) {
		barkTo(this, user, "Including your gold I'm holding, I have enough gold to continue working for " + days_remaining + " days. (" + earth_days + " earth days)");
	} else {
		int shortfall = daily_charge - quantity - myAccount;
		barkTo(this, user, "You need to give me " + shortfall + " gold by the end of the day to retain my services.");
	}
	return();
}

function void self_destruct() {
	bark(this, "I regret nothing!");
	list args;
	message(getBackpack(this), "cleanup", args);
	makeVulnerable(this);
	setCurHP(this, 0x00);
	loseHP(this, 0x2710);
	return();
}

function int deduct_daily_charge() {
	int daily_charge = get_daily_charge();
	int myAccount = getObjVar(this, "myAccount");
	myAccount = myAccount - daily_charge;
	if (myAccount < 0x00) {
		obj gold = withdraw_gold(this, get_owner(), 0x00 - myAccount);
		if (gold != NULL()) {
			myAccount = myAccount + getQuantity(gold);
			deleteObject(gold);
		}
		if (myAccount < 0x00) {
			self_destruct();
			return(0x00);
		}
	}
	setObjVar(this, "myAccount", myAccount);
	return(0x01);
}

trigger callback(0x90) {
	callback(this, 0x7080, 0x90);
	return(deduct_daily_charge());
}

trigger speech("*") {
	if (!isFreelyViewable(this, speaker)) {
		return(0x01);
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	list words;
	split(words, arg);
	int addressed = 0x00;
	int action = 0x00;
	for (int i = 0x00; i < numInList(words); i++) {
		string word = words[i];
		if (word == "vendor") {
			addressed = 0x01;
		}
		if (word == "salesman") {
			addressed = 0x01;
		}
		if (word == "salesperson") {
			addressed = 0x01;
		}
		if (word == "saleswoman") {
			addressed = 0x01;
		}
		if (word == "shopkeeper") {
			addressed = 0x01;
		}
		if (word == "hi") {
			addressed = 0x01;
		}
		if (word == "greetings") {
			addressed = 0x01;
		}
		if (word == "hello") {
			addressed = 0x01;
		}
		if (word == "yo") {
			addressed = 0x01;
		}
		if (word == "hey") {
			addressed = 0x01;
		}
		if (word == "hail") {
			addressed = 0x01;
		}
		if (word == getName(this)) {
			addressed = 0x01;
		}
		if (word == "buy") {
			action = 0x02;
			break;
		}
		if (word == "purchase") {
			action = 0x02;
			break;
		}
		if (word == "browse") {
			action = 0x01;
			break;
		}
		if (word == "view") {
			action = 0x01;
			break;
		}
		if (word == "look") {
			action = 0x01;
			break;
		}
		if (word == "collect") {
			action = 0x03;
			break;
		}
		if (word == "gold") {
			action = 0x03;
			break;
		}
		if (word == "get") {
			action = 0x03;
			break;
		}
		if (word == "status") {
			action = 0x04;
			break;
		}
		if (word == "info") {
			action = 0x04;
			break;
		}
	}
	if (!addressed) {
		return(0x01);
	}
	int dir = getDirectionInternal(getLocation(this), getLocation(speaker));
	faceHere(this, dir);
	if (action == 0x00) {
		return(0x01);
	}
	switch(action) {
	case 0x01
		barkTo(this, speaker, "Take a look at my wares.");
		int result = openContainer(speaker, getBackpack(this));
		break;
	case 0x02
		prompt_buy_item(speaker);
		break;
	case 0x03
		collect_gold(speaker);
		break;
	case 0x04
		report_finances(speaker);
		break;
	}
	return(0x00);
}

trigger objectloaded {
	callback(this, 0x7080, 0x90);
	callback(this, 0x00, 0x81);
	return(0x01);
}

trigger callback(0x81) {
	if (getCreationLoc(this) != getLocation(this)) {
		int result = teleport(this, getCreationLoc(this));
	}
	check_inventory();
	return(0x01);
}

trigger message("housedecay") {
	self_destruct();
	return(0x01);
}

trigger destroyed {
	if (hasObjVar(this, "multi")) {
		obj multi = getObjVar(this, "multi");
		if (isValid(multi)) {
			list args;
			appendToList(args, this);
			message(multi, "vendordelete", args);
		}
	}
	return(0x01);
}
