forward string guildName();

forward string get_guild_abbreviation();

forward string myGuildTitle();

forward void request_guild_update(obj this);

forward void cleanup(obj this);

member obj me;

trigger lookedat {
	string ab = getObjVar(this, "guildAbbreviation");
	if (ab == "none") {
		ab = guildName();
	}
	if (hasObjVar(this, "displayGuildAbbr")) {
		barkTo(this, looker, "[" + ab + "]");
	}
	return(0x01);
}

trigger objectloaded {
	request_guild_update(this);
	return(0x01);
}

function string guildName() {
	if (!hasObjVar(me, "guildName")) {
		cleanup(me);
	}
	string x = getObjVar(me, "guildName");
	return(x);
}

function string get_guild_abbreviation() {
	if (!hasObjVar(me, "guildAbbreviation")) {
		cleanup(me);
	}
	string x = getObjVar(me, "guildAbbreviation");
	return(x);
}

function string myGuildTitle() {
	if (!hasObjVar(me, "myGuildTitle")) {
		cleanup(me);
	}
	string x = getObjVar(me, "myGuildTitle");
	return(x);
}

trigger creation {
	me = this;
	setObjVar(this, "guildName", "unaffiliated");
	setObjVar(this, "guildAbbreviation", "none");
	setObjVar(this, "myGuildTitle", "");
	request_guild_update(this);
	return(0x01);
}

function void request_guild_update(obj this) {
	if (!hasObjVar(this, "guildstoneId")) {
		cleanup(me);
		return();
	}
	obj guildstone = getObjVar(this, "guildstoneId");
	list blah;
	multimessage(guildstone, "updateMyGuildInfo", blah);
	return();
}

trigger message("updateGuildInfo") {
	int still_member = args[0x00];
	string new_name = args[0x01];
	string new_abbr = args[0x02];
	string new_title = args[0x03];
	if (new_name != guildName()) {
		systemMessage(this, "The name of your guild has changed from " + guildName() + " to " + new_name + ".");
		setObjVar(this, "guildName", new_name);
	}
	if (new_abbr != get_guild_abbreviation()) {
		systemMessage(this, "Your guild abbreviation has changed from " + get_guild_abbreviation() + " to " + new_abbr + ".");
		setObjVar(this, "guildAbbreviation", new_abbr);
	}
	if (new_title != myGuildTitle()) {
		systemMessage(this, "You have been given a new guild title: " + new_title + ".");
		setObjVar(this, "myGuildTitle", new_title);
	}
	if (!still_member) {
		systemMessage(this, "You have been dismissed from " + guildName() + ".");
		cleanup(this);
	}
	return(0x01);
}

function void cleanup(obj this) {
	removeObjVar(this, "guildName");
	removeObjVar(this, "guildAbbreviation");
	removeObjVar(this, "myGuildTitle");
	removeObjVar(this, "guildstoneId");
	removeObjVar(this, "displayGuildAbbr");
	detachScript(this, "guilded");
	return();
}

trigger message("removedFromGuild") {
	cleanup(this);
	return(0x01);
}

trigger message("guildMessage") {
	string msg = args[0x00];
	systemMessage(this, "Guild message: " + msg);
	return(0x01);
}

trigger message("globalGuildMessage") {
	string msg = args[0x00];
	systemMessage(this, "Guild message: " + msg);
	return(0x01);
}
