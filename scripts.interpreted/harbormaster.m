inherits multistuff;

function int user_has_ship_key(obj house, obj mobile) {
	obj door = NULL();
	if (hasObjListVar(house, "myhousedoors")) {
		list doors;
		getObjListVar(doors, house, "myhousedoors");
		if (numInList(doors) > 0x00) {
			door = doors[0x00];
		}
	} else {
		if (hasObjVar(house, "myhousedoor")) {
			door = getObjVar(house, "myhousedoor");
		}
	}
	if (door == NULL()) {
		return(0x00);
	}
	obj key = mobileHasObjWithListObjOfObj(mobile, "whatIUnlock", door);
	if (key == NULL()) {
		return(0x00);
	}
	return(0x01);
}

function void set_claim_ticket_desc(obj ticket, obj ship, loc where) {
	string desc = "a ship claim ticket";
	loc area_loc;
	string area_name;
	int has_area = getLocalizedDesc(area_name, area_loc, where, where);
	if (has_area) {
		concat(desc, " from ");
		concat(desc, area_name);
	}
	if (has_name(ship)) {
		concat(desc, " for the ");
		concat(desc, get_custom_multi_name(ship));
	}
	setObjVar(ticket, "lookAtText", desc);
	return();
}

function obj dock_ship(obj ship, loc where) {
	list objects_on_deck;
	getObjectsOnMulti(objects_on_deck, ship);
	if (numInList(objects_on_deck) > 0x00) {
		return(NULL());
	}
	obj shiphold = NULL();
	if (hasObjVar(ship, "myshiphold")) {
		shiphold = getObjVar(ship, "myshiphold");
	}
	if (shiphold != NULL()) {
		list hold_contents;
		getContents(hold_contents, shiphold);
		int hold_count = numInList(hold_contents);
		if (hold_count > 0x00) {
			return(NULL());
		}
	}
	obj claim_ticket = createGlobalObjectAt(0x0E76, where);
	if (claim_ticket == NULL()) {
		return(NULL());
	}
	setType(claim_ticket, 0x14F2);
	setStatus(claim_ticket, 0x80, 0x01);
	int ship_type = 0x00;
	if (hasObjVar(ship, "myshiptype")) {
		ship_type = getObjVar(ship, "myshiptype");
		setObjVar(claim_ticket, "myshiptype", ship_type);
	}
	if (hasObjVar(ship, "mymultiname")) {
		string ship_name = getObjVar(ship, "mymultiname");
		setObjVar(claim_ticket, "mymultiname", ship_name);
	}
	set_claim_ticket_desc(claim_ticket, ship, where);
	setObjVar(claim_ticket, "claimloc", where);
	setObjVar(claim_ticket, "shipobj", ship);
	attachScript(claim_ticket, "shipclaim");
	int ticket_put_result = putObjContainer(ship, claim_ticket);
	return(claim_ticket);
}

function void prompt_dock_ship(obj user, obj npc) {
	if (amtGoldInBank(user) < 0x19) {
		barkTo(this, user, "Thou dost not have 25 gold in thy bank account.");
		return();
	}
	barkTo(npc, user, "I charge 25 gold for docking thy ship.  What ship do you want to dock?");
	targetObj(user, npc);
	return();
}

trigger speech("*") {
	list words;
	split(words, arg);
	if (isInList(words, "dock")) {
		prompt_dock_ship(speaker, this);
		return(0x00);
	} else {
		if (isInList(words, "job")) {
			bark(this, "I am a harbormaster.  I dock ships for a fee.");
			return(0x00);
		}
	}
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (amtGoldInBank(user) < 0x19) {
		barkTo(this, user, "Thou dost not have 25 gold in thy bank account.");
		return(0x00);
	}
	if (!isValid(usedon)) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(this), getLocation(usedon)) > 0x64) {
		barkTo(this, user, "That is too far away.");
		return(0x00);
	}
	if (isMultiComp(usedon) && (hasObjVar(getMultiSlaveId(usedon), "myshiptype"))) {
		obj ship = getMultiSlaveId(usedon);
		if (user_has_ship_key(ship, user)) {
			obj claim_ticket = dock_ship(ship, getLocation(this));
			if (claim_ticket == NULL()) {
				barkTo(this, user, "I could not dock the ship.");
				barkTo(this, user, "Make sure the deck is clear and the hold is empty.");
			} else {
				int fee_result = withdrawAndDestroy(user, 0x19);
				int move_result = toMobile(claim_ticket, user);
				barkTo(this, user, "Here is your claim ticket.  I suggest you store it in your safety deposit box for safety.");
			}
		} else {
			barkTo(this, user, "You must have the key to the ship you wish to dock.");
		}
	} else {
		barkTo(this, user, "That is not a ship!");
	}
	return(0x00);
}
