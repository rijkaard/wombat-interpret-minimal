inherits identify;

member list seen_by;

forward void track_looker(obj owner);

forward int has_seen_item(obj looker);

trigger lookedat {
	if (hasObjVar(this, "owner")) {
		obj owner = getObjVar(this, "owner");
		track_looker(owner);
	}
	string name;
	name = get_display_name(this);
	if (hasObjVar(this, "beenIdentified")) {
		if (has_seen_item(looker) > 0x00) {
			string magic_item_name = getObjVar(this, "MagicItemName");
			name = magic_item_name;
			if (hasObjVar(this, "charges")) {
				int charges = getObjVar(this, "charges");
				if (charges > 0x00) {
					name = magic_item_name + "  charges: " + charges;
				}
			}
		}
	}
	barkTo(this, looker, name);
	return(0x00);
}

trigger creation {
	setObjVar(this, "lookAtText", get_display_name(this));
	return(0x00);
}

function void track_looker(obj player) {
	if (isInList(seen_by, player)) {
		for (int i = 0x00; i < numInList(seen_by); i++) {
			obj item = seen_by[i];
			if (player == item) {
				return();
			}
		}
	} else {
		appendToList(seen_by, player);
	}
	if (numInList(seen_by) > 0x04) {
		removeItem(seen_by, 0x05);
	}
	return();
}

function int has_seen_item(obj looker) {
	for (int i = 0x00; i < numInList(seen_by); i++) {
		obj item = seen_by[i];
		if (looker == item) {
			return(0x01);
		}
	}
	return(0x00);
}
