inherits guildbase;

trigger message("checkGuildRequirements") {
	int met = 0x01;
	if (getFameLevel(this) < 0x03) {
		met = 0x00;
	} else {
		if (isMurderer(this)) {
			met = 0x00;
		}
	}
	setObjVar(this, "metGuildRequirements", met);
	return(0x01);
}

function void removedFromSpecialGuild() {
	obj shield = getItemAtSlot(this, 0x02);
	if (shield != NULL()) {
		list args;
		message(shield, "destroyVirtueShield", args);
	}
	setDefaultReturn(0x01);
	detachScript(this, get_guild_script(get_guild_type()));
	return();
}

trigger message("removedFromGuild") {
	removedFromSpecialGuild();
	return(0x01);
}

trigger message("removedFromSpecialGuild") {
	removedFromSpecialGuild();
	return(0x01);
}

trigger message("addedToSpecialGuild") {
	setObjVar(this"displayGuildAbbr", 0x01);
	return(0x01);
}

trigger famechanged {
	if (getFameLevel(this) < 0x03) {
		systemMessage(this, "You are no longer famous enough to remain in your guild.");
		resign_from_guild(this);
	}
	return(0x01);
}

trigger murdercountchanged {
	if (isMurderer(this)) {
		systemMessage(this, "Murderers aren't allowed in your guild.");
		resign_from_guild(this);
	}
	return(0x01);
}
