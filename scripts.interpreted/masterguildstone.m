inherits globals;

member list guilds;

forward void notify_guilds_updated(list guild_record);

forward void notify_guilds_disbanded(obj guild_ref);

trigger message("sendOtherGuilds") {
	list guild_list;
	appendToList(guild_list, guilds);
	multimessage(sender, "otherGuildsUpdate", guild_list);
	return(0x01);
}

trigger decay {
	return(0x00);
}

trigger message("IAmHere") {
	int i;
	list guild_record;
	obj guild_arg;
	obj existing_guild;
	guild_arg = args[0x00];
	int found = 0x00;
	for (i = 0x00; i < numInList(guilds); i++) {
		existing_guild = oprlist(guilds[i], 0x00);
		if (existing_guild == guild_arg) {
			found = 0x01;
		}
	}
	if (!found) {
		obj guild = args[0x00];
		string name = args[0x01];
		string abbr = args[0x02];
		int type = args[0x03];
		guild_record = guild, name, abbr, type;
		appendToList(guilds, guild_record);
		notify_guilds_updated(guild_record);
	}
	return(0x01);
}

trigger creation {
	setObjVar(this, "lookAtText", "This is the master guild object. Do not delete!");
	return(0x01);
}

trigger objectloaded {
	int guild_count = numInList(guilds);
	for (int i = 0x00; i < guild_count; i = i) {
		if (numInList(oprlist(guilds, i)) < 0x04) {
			removeItem(guilds, i);
			guild_count--;
		} else {
			i++;
		}
	}
	return(0x01);
}

trigger message("newGuild") {
	list guild_record;
	obj guild = args[0x00];
	string name = args[0x01];
	string abbr = args[0x02];
	int type = args[0x03];
	guild_record = guild, name, abbr, type;
	appendToList(guilds, guild_record);
	notify_guilds_updated(guild_record);
	return(0x01);
}

trigger message("deadGuild") {
	list guild_record;
	obj guild_ref = args[0x00];
	int idx;
	int found;
	obj entry_guild;
	for (int i = 0x00; i < numInList(guilds); i++) {
		entry_guild = oprlist(guilds[i], 0x00);
		if (entry_guild == guild_ref) {
			idx = i;
			found = 0x01;
		}
	}
	if (found) {
		removeItem(guilds, idx);
		notify_guilds_disbanded(guild_ref);
	}
	return(0x00);
}

trigger message("requestChangeName") {
	string new_name = args[0x00];
	debugMessage("MGS:name changed to '" + new_name + "'");
	list msg_args;
	obj guild;
	int i;
	int guild_idx;
	string existing_name;
	for (i = 0x00; i < numInList(guilds); i++) {
		guild = oprlist(guilds[i], 0x00);
		if (guild == sender) {
			guild_idx = i;
		}
		existing_name = oprlist(guilds[i], 0x01);
		if (existing_name == new_name) {
			multimessage(sender, "cannotChangeName", msg_args);
			return(0x01);
		}
	}
	list name_args = new_name;
	multimessage(sender, "canChangeName", name_args);
	if (numInList(args) > 0x01) {
		return(0x01);
	}
	existing_name = oprlist(guilds[guild_idx], 0x02);
	list guild_record = sender, new_name, existing_name;
	removeItem(guilds, guild_idx);
	appendToList(guilds, guild_record);
	notify_guilds_updated(guild_record);
	return(0x01);
}

trigger message("doesMyGuildExist") {
	list guild_record;
	obj guild = args[0x00];
	obj m;
	int found;
	for (int i = 0x00; i < numInList(guilds); i++) {
		m = oprlist(guilds[i], 0x00);
		if (m == guild) {
			found = 0x01;
		}
	}
	if (!found) {
		multimessage(sender, "guildGone", args);
	}
	return(0x01);
}

trigger message("requestChangeAbbr") {
	string new_abbr = args[0x00];
	list empty_args;
	obj guild_obj;
	int i;
	int guild_idx;
	string tmp_str;
	for (i = 0x00; i < numInList(guilds); i++) {
		guild_obj = oprlist(guilds[i], 0x00);
		if (guild_obj == sender) {
			guild_idx = i;
		}
		tmp_str = oprlist(guilds[i], 0x02);
		if (tmp_str == new_abbr) {
			multimessage(sender, "cannotChangeAbbr", empty_args);
			return(0x01);
		}
	}
	tmp_str = oprlist(guilds[guild_idx], 0x01);
	list guild_record = sender, tmp_str, new_abbr, 0x00;
	removeItem(guilds, guild_idx);
	appendToList(guilds, guild_record);
	notify_guilds_updated(guild_record);
	list reply_args = new_abbr;
	multimessage(sender, "canChangeAbbr", reply_args);
	return(0x01);
}

function void notify_guilds_updated(list guild_record) {
	list guild_entry;
	obj guild;
	int i;
	for (i = 0x00; i < numInList(guilds); i++) {
		guild = oprlist(guilds[i], 0x00);
		multimessage(guild, "updatedGuildList", guild_record);
	}
	return();
}

function void notify_guilds_disbanded(obj guild_param) {
	list guild_entry;
	obj guild;
	int i;
	list disbanded_args = guild_param;
	for (i = 0x00; i < numInList(guilds); i++) {
		guild = oprlist(guilds[i], 0x00);
		multimessage(guild, "disbanded", disbanded_args);
	}
	return();
}

trigger lookedat {
	int i;
	string name;
	string abbr;
	int type;
	list guild_record;
	obj guild_obj;
	if (!isEditing(looker)) {
		return(0x01);
	}
	systemMessage(looker, "" + numInList(guilds) + " guilds on the shard.");
	bark(this, "Guild list:");
	for (i = 0x00; i < numInList(guilds); i++) {
		name = oprlist(guilds[i], 0x01);
		abbr = oprlist(guilds[i], 0x02);
		guild_obj = oprlist(guilds[i], 0x00);
		type = oprlist(guilds[i], 0x03);
		systemMessage(looker, name + ", [" + abbr + "] ID:" + objtoint(guild_obj) + " Type:" + type);
	}
	return(0x01);
}
