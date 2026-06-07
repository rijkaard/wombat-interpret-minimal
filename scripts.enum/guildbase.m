inherits multistuff;

function string get_player_name(obj player) {
	string name;
	if (hasObjVar(player, "origName")) {
		name = getObjVar(player, "origName");
	} else {
		name = getName(player);
	}
	return(name);
}

function int get_guild_type() {
	if (!hasObjVar(this, "guildType")) {
		return(0x00);
	}
	return(getObjVar(this, "guildType"));
}

function string get_guild_label(int guild_type) {
	string label;
	switch(guild_type) {
	case 0x02
		label = "an order";
		break;
	case 0x03
		label = "a chaos";
		break;
	default
		label = "a standard";
		break;
	}
	return(label);
}

function string get_guild_suffix(int guild_type) {
	string suffix;
	switch(guild_type) {
	case 0x02
		suffix = "(Order)";
		break;
	case 0x03
		suffix = "(Chaos)";
		break;
	default
		suffix = "";
		break;
	}
	return(suffix);
}

function string get_guildstone_script(int guild_type) {
	string script_name;
	switch(guild_type) {
	case 0x02
		script_name = "orderguildstone";
		break;
	case 0x03
		script_name = "chaosguildstone";
		break;
	default
		script_name = "guildstone";
		break;
	}
	return(script_name);
}

function string get_guild_script(int guild_type) {
	string script_name;
	switch(guild_type) {
	case 0x02
		script_name = "orderguild";
		break;
	case 0x03
		script_name = "chaosguild";
		break;
	default
		script_name = "";
		break;
	}
	return(script_name);
}

function int check_guild_requirements(obj player, int guild_type) {
	string script_name = get_guild_script(guild_type);
	if (script_name == "") {
		return(0x01);
	}
	list args;
	if (hasScript(player, script_name)) {
		message(player, "checkGuildRequirements", args);
	} else {
		attachScript(player, script_name);
		message(player, "checkGuildRequirements", args);
		detachScript(player, script_name);
	}
	int met_requirements = getObjVar(player, "metGuildRequirements");
	removeObjVar(player, "metGuildRequirements");
	return(met_requirements);
}

function void resign_from_guild(obj player) {
	list args;
	if (!hasObjVar(player, "guildstoneId")) {
		message(player, "removedFromGuild", args);
		return();
	}
	obj guildstone = getObjVar(player, "guildstoneId");
	list info = get_player_name(player);
	if (guildstone == NULL()) {
		message(player, "removedFromGuild", args);
		return();
	}
	multimessage(guildstone, "removeFromGuild", info);
	message(player, "removedFromGuild", args);
	return();
}
