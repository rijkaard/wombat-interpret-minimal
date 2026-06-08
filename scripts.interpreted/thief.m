trigger creation {
	int role = random(0x01, 0x05);
	if (role == 0x01) {
		addFragment(this, "Britannia_Actor");
		return(0x00);
	}
	if (role == 0x02) {
		addFragment(this, "Britannia_Beggar");
		return(0x00);
	}
	if (role == 0x03) {
		addFragment(this, "Britannia_Gypsy");
		return(0x00);
	}
	if (role == 0x04) {
		addFragment(this, "Britannia_Artist");
		return(0x00);
	}
	if (role == 0x05) {
		addFragment(this, "Britannia_Laborer");
		return(0x00);
	}
	return(0x00);
}

trigger acquiredesire {
	int guild_rank;
	obj thief;
	if (isPlayer(target)) {
		if (hasObjVar(target, "guildMember")) {
			guild_rank = getObjVar(target, "guildMember");
		}
		if (guild_rank == 0x03) {
			return(0x01);
		} else {
			int total_money = getMoney(target);
			int steal_amt = total_money / 0x14;
			thief = transferGenericToContainer(this, target, 0x0EED, steal_amt);
			barkTo(this, target, "pilfered");
			stopFollowing(this);
			runAway(this, target);
			setCriminal(this, 0x01E0);
		}
	}
	return(0x01);
}
