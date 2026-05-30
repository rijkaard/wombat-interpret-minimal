inherits sk_table;

trigger creation {
	if (0x00) {
		bark(this, "I am now bounty hunted!");
	}
	return(0x01);
}

function int get_kill_count(obj killer) {
	if (!hasObjListVar(killer, "killcount")) {
		return(0x00);
	}
	list kills;
	getObjListVar(kills, killer, "killcount");
	return(numInList(kills));
}

trigger time("hour:12") {
	if (!hasObjListVar(this, "killcount")) {
		return(0x01);
	}
	list kill_list;
	getObjListVar(kill_list, this, "killcount");
	removeObjVar(this, "killcount");
	removeItem(kill_list, 0x01);
	if (numInList(kill_list) > 0x00) {
		setObjVar(this, "killcount", kill_list);
	}
	if (0x00) {
		bark(this, "Reducing bounty count.");
	}
	return(0x01);
}

function void penalize_skills_stats(obj m_target) {
	if (0x00) {
		bark(m_target, "Penalizing stats.");
	}
	for (int i = 0x00; i < 0x2E; i++) {
		loseSkillLevel(m_target, i, (getSkillLevel(m_target, i) / 0x0A));
	}
	int result;
	for (i = 0x00; i < 0x03; i++) {
		result = modifyRealStat(m_target, i, (0x00 - getRealStat(m_target, i) / 0x0A));
	}
	removeObjVar(m_target, "killcount");
	return();
}

trigger death {
	if (!isPlayer(attacker)) {
		return(0x01);
	}
	if (getNotorietyLevel(attacker) < 0x01) {
		if (0x00) {
			bark(this, "Killer must be above neutral to collect bounty.");
		}
		return(0x01);
	}
	if (get_kill_count(attacker) >= get_kill_count(this)) {
		if (0x00) {
			bark(this, "You have a higher killcount than the victim and cannot claim the bounty.");
		}
		return(0x01);
	}
	obj head;
	barkTo(attacker, attacker, "As you kill them, you realize there is a bounty on their head! You take the head as evidence of your victory.");
	head = createGlobalObjectIn(0x1DA0, this);
	string head_name = "the head of " + getName(this);
	setObjVar(head, "lookAtText", head_name);
	if (giveItem(attacker, head) == NULL()) {
		int r = teleport(head, getLocation(attacker));
	}
	setObjVar(head, "bountyObjID", this);
	setObjVar(head, "bountyClaimant", attacker);
	penalize_skills_stats(this);
	shortCallback(this, 0x7F, 0x01);
	return(0x01);
}

trigger callback(0x7F) {
	detachScript(this, "bountymark");
	return(0x01);
}
