inherits globals;

function string get_mark_desc(loc mark_loc, loc rune_loc) {
	string desc;
	loc nearest_loc;
	int found = getLocalizedDesc(desc, nearest_loc, mark_loc, rune_loc);
	if (!found) {
		desc = "an unknown location";
	}
	return(desc);
}

function void update_rune_desc(obj rune) {
	string text = "an unmarked recall rune";
	if (hasObjVar(rune, "markLoc")) {
		loc mark_loc = getObjVar(rune, "markLoc");
		loc rune_loc = getLocation(rune);
		string desc = get_mark_desc(mark_loc, rune_loc);
		text = "a recall rune for " + desc;
	}
	setObjVar(rune, "lookAtText", text);
	return();
}

trigger creation {
	update_rune_desc(this);
	return(0x01);
}

trigger message("marked") {
	update_rune_desc(this);
	return(0x01);
}

function void prompt_rune_desc(obj rune, obj user) {
	if (!hasObjVar(rune, "markLoc")) {
		systemMessage(user, "That rune is not yet marked.");
		return();
	}
	systemMessage(user, "Please enter a description for this marked object:");
	textEntry(rune, user, 0x15, 0x00, "");
	return();
}

trigger textentry(0x15) {
	if (!hasObjVar(this, "markLoc")) {
		systemMessage(sender, "That rune is not yet marked.");
		return(0x00);
	}
	if (button == 0x00) {
		systemMessage(sender, "Request cancelled.");
		return(0x00);
	}
	string look_text = "a recall rune for ";
	concat(look_text, text);
	setObjVar(this, "lookAtText", look_text);
	systemMessage(sender, "Rune now described as: " + look_text);
	return(0x00);
}

trigger use {
	prompt_rune_desc(this, user);
	return(0x00);
}

trigger isstackableon {
	if ((hasObjVar(this, "markLoc")) || (hasObjVar(stackon, "markLoc"))) {
		return(0x00);
	}
	return(0x01);
}
