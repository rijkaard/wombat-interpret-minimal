inherits comreceiver;

forward string guildName();

forward string guild_abbrev();

forward string myGuildTitle();

forward void sync_guild_info(obj this);

trigger lookedat {
	if (hasObjVar(this, "displayGuildAbbr")) {
		string ab = getObjVar(this, "guildAbbreviation");
		if (hasObjVar(this, "isGuildmaster")) {
			string x = getObjVar(this, "gmTitle");
			ab = x + ", " + ab;
		} else {
			if (myGuildTitle() != " ") {
				ab = myGuildTitle() + ", " + ab;
			}
		}
		ab = "[" + ab + "]" + " " + get_guild_suffix(get_guild_type());
		barkTo(this, looker, ab);
	}
	return(0x01);
}

trigger objectloaded {
	sync_guild_info(this);
	return(0x01);
}

trigger speech("*I resign from my guild*") {
	if (speaker != this) {
		return(0x01);
	}
	resign_from_guild(this);
	return(0x00);
}

function string guildName() {
	if (!hasObjVar(this, "guildName")) {
		list args;
		message(this, "removedFromGuild", args);
		return("");
	}
	string x = getObjVar(this, "guildName");
	return(x);
}

function string guild_abbrev() {
	if (!hasObjVar(this, "guildAbbreviation")) {
		list args;
		message(this, "removedFromGuild", args);
		return("");
	}
	string x = getObjVar(this, "guildAbbreviation");
	return(x);
}

function string myGuildTitle() {
	if (!hasObjVar(this, "myGuildTitle")) {
		return(" ");
	}
	string x = getObjVar(this, "myGuildTitle");
	return(x);
}

function void sync_guild_info(obj this) {
	loc relay_loc = 0x00, 0x00, (0x00 - 0x50);
	if (!hasObjVar(this, "guildstoneId")) {
		list args;
		message(this, "removedFromGuild", args);
		return();
	}
	obj guildstone = getObjVar(this, "guildstoneId");
	list blah;
	multimessage(guildstone, "updateMyGuildInfo", blah);
	blah = guildstone;
	multiMessageToLoc(relay_loc, "doesMyGuildExist", blah);
	return();
}

trigger message("updateGuildInfo") {
	int is_member = args[0x00];
	string guild_name = args[0x01];
	string new_abbrev = args[0x02];
	int guild_type = args[0x03];
	string guild_title = args[0x04];
	obj guildmaster = args[0x05];
	string gmTitle = args[0x06];
	list opposing_guilds;
	sendToNearbyPlayers(this, 0x00);
	copyList(opposing_guilds, args[0x07]);
	setObjVar(this, "opposingGuilds", opposing_guilds);
	if (guildmaster == this) {
		setObjVar(this, "isGuildmaster", 0x01);
		setObjVar(this, "gmTitle", gmTitle);
	} else {
		removeObjVar(this, "isGuildmaster");
		removeObjVar(this, "gmTitle");
	}
	if (!hasObjVar(this, "guildName")) {
		setObjVar(this, "guildName", "unaffiliated");
	}
	if (guild_name != guildName()) {
		systemMessage(this, "The name of your guild has changed from " + guildName() + " to " + guild_name + ".");
		setObjVar(this, "guildName", guild_name);
	}
	if (!hasObjVar(this, "guildAbbreviation")) {
		setObjVar(this, "guildAbbreviation", "[none]");
	}
	if (new_abbrev != guild_abbrev()) {
		systemMessage(this, "Your guild abbreviation has changed from " + guild_abbrev() + " to " + new_abbrev + ".");
		setObjVar(this, "guildAbbreviation", new_abbrev);
	}
	if (!hasObjVar(this, "myGuildTitle")) {
		setObjVar(this, "myGuildTitle", " ");
	}
	if (guild_title != myGuildTitle()) {
		systemMessage(this, "Your guild abbreviation has changed from " + guild_title + ".");
		setObjVar(this, "myGuildTitle", guild_title);
	}
	if (guild_type != get_guild_type()) {
		systemMessage(this, "Your guild is now " + get_guild_label(guild_type) + " to ");
	}
	sendToNearbyPlayers(this, 0x00);
	if (check_guild_requirements(this, guild_type)) {
		if (guild_type != get_guild_type()) {
			message(this, "removedFromSpecialGuild", args);
			setObjVar(this, "guildType", guild_type);
			string guild_script = get_guild_script(guild_type);
			if (guild_script != "") {
				attachScript(this, guild_script);
				message(this, "addedToSpecialGuild", args);
			}
		}
	} else {
		systemMessage(this, "You are no longer qualified to be a member of your guild.");
		resign_from_guild(this);
		return(0x01);
	}
	if (!is_member) {
		systemMessage(this, "You have been dismissed from " + guildName() + ".");
		message(this, "guildAbbreviation", args);
	}
	return(0x01);
}

function void clear_guild_data() {
	removeObjVar(this, "guildName");
	removeObjVar(this, "guildAbbreviation");
	removeObjVar(this, "myGuildTitle");
	removeObjVar(this, "guildstoneId");
	removeObjVar(this, "displayGuildAbbr");
	removeObjVar(this, "opposingGuilds");
	removeObjVar(this, "guildType");
	removeObjVar(this, "gmTitle");
	removeObjVar(this, "isGuildmaster");
	sendToNearbyPlayers(this, 0x00);
	return();
}

trigger message("removedFromGuild") {
	clear_guild_data();
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

trigger message("guildGone") {
	systemMessage(this, "Guild message: Your guild has been disbanded!");
	clearList(args);
	message(this, "removedFromGuild", args);
	return(0x01);
}

function void prompt_murder_report() {
	if (!hasObjVar(this, "myGuildTitle")) {
		return();
	}
	list canReportNameList;
	getObjListVar(canReportNameList, this, "myGuildTitle");
	string msg = canReportNameList[0x00];
	msg = "Would you like to report " + msg + " as a murderer?";
	systemMessage(this, msg);
	int bank_gold = amtGoldInBank(this);
	stringQuery(this, this, 0x21, msg, 0x01, 0x02, bank_gold, " " + bank_gold + " max)");
	return();
}

trigger textentry(0x21) {
	if (sender != this) {
		return(0x00);
	}
	list canReportNameList;
	getObjListVar(canReportNameList, this, "canReportNameList");
	list canReportIdList;
	getObjListVar(canReportIdList, this, "canReportIdList");
	int result;
	list args;
	debugMessage("button=" + button);
	if (button == 0x01) {
		obj player = canReportIdList[0x00];
		string suspect_name = canReportNameList[0x00];
		debugMessage("text='" + text + "'");
		int bounty = text;
		string bounty_str = bounty;
		if (text == bounty_str) {
			int bank_gold = amtGoldInBank(this);
			if (bounty > bank_gold) {
				bounty = bank_gold;
			}
			if (bounty > 0x00) {
				result = withdrawAndDestroy(this, bounty);
				obj bountyInfo = createNoResObjectAt(0x01, getLocation(this));
				setObjVar(bountyInfo, "You have been given a new guild title: ", player);
				attachScript(bountyInfo, "bountyinfo");
				args = player, bounty, 0x00, suspect_name;
				message(bountyInfo, "addBounty", args);
				result = teleport(bountyInfo, getRelayLoc(player));
				if (isValid(bountyInfo)) {
					clearList(args);
					message(bountyInfo, "teleported", args);
				}
			}
		}
		args = getAdjFame(this);
		relay_message(player, "murderReport", args);
		result = addToObjVarListSet(this, "recentlyReported", player);
		callbackAdvanced(this, 0x04B0, TIMER_EVENT_CRIMINAL, 0x04);
	}
	removeItem(canReportIdList, 0x00);
	removeItem(canReportNameList, 0x00);
	if (numInList(canReportIdList) > 0x00) {
		setObjVar(this, "canReportIdList", canReportIdList);
		setObjVar(this, "canReportNameList", canReportNameList);
		shortCallback(this, 0x01, 0x8C);
	} else {
		removeObjVar(this, "canReportIdList");
		removeObjVar(this, "canReportNameList");
	}
	return(0x00);
}

trigger online {
	if (isDead(this)) {
		shortCallback(this, 0x14, 0x8C);
	}
	return(0x01);
}

trigger message("refreshAggression") {
	refreshAggression(this);
	return(0x00);
}

trigger message("refreshCriminal") {
	loc crime_loc = args[0x00];
	committedCrimeAt(this, crime_loc, 0x01E0)return(0x00);
}

trigger message("changeReputation") {
	changeFame(this, args[0x00]);
	changeKarma(this, args[0x01]);
	return(0x00);
}

trigger message("murderReport") {
	int reporter_fame = args[0x00];
	int murderCount = 0x01 + getMurderCount(this);
	if (murderCount >= 0x05) {
		if (murderCount == 0x05) {
			systemMessage(this, "You are now known as a murderer!");
		}
		int hair_hue = 0x00;
		int hair_type = 0x00;
		obj hair = getItemAtSlot(this, EQUIP_HAIR);
		if (hair != NULL()) {
			hair_hue = getHue(hair);
			hair_type = getObjType(hair);
		}
		args = this, murderCount, getSex(this), hair_type, hair_hue, getHue(this);
		multiMessageToLoc(getRelayLoc(this), "updateBountyDesc", args);
	}
	changeKarma(this, 0x00 - reporter_fame);
	setMurderCount(this, murderCount);
	callbackAdvanced(this, 0x0001C200, TIMER_EVENT_CRIMINAL, 0x03);
	return(0x00);
}

trigger sawdeath {
	if (!getCompileFlag(0x01)) {
		return(0x00);
	}
	if (this != victim) {
		return(0x01);
	}
	shortCallback(this, 0x01, 0x8C);
	return(0x00);
}

trigger callback(0x8C) {
	if (getMobFlag(this, 0x02)) {
		shortCallback(this, 0x01, 0x8C);
		return(0x01);
	}
	prompt_murder_report();
	return(0x01);
}

function void clear_bounty_state() {
	removeObjVar(this, "bountyGuardId");
	removeObjVar(this, "bountyPlayerName");
	return();
}

trigger callback(0x8D) {
	if (hasObjVar(this, "bountyGuardId")) {
		obj guard = getObjVar(this, "bountyGuardId");
		string player_name = getObjVar(this, "bountyPlayerName");
		string msg = "There was no bounty on " + player_name + ".";
		clear_bounty_state();
		if (isValid(guard)) {
			if (getDistanceInTiles(getLocation(guard), getLocation(this)) < 0x0A) {
				bark(guard, msg);
				return(0x00);
			}
		}
		systemMessage(this, msg);
	}
	clear_bounty_state();
	return(0x01);
}

trigger speech("myGuildTitle") {
	if (speaker == this) {
		return(0x01);
	}
	if (!isMurderer(this)) {
		return(0x01);
	}
	if (!inJusticeRegion(getLocation(this))) {
		return(0x01);
	}
	callGuards(this, speaker, 0x03E8);
	return(0x00);
}

trigger message("bountyInfo") {
	obj subject = args[0x00];
	int bounty = args[0x01];
	string player_name = args[0x02];
	obj gold = createNoResObjectIn(0x0EED, this);
	int result = requestAddQuantity(gold, bounty);
	result = depositIntoBank(this, gold, bounty);
	removeCallback(this, 0x8D);
	if (hasObjVar(this, "bountyGuardId")) {
		obj guard = getObjVar(this, "bountyGuardId");
		string msg = "The bounty on " + player_name + " was " + bounty + " gold, and has been credited to your account.";
		changeKarma(this, 0x07D0);
		clear_bounty_state();
		if (isValid(guard)) {
			if (getDistanceInTiles(getLocation(guard), getLocation(this)) < 0x0A) {
				bark(guard, msg);
				return(0x00);
			}
		}
		systemMessage(this, msg);
	}
	return(0x00);
}
