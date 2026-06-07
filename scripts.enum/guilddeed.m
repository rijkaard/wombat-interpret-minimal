inherits housestuff;

trigger creation {

member loc placement_loc = 0x00, 0x00, (0x00 - 0x50);
	setObjVar(this, "lookAtText", "a guild deed");
	return(0x01);
}

trigger use {

member obj m_placer = user;

member obj myHome;
	obj multi;
	if (hasObjVar(m_placer, "guildstoneId")) {
		barkTo(m_placer, m_placer, "You must resign from your current guild before founding another!");
		return(0x00);
	}
	multi = isAnyMultiBelow(getLocation(m_placer));
	myHome = multi;
	if (myHome == NULL()) {
		barkTo(m_placer, m_placer, "You can only place a guildstone in a house or on a ship.");
		return(0x00);
	}
	if (!mobile_owns_house(myHome, m_placer)) {
		barkTo(m_placer, m_placer, "You can only place a guildstone in a house or ship you own!");
		return(0x00);
	}
	if (has_guildstone(myHome)) {
		barkTo(m_placer, m_placer, "Only one guildstone may reside in a given house or ship.");
		return(0x00);
	}

member loc place = getLocation(m_placer);
	systemMessage(m_placer, "Enter the name of your new guild:");
	textEntry(this, m_placer, 0x1B, 0x00, "");
	return(0x00);
}

trigger textentry(0x1B) {
	if (isObscene(text)) {
		barkTo(m_placer, m_placer, "That name is not permissible.");
		return(0x00);
	}
	if (button != 0x00) {
		list msg_args = text, 0x01;
		multiMessageToLoc(placement_loc, "requestChangeName", msg_args);
		return(0x00);
	}
	barkTo(m_placer, m_placer, "Placement of guildstone cancelled.");
	return(0x00);
}

trigger message("cannotChangeName") {
	list arg_list;
	copyList(arg_list, args);
	string msg;
	string name = arg_list[0x01];
	msg = "There is already a guild named " + name + " on this shard.";
	barkTo(m_placer, m_placer, msg);
	return(0x01);
}

trigger message("canChangeName") {
	string name = args[0x00];
	string msg = "A new guild hath been founded, to be called " + name + "!";
	barkTo(m_placer, m_placer, msg);
	obj guild = createNoResObjectAt(0x0ED5, place);
	if (!try_set_guildstone(myHome, guild)) {
		barkTo(m_placer, m_placer, "Only one guildstone may reside in on a given house or ship.");
		deleteObject(guild);
		return(0x00);
	}
	setObjVar(guild, "guildName", name);
	setObjVar(guild, "lookAtText", "The Guildstone for " + name);
	mark_for_multi_delete(guild);
	setObjVar(guild, "myHome", myHome);
	attachScript(guild, "guildstone");
	deleteObject(this);
	return(0x01);
}
