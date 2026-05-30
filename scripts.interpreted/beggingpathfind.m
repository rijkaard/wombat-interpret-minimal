inherits globals;

trigger creation {

member obj victim = getObjVar(this, "beggingVictim");
	removeObjVar(this, "beggingVictim");

member obj beggar = getObjVar(this, "beggingBeggar");
	removeObjVar(this, "beggingBeggar");
	return(0x00);
}

function void resolve_begging(obj beggar, obj victim) {
	removeObjVar(this, "beggingVictim");
	removeObjVar(this, "beggingBeggar");
	int amt = getMoney(victim) / 0x0A;
	if (amt > 0x0A) {
		amt = 0x0A;
	}
	if (!getCompileFlag(0x01)) {
		amt = amt + (getNotoriety(beggar) / 0x0A);
	} else {
		int mod = amt + getAdjKarma(beggar) / 0x07D0;
		amt = amt + mod;
	}
	if (amt < 0x01) {
		bark(victim, "Thou dost not look trustworthy... no gold for thee today!");
		return();
	}
	if (amt > getMoney(victim)) {
		bark(victim, "I have not enough money to give thee any!");
		return();
	}
	obj gold = transferGenericToContainer(this, victim, 0x0EED, amt);
	if (gold == NULL()) {
		bark(victim, "I have not enough money to give thee any!");
		return();
	}
	obj given = giveItem(beggar, gold);
	if (given == NULL()) {
		bark(victim, "I have not enough money to give thee any!");
		return();
	}
	string msg = "Here, have ");
	string amt_str = amt;
	concat(msg, amt_str);
	concat(msg, " gold coin");
	if (amt > 0x01) {
		concat(msg, "s.");
	} else {
		concat(msg, ".");
	}
	toUpper(msg, 0x00, 0x01);
	bark(beggar, msg);
	if (given == NULL()) {
		int bar = teleport(gold, getLocation(beggar));
	}
	detachScript(this, "beggingpathfind");
	return();
}

trigger pathfound(0x12) {
	bark(this, "Let me see...");
	resolve_begging(this, victim);
	return(0x00);
}

trigger pathnotfound(0x12) {
	bark(this, "I dare not approach thee too closely, lest others think me an easy mark...");
	resolve_begging(this, victim);
	return(0x00);
}
