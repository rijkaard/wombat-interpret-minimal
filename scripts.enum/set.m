inherits sk_table;

trigger enterrange(0x00) {
	int target_z = getZ(getLocation(target));
	int base_z = getZ(getLocation(this));
	int gate_height = getHeight(this);
	int top_z = base_z + gate_height;
	int play_age = getPlayAge(target);
	int age_minutes = play_age * 0x08;
	if ((target_z < base_z) || (target_z > top_z)) {
		return(0x01);
	}
	if (hasObjVar(this, "playerOnly")) {
		if (!isPlayer(target)) {
			return(0x00);
		}
	}
	if (!hasObjVar(this, "infiniteUse")) {
		if ((hasObjVar(target, "usedAlready")) || (age_minutes < 0xAA)) {
			barkTo(this, target, "You have already used an advancement gate OR your character has not existed for at least three hours!");
			return(0x01);
		}
		setObjVar(target, "usedAlready", 0x01);
	}
	if (hasObjVar(this, "setTemplate")) {
		becomeTemplate(target, getObjVar(this, "setTemplate"));
	}
	if (hasObjVar(this, "clearSkills")) {
		for (int i = 0x00; i < 0x2E; i++) {
			setSkillLevel(target, i, 0x00);
		}
	}
	for (i = 0x00; i < 0x2E; i++) {
		string var_key = "setSkill" + i;
		if (hasObjVar(this, var_key)) {
			setSkillLevel(target, i, getObjVar(this, var_key));
		}
	}
	for (i = 0x00; i < 0x63; i++) {
		var_key = "putObject" + i;
		if (hasObjVar(this, var_key)) {
			int type_id = getObjVar(this, var_key);
			if (type_id > 0x000186A0) {
				type_id = type_id - 0x000186A0;
				loc there = getLocation(this);
				obj npc = requestCreateNPCAt(type_id, there, 0x32);
				if (npc != NULL()) {
					int ok = putObjContainer(npc, getBackpack(target));
				}
			} else {
				obj item = requestCreateObjectIn(type_id, getBackpack(target));
			}
		} else {
			break;
		}
	}
	int ok2;
	if (hasObjVar(this, "setInt")) {
		ok2 = setRealStat(target, STAT_INT, getObjVar(this, "setInt"));
	}
	if (hasObjVar(this, "setIntMod")) {
		ok2 = setStatMod(target, STAT_INT, getObjVar(this, "setIntMod"));
	}
	if (hasObjVar(this, "setStr")) {
		ok2 = setRealStat(target, STAT_STR, getObjVar(this, "setStr"));
	}
	if (hasObjVar(this, "setStrMod")) {
		ok2 = setStatMod(target, STAT_STR, getObjVar(this, "setStrMod"));
	}
	if (hasObjVar(this, "setDex")) {
		ok2 = setRealStat(target, STAT_DEX, getObjVar(this, "setDex"));
	}
	if (hasObjVar(this, "setDexMod")) {
		ok2 = setStatMod(target, STAT_DEX, getObjVar(this, "setDexMod"));
	}
	if (hasObjVar(this, "setCurHP")) {
		setCurHP(target, getObjVar(this, "setCurHP"));
	}
	if (hasObjVar(this, "setMaxHP")) {
		setMaxHP(target, getObjVar(this, "setMaxHP"));
	}
	if (hasObjVar(this, "setCurFatigue")) {
		setCurFatigue(target, getObjVar(this, "setCurFatigue"));
	}
	if (hasObjVar(this, "setMaxFatigue")) {
		setMaxFatigue(target, getObjVar(this, "setMaxFatigue"));
	}
	if (hasObjVar(this, "setCurMana")) {
		setCurMana(target, getObjVar(this, "setCurMana"));
	}
	if (hasObjVar(this, "setMaxMana")) {
		setMaxMana(target, getObjVar(this, "setMaxMana"));
	}
	if (hasObjVar(this, "setNotoriety")) {
		setNotoriety(target, getObjVar(this, "setNotoriety"));
	}
	if (hasObjVar(this, "setFame")) {
		setFame(target, getObjVar(this, "setFame"));
	}
	if (hasObjVar(this, "setKarma")) {
		setKarma(target, getObjVar(this, "setKarma"));
	}
	if (hasObjVar(this, "setNaturalAC")) {
		setNaturalAC(target, getObjVar(this, "setNaturalAC"));
	}
	if (hasObjVar(this, "setMurderCount")) {
		setMurderCount(target, getObjVar(this, "setMurderCount"));
	}
	if (hasObjVar(this, "setHidden")) {
		setHidden(target, getObjVar(this, "setHidden"));
	}
	if (hasObjVar(this, "setInvisible")) {
		setInvisible(target, getObjVar(this, "setInvisible"));
	}
	if (hasObjVar(this, "setPoisoned")) {
		setPoisoned(target, getObjVar(this, "setPoisoned"));
	}
	if (hasObjVar(this, "setCursed")) {
		setCursed(target, getObjVar(this, "setCursed"));
	}
	if (hasObjVar(this, "setMovementType")) {
		setMovementType(target, getObjVar(this, "setMovementType"));
	}
	if (hasObjVar(this, "setMessage")) {
		systemMessage(target, getObjVar(this, "setMessage"));
	}
	if (hasObjVar(this, "setBark")) {
		bark(this, getObjVar(this, "setBark"));
	}
	doMobAnimation(target, 0x375A, 0x09, 0x0F, 0x00, 0x00);
	return(0x01);
}
