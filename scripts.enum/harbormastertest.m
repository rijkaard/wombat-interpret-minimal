inherits globals;

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
	loc loc_out;
	string loc_name;
	int has_loc = getLocalizedDesc(loc_name, loc_out, where, where);
	if (has_loc) {
		concat(desc, " from ");
		concat(desc, loc_name);
	}
	setObjVar(ticket, "lookAtText", desc);
	return();
}

function obj create_ship_claim_ticket(obj ship, loc where) {
	list objects_on_ship;
	getObjectsOnMulti(objects_on_ship, ship);
	if (numInList(objects_on_ship) > 0x00) {
		return(NULL());
	}
	obj ticket = createGlobalObjectAt(0x0EFA, where);
	if (ticket == NULL()) {
		return(NULL());
	}
	setType(ticket, 0x14F2);
	setStatus(ticket, 0x80, 0x01);
	int ship_type = 0x00;
	if (hasObjVar(ship, "myshiptype")) {
		ship_type = getObjVar(ship, "myshiptype");
		setObjVar(ticket, "myshiptype", ship_type);
	}
	if (hasObjVar(ship, "mymultiname")) {
		string ship_name = getObjVar(ship, "mymultiname");
		setObjVar(ticket, "mymultiname", ship_name);
	}
	set_claim_ticket_desc(ticket, ship, where);
	setObjVar(ticket, "claimloc", where);
	setObjVar(ticket, "shipobj", ship);
	attachScript(ticket, "shipclaim");
	int put_result = putObjContainer(ship, ticket);
	return(ticket);
}

function void prompt_dock_ship(obj user, obj npc) {
	barkTo(npc, user, "What ship do you want to dock?");
	targetObj(user, npc);
	return();
}

trigger speech("*") {
	list words;
	split(words, arg);
	if (isInList(words, "dock")) {
		prompt_dock_ship(speaker, this);
		return(0x00);
	}
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
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
			obj ticket = create_ship_claim_ticket(ship, getLocation(this));
			if (ticket == NULL()) {
				barkTo(this, user, "I could not dock the ship.");
				barkTo(this, user, "Make sure the deck is clear.");
			} else {
				int result = toMobile(ticket, user);
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
