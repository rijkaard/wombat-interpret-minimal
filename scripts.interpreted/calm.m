inherits sk_table;

trigger creation {

member int goodSound;

member int badSound;
	return(0x01);
}

function void apply_calm(obj user) {
	list players;
	list targets;
	getNPCsInRange(targets, getLocation(user), 0x0C);
	getPlayersInRange(players, getLocation(user), 0x0C);
	int i;
	obj m_target;
	for (i = 0x00; i < numInList(players); i++) {
		m_target = players[i];
		appendToList(targets, m_target);
	}
	if (!testSkill(user, 0x1D)) {
		sfx(getLocation(user), badSound, 0x3C);
		barkTo(user, user, "You play poorly, and there is no effect.");
		return();
	}
	if (!testSkill(user, 0x09)) {
		sfx(getLocation(user), badSound, 0x3C);
		for (i = 0x00; i < numInList(targets); i++) {
			m_target = targets[i];
			if (m_target == user) {
				barkTo(user, user, "You attempt to calm everyone, but fail.");
			} else {
				if (isPlayer(m_target)) {
					if (getCombatMode(m_target)) {
						barkTo(m_target, m_target, "You hear music, and for a moment are distracted.");
					}
				}
			}
		}
		return();
	}
	sfx(getLocation(user), goodSound, 0x3C);
	for (i = 0x00; i < numInList(targets); i++) {
		m_target = targets[i];
		if (m_target == user) {
			systemMessage(user, "You play your hypnotic music, stopping the battle.");
		} else {
			if (isPlayer(m_target)) {
				if (getCombatMode(m_target)) {
					barkTo(m_target, m_target, "You hear lovely music, and forget to continue battling!");
				}
			}
		}
		stopAttack(targets[i]);
	}
	return();
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "calm");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	if (hasObjVar(this, "lastInstrument")) {
		obj instrument = getObjVar(this, "lastInstrument");
		if (hasObj(this, instrument)) {
			goodSound = getObjVar(instrument, "goodSound");
			badSound = getObjVar(instrument, "badSound");
			apply_calm(this);
			return(0x00);
		}
	}
	systemMessage(this, "What instrument shall you play?");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	loc here = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(here, there) > 0x01) {
		systemMessage(user, "That is too far away!");
		return(0x00);
	}
	if (!hasObjVar(usedon, "isInstrument")) {
		systemMessage(user, "That is not a musical instrument.");
		return(0x00);
	}
	badSound = getObjVar(usedon, "badSound");
	goodSound = getObjVar(usedon, "goodSound");
	setObjVar(user, "lastInstrument", usedon);
	apply_calm(user);
	return(0x00);
}
