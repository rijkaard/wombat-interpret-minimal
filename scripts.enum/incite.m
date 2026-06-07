inherits sk_table;

function int is_too_loyal(obj npc) {
	if (!hasObjVar(npc, "myBoss")) {
		return(0x00);
	}
	if (!hasObjVar(npc, "myLoyalty")) {
		return(0x00);
	}
	int loyalty = getObjVar(npc, "myLoyalty");
	if (loyalty < 0x01) {
		return(0x00);
	}
	return(0x01);
}

trigger creation {

member int step = 0x00;

member obj attacker;

member int badSound;

member int goodSound;
	return(0x00);
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "incite");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	if (hasObjVar(this, "lastInstrument")) {
		obj instrument = getObjVar(this, "lastInstrument");
		if (hasObj(this, instrument)) {
			goodSound = getObjVar(instrument, "goodSound");
			badSound = getObjVar(instrument, "badSound");
			systemMessage(this, "Whom do you wish to incite?");
			step = 0x02;
			targetObj(this, this);
			return(0x00);
		}
	}
	systemMessage(this, "What instrument shall you play the music on?");
	step = 0x01;
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x10) {
		return(0x00);
	}
	if (step == 0x01) {
		if (!hasObjVar(usedon, "isInstrument")) {
			systemMessage(user, "That isn't a musical instrument.");
			step = 0x00;
			return(0x00);
		}
		setObjVar(user, "lastInstrument", usedon);
		step = 0x02;
		goodSound = getObjVar(usedon, "goodSound");
		badSound = getObjVar(usedon, "badSound");
		systemMessage(user, "Whom do you wish to incite?");
		targetObj(user, this);
		return(0x00);
	}
	if (step == 0x02) {
		if (!isNPC(usedon)) {
			if (isPlayer(usedon)) {
				barkTo(usedon, user, "Verbal taunts might be more effective!");
				return(0x00);
			}
			barkTo(usedon, user, "You can't incite that!");
			return(0x00);
		}
		if (is_too_loyal(usedon)) {
			bark(this, "They are too loyal to their master to be provoked.");
			return(0x00);
		}
		if (isHuman(usedon)) {
			criminalAct(user, usedon, 0x01, 0x01);
		}
		if (isHuman(usedon)) {
			if (!getCompileFlag(0x01)) {
				removeNotoriety(user, 0x64);
			} else {
				changeKarma(user, 0x00 - 0x1D4C);
			}
			bark(usedon, "Think not that I fail to see what thou art doing!");
			if (getCompileFlag(0x01)) {
				committedCrimeAt(user, getLocation(usedon), 0x01E0);
			} else {
				criminalAct(user, usedon, 0x01, 0x19);
				callGuards(user, getLocation(user), 0x02);
			}
			return(0x00);
		}
		if (isInvulnerable(usedon)) {
			systemMessage(user, getName(usedon) + " isn't listening.");
			return(0x00);
		}
		attacker = usedon;
		step = 0x03;
		sfx(getLocation(user), goodSound, 0x00);
		barkTo(attacker, attacker, "You hear the music and are strangely angered...");
		string msg = "You play your music, inciting anger, and ";
		concat(msg, getHeShe(attacker));
		concat(msg, " begins to look furious. Whom do you wish ");
		concat(msg, getHimHer(attacker));
		concat(msg, " to attack?");
		barkTo(attacker, user, msg);
		targetObj(user, this);
		return(0x00);
	}
	if (step == 0x03) {
		if (!testSkill(user, SKILL_MUSICIANSHIP)) {
			sfx(getLocation(user), badSound, 0x00);
			barkTo(user, user, "You play rather poorly, and to no effect.");
			return(0x00);
		}
		if (!testSkill(user, SKILL_PROVOCATION)) {
			sfx(getLocation(user), badSound, 0x00);
			barkTo(attacker, attacker, "You hear the music and realize that the musician is trying to get you angry...!");
			barkTo(attacker, user, "Your music fails to incite enough anger.");
			if (!getCompileFlag(0x01)) {
				callGuards(user, getLocation(user), 0x02);
			}
			if (!isInArea("city", getLocation(user), 0x00)) {
				attack(attacker, user);
			}
			return(0x00);
		}
		if (!getCompileFlag(0x01)) {
			if ((isGuard(usedon)) || (isShopkeeper(usedon))) {
				bark(attacker, "Thou mayst have angered me, but I am not stupid!");
				criminalAct(user, usedon, 0x01, 0x19);
				callGuards(user, getLocation(user), 0x02);
				return(0x00);
			}
		}
		if (isInvulnerable(usedon)) {
			systemMessage(user, getName(usedon) + " isn't listening.");
			return(0x00);
		}
		if (attacker == usedon) {
			systemMessage(user, "You can't tell someone to attack themselves!");
			return(0x00);
		}
		if (getCompileFlag(0x01)) {
			int notoriety_loss = 0x00;
			if (!canBeFreelyAggressedBy(usedon, user)) {
				notoriety_loss = 0x03E8;
			}
			if (!canBeFreelyAggressedBy(attacker, user)) {
				committedCrimeAt(user, getLocation(usedon), 0x01E0);
				notoriety_loss = 0x03E8;
			}
			int witness_result = witnessCrime(getLocation(attacker), user, usedon, getName(attacker), 0x03E8, notoriety_loss, 0x03);
		}
		barkTo(attacker, attacker, "Your anger coalesces into hatred, and you move to attack!");
		barkTo(attacker, user, "Your music succeeds, as you start a fight.");
		if (getCompileFlag(0x01)) {
			copyControllerInfo(attacker, user);
			setObjVar(attacker, "controllerTimeout", 0x02 * 0x3C * 0x04);
			callbackAdvanced(attacker, 0x02 * 0x3C * 0x04, TIMER_EVENT_CTRL_TIMEOUT, 0x00);
			if (canBeFreelyAggressedBy(usedon, user)) {
				setObjVar(attacker, "defensive", 0x01);
			}
		} else {
			if (isHuman(usedon)) {
				criminalAct(user, usedon, 0x01, 0x0A);
			}
		}
		attack(attacker, usedon);
		if (!getCompileFlag(0x01)) {
			list nearby_mobs;
			obj witness;
			getMobsInRange(nearby_mobs, getLocation(user), 0x0C);
			int had_witness = 0x00;
			for (int i = 0x00; i < numInList(nearby_mobs); i++) {
				witness = nearby_mobs[i];
				if (canSeeObj(witness, user)) {
					if (witness != user) {
						if (witness != attacker) {
							if (witness != usedon) {
								if (isHuman(witness)) {
									had_witness = 0x01;
									bark(witness, "Guards! Help!");
								}
							}
						}
					}
				}
			}
			if (had_witness) {
				callGuards(user, getLocation(user), 0x02);
			}
		}
		step = 0x00;
		return(0x00);
	}
	return(0x00);
}
