inherits spelskil;

member loc dest_loc;

member int is_active;

trigger creation {
	setX(dest_loc, getObjVar(this, "xPoint"));
	setY(dest_loc, getObjVar(this, "yPoint"));
	setZ(dest_loc, getObjVar(this, "zPoint"));
	return(0x00);
}

function void prompt_moongate_confirm(obj me, obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "Yes");
	appendToList(options, 0x01);
	appendToList(options, "No");
	selectType(player, me, 0x2C, "Dost thou wish to step into the moongate?", options);
	return();
}

function int teleport_player_to_dest(obj me, obj player) {
	teleport_followers(player, dest_loc);
	if (teleport(player, dest_loc)) {
		sfx(getLocation(player), 0x01FE, 0x00);
		return(0x01);
	}
	return(0x00);
}

function int is_justice_exit(obj me, obj player) {
	if ((inJusticeRegion(getLocation(me))) && (!inJusticeRegion(dest_loc))) {
		return(0x01);
	}
	return(0x00);
}

function int can_enter_gate(obj gate, obj it) {
	if (!is_active) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(gate), getLocation(it)) > 0x01) {
		return(0x00);
	}
	int it_z = getZ(getLocation(it));
	int gate_z = getZ(getLocation(gate));
	int gate_height = getHeight(gate);
	int gate_top = gate_z + gate_height;
	if ((it_z < gate_z) || (it_z > gate_top)) {
		return(0x00);
	}
	return(0x01);
}

function int handle_gate_enter(obj gate, obj player) {
	if (!can_enter_gate(gate, player)) {
		return(0x01);
	}
	reveal_and_notify(player);
	int result;
	if (is_justice_exit(gate, player)) {
		prompt_moongate_confirm(gate, player);
		result = teleport(player, getLocation(gate));
		return(0x00);
	} else {
		result = teleport_player_to_dest(gate, player);
	}
	return(0x00);
}

trigger enterrange(0x00) {
	return(handle_gate_enter(this, target));
}

trigger use {
	if (getLocation(this) == getLocation(user)) {
		int result = handle_gate_enter(this, user);
	}
	return(0x00);
}

trigger typeselected(0x2C) {
	if (listindex == 0x00) {
		return(0x00);
	}
	if (objtype != 0x00) {
		return(0x00);
	}
	if (!can_enter_gate(this, user)) {
		return(0x00);
	}
	int result = teleport_player_to_dest(this, user);
	return(0x00);
}

trigger callback(0x79) {
	loc gate_loc = getLocation(this);
	int okay = 0x01;
	if (!hasObjVar(this, "sourceGate")) {
		deleteObject(this);
	}
	if (isAnyMultiAt(gate_loc) != NULL()) {
		okay = 0x00;
	}
	if (has_gate_at_loc(gate_loc, this)) {
		okay = 0x00;
	}
	list status_args;
	appendToList(status_args, okay);
	obj source_gate = getObjVar(this, "sourceGate");
	appendToList(status_args, this);
	multimessage(source_gate, "gatestatus", status_args);
	is_active = okay;
	if (!okay) {
		deleteObject(this);
	}
	return(0x01);
}

trigger message("gatestatus") {
	int i = args[0x00];
	if (i) {
		is_active = 0x01;
	} else {
		deleteObject(this);
	}
	return(0x01);
}
