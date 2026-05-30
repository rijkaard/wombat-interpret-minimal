inherits human;

trigger objectloaded {
	callBack(this, 0x64, 0x60);
	return(0x01);
}

trigger creation {
	int guild_id;

member string guildName;

member int my_guild;
	loc my_loc = getLocation(this);
	setObjVar(this, "myGuildLocation", my_loc);
	setLoiterMode(this, 0x01);
	goLoiter(this, my_loc, 0x03E8);
	callBack(this, 0x64, 0x60);
	setBehavior(this, 0x02);
	if (hasObjVar(this, "guildMember")) {
		guild_id = getObjVar(this, "guildMember");
	}
	if (!guild_id) {
		setObjVar(this, "guildMember", 0x00);
	}
	my_guild = guild_id;
	switch(guild_id) {
	case 0x00
		guildName = "Default Guild of Superheroic Non-Player Characters";
		break;
	case 0x01
		guildName = "Guild of Arcane Arts";
		break;
	case 0x02
		guildName = "Warrior's Guild";
		break;
	case 0x03
		guildName = "Society of Thieves";
		break;
	case 0x04
		guildName = "League of Rangers";
		break;
	case 0x05
		guildName = "Guild of Healers";
		break;
	case 0x06
		guildName = "Mining Cooperative";
		break;
	case 0x07
		guildName = "Merchants' Association";
		break;
	case 0x08
		guildName = "Order of Engineers";
		break;
	case 0x09
		guildName = "Society of Clothiers";
		break;
	case 0x0A
		guildName = "Maritime Guild";
		break;
	case 0x0B
		guildName = "Bardic Collegium";
		break;
	default
		guildName = "Default Guild of Superheroic Non-Player Characters";
		break;
	}
	return(0x00);
}

trigger callback(0x60) {
	if (hasObjVar(this, "myGuildLocation")) {
		loc there = getObjVar(this, "myGuildLocation");
		if (getDistanceInTiles(getLocation(this), there) > 0x0A) {
			int result = teleport(this, there);
		}
	}
	callBack(this, 0x64, 0x60);
	return(0x01);
}

trigger pathnotfound(0x06) {
	if (!hasObjVar(this, "myGuildLocation")) {
		return(0x00);
	}
	loc place = getObjVar(this, "myGuildLocation");
	int result = teleport(this, place);
	return(0x00);
}

trigger speech("*") {
	string word;
	list args;
	int guild_id;
	string phrases;
	if (!check_convo_eligibility(this, speaker, arg)) {
		return(0x01);
	}
	split(args, arg);
	for (int i = 0x00; i < numInList(args); i++) {
		word = args[i];
		if (word == "join" || (word == "member")) {
			if (hasObjVar(speaker, "guildMember")) {
				guild_id = getObjVar(speaker, "guildMember");
				if (guild_id != my_guild) {
					bark(this, "Thou must resign from thy other guild first.");
					return(0x00);
				}
				bark(this, "Thou art already a member of our guild.");
				return(0x00);
			}
			bark(this, "The fee for joining a guild is 500 gold coins.");
			setObjVar(speaker, "guildAskedToJoin", this);
			return(0x00);
		}
		if (word == "resign" || (word == "quit")) {
			if (hasObjVar(speaker, "guildMember")) {
				guild_id = getObjVar(speaker, "guildMember");
				if (guild_id != my_guild) {
					bark(this, "Thou dost not belong to my guild!");
					return(0x00);
				}
				bark(this, "I accept thy resignation.");
				removeObjVar(speaker, "guildMember");
				return(0x00);
			}
		}
		if (word == "guild" || (word == "guilds")) {
			phrases = "I am a Guildmaster of the " + guildName + ". Art thou interested in joining?");
			bark(this, phrases);
			return(0x00);
		}
	}
	return(0x01);
}

trigger give {
	int guild_type;
	if (hasObjVar(giver, "guildAskedToJoin")) {
		obj asked_guild = getObjVar(giver, "guildAskedToJoin");
		if (asked_guild != this) {
			return(0x01);
		}
		int value;
		int ok;
		ok = getResource(value, givenobj, "gold", 0x03, 0x02);
		if (!ok) {
			return(0x01);
		}
		if (value != 0x01F4) {
			return(0x01);
		}
		ok = putObjContainer(givenobj, this);
		deleteObject(givenobj);
		string phrases = "Welcome to the " + guildName + "!";
		guild_type = getObjVar(this, "guildMember");
		if (guild_type == 0x03) {
			phrases = phrases + " Fellow thieves and beggars shall not bother thee now.";
		} else {
			phrases = phrases + " Thou shalt find that fellow members shall grant thee lower prices in shops.";
		}
		bark(this, phrases);
		setObjVar(giver, "guildMember", guild_type);
		return(0x00);
	}
	return(0x01);
}
