inherits globals;

function obj get_vendor() {
	obj container = getTopmostContainer(this);
	if (container == NULL()) {
		return(NULL());
	}
	if (!hasScript(container, "vendor")) {
		return(NULL());
	}
	return(container);
}

function void cleanup() {
	if (isContainer(this)) {
		list contents;
		getContents(contents, this);
		while (numInList(contents)) {
			list args;
			message(contents[0x00], "cleanup", args);
			removeItem(contents, 0x00);
		}
	}
	removeObjVar(this, "vendedOwner");
	removeObjVar(this, "vendedPrice");
	removeObjVar(this, "description");
	detachScript(this, "vended");
	return();
}

function obj get_owner() {
	if (hasObjVar(this, "vendedOwner")) {
		return(getObjVar(this, "vendedOwner"));
	}
	return(getObjVar(get_vendor(), "owner"));
}

function int get_price() {
	if (!hasObjVar(this, "vendedPrice")) {
		return(0x00 - 0x01);
	}
	return(getObjVar(this, "vendedPrice"));
}

function int is_keyring(obj b) {
	switch(getObjType(b)) {
	case 0x0FEF
	case 0x0FF0
	case 0x0FF1
	case 0x0FF2
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int can_remove_from_sale(obj t) {
	if (hasObjVar(t, "isLocked")) {
		barkTo(get_owner(), get_owner(), "Locked items may not be made not-for-sale.");
		return(0x01);
	}
	if (isContainer(t)) {
		if (!isRealContainer(t)) {
			switch(getObjType(t)) {
			case 0x0EFA
			case 0x0E3B
				break;
			default
				return(0x01);
			}
		} else {
			list contents;
			getContents(contents, t);
			for (int i = numInList(contents); i; i--) {
				if ((!hasScript(contents[0x00], "vended")) || ((!hasObjVar(contents[0x00], "vendedPrice")))) {
					if (!can_remove_from_sale(contents[0x00])) {
						barkTo(get_owner(), get_owner(), "To be not for sale, all contents of a container must be for sale.");
						return(0x00);
					}
				}
				removeItem(contents, 0x00);
			}
		}
		return(0x01);
	}
	if (is_keyring(t)) {
		return(0x01);
	}
	obj parent = containedBy(t);
	if (!isValid(parent)) {
		bark(get_owner(), "It's not in a container.");
		return(0x00);
	}
	if (hasObjVar(parent, "vendedPrice")) {
		return(0x01);
	}
	barkTo(get_owner(), get_owner(), "Only the following items may be made not-for-sale: books, containers, keyrings, and items in a for-sale container.");
	return(0x00);
}

function void checkStatus() {
	if (isContainer(this)) {
		list contents;
		getContents(contents, this);
		while (numInList(contents)) {
			list args;
			if (!hasScript(contents[0x00], "vended")) {
				attachScript(contents[0x00], "vended");
			}
			message(contents[0x00], "checkStatus", args);
			removeItem(contents, 0x00);
		}
	}
	if (get_price() < 0x00) {
		if (!can_remove_from_sale(this)) {
			setObjVar(this, "vendedPrice", getValue(this));
		}
	}
	return();
}

trigger textentry(0x1A) {
	if (sender != get_owner()) {
		return(0x00);
	}
	if (!isFreelyViewable(this, sender)) {
		return(0x00);
	}
	if (button == 0x00) {
		if (hasObjVar(this, "vendedPrice")) {
			removeObjVar(this, "vendedPrice");
		}
		scriptTrig(this, 0x1C, get_owner());
		return(0x00);
	}
	int price = text;
	if (price < 0x00) {
		systemMessage(get_owner(), "Only containers can be set to 'not for sale.'");
	}
	if (price > 0x000F4240) {
		price = 0x000F4240;
	}
	string price_str = price;
	string original_text = text;
	removePrefix(text, price_str);
	if (original_text == text) {
		if (can_remove_from_sale(this)) {
			price = 0x00 - 0x01;
		} else {
			return(0x00);
		}
	}
	removePrefix(text, " ");
	removePrefix(text, " ");
	removePrefix(text, ",");
	removePrefix(text, " ");
	removePrefix(text, " ");
	if (text == "") {
		removeObjVar(this, "description");
	} else {
		setObjVar(this, "description", text);
	}
	if (price < 0x00) {
		if (hasObjVar(this, "vendedPrice")) {
			removeObjVar(this, "vendedPrice");
		}
	} else {
		setObjVar(this, "vendedPrice", price);
	}
	scriptTrig(this, 0x1C, get_owner());
	return(0x00);
}

trigger wasgotten {
	if (isEditing(getter)) {
		return(0x01);
	}
	if (get_price() == 0x00) {
		return(0x01);
	}
	if (getter != get_owner()) {
		systemMessage(getter, "To purchase items, say 'vendor buy'.");
		return(0x00);
	}
	return(0x01);
}

trigger wasdropped {
	if (get_vendor() == NULL()) {
		setDefaultReturn(0x01);
		cleanup();
	}
	return(0x01);
}

trigger creation {
	if (containedBy(this) != NULL()) {
		if (hasScript(containedBy(this), "vendor")) {
			return(0x00);
		}
	}
	systemMessage(get_owner(), "Type in a price and description for " + getName(this) + ": (ESC=Not for sale)");
	textEntry(this, get_owner(), 0x1A, 0x00, "Type in a price for " + getName(this) + ".");
	return(0x00);
}

trigger message("checkStatus") {
	checkStatus();
	return(0x00);
}

trigger lookedat {
	string price_str = get_price();
	if (get_price() == 0x00) {
		price_str = "FREE!";
	}
	if (get_price() < 0x00) {
		price_str = "Not for sale.";
		if (!can_remove_from_sale(this)) {
			setObjVar(this, "vendedPrice", getValue(this));
			price_str = get_price();
		}
	}
	string desc = "";
	if (hasObjVar(this, "description")) {
		desc = getObjVar(this, "description");
		desc = desc + ".  ";
	}
	barkTo(this, looker, desc + "Cost:" + price_str);
	return(0x01);
}

trigger give {
	if (giver != get_owner()) {
		barkTo(get_vendor(), giver, "I can only accept items from the shop owner.");
		return(0x00);
	}
	setObjVar(givenobj, "vendedOwner", giver);
	attachScript(givenobj, "vended");
	return(0x01);
}

trigger message("cleanup") {
	cleanup();
	return(0x00);
}

trigger message("purchase") {
	obj user = args[0x00];
	int result;
	if (user == get_owner()) {
		systemMessage(user, "You take the item.");
		result = putObjContainer(this, getBackpack(user));
		cleanup();
		return(0x00);
	}
	obj vendor = get_vendor();
	int price = get_price();
	if (price < 0x00) {
		systemMessage(user, "This item is not for sale.");
		return(0x00);
	}
	if (price == 0x00) {
		systemMessage(user, "You take " + getName(this) + ".");
		result = putObjContainer(this, getBackpack(user));
		cleanup();
		return(0x00);
	}
	obj gold = NULL();
	if (price > 0x00) {
		if (price <= getMoney(user)) {
			gold = transferGenericToContainer(vendor, user, 0x0EED, price);
			systemMessage(user, "You purchase " + getName(this) + ".");
		} else {
			if (price <= amtGoldInBank(user)) {
				result = withdrawFromBank(user, price);
				gold = transferGenericToContainer(vendor, user, 0x0EED, price);
				systemMessage(user, "You purchase " + getName(this) + " with the gold in your bank account.");
			} else {
				systemMessage(user, "You cannot afford this item.");
				return(0x00);
			}
		}
	}
	list goldOwnerList;
	list goldQuantityList;
	if (hasObjListVar(vendor, "goldOwnerList")) {
		getObjListVar(goldOwnerList, vendor, "goldOwnerList");
		getObjListVar(goldQuantityList, vendor, "goldQuantityList");
	}
	for (int i = 0x00; 0x01; i++) {
		if (i >= numInList(goldOwnerList)) {
			append(goldOwnerList, get_owner());
			append(goldQuantityList, price);
			break;
		}
		obj owner_entry = goldOwnerList[i];
		if (get_owner() == owner_entry) {
			int existing_qty = goldQuantityList[i];
			setItem(goldQuantityList, existing_qty + price, i);
			break;
		}
	}
	setObjVar(vendor, "goldOwnerList", goldOwnerList);
	setObjVar(vendor, "goldQuantityList", goldQuantityList);
	result = putObjContainer(this, getBackpack(user));
	cleanup();
	return(0x00);
}

trigger objectloaded {
	if (hasObjVar(this, "owner")) {
		if (!hasScript(this, "magicitem")) {
			removeObjVar(this, "owner");
		}
	}
	setObjVar(this, "vendedOwner", get_owner());
	if (hasObjVar(this, "price")) {
		int price = getObjVar(this, "price");
		setObjVar(this, "vendedPrice", price);
		removeObjVar(this, "price");
	}
	if (get_vendor() == NULL()) {
		cleanup();
		return(0x01);
	}
	return(0x01);
}
