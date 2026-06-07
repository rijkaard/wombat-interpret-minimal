inherits spelskil;

function void show_debug_info(obj usedon, obj user) {
	if (!isEditing(user)) {
		return();
	}
	systemMessage(user, getName(usedon));
	systemMessage(user, "Loc=<" + getLocation(usedon) + ">");
	int num;
	int die_sides;
	int mod;
	int wc_extra;
	if (isContainer(usedon)) {
		int opened = openContainer(user, usedon);
		list contents;
		getContents(contents, usedon);
		systemMessage(user, "# Items contained=" + numInList(contents));
	}
	if (isMobile(usedon)) {
		systemMessage(user, "Notoriety=" + getNotoriety(usedon));
		systemMessage(user, "Fame=" + getFame(usedon));
		systemMessage(user, "Karma=" + getKarma(usedon));
		getWeaponClass(usedon, num, die_sides, mod, wc_extra);
		systemMessage(user, "NaturalWC=" + num + "d" + die_sides + "+" + mod);
		int s;
		int d;
		int i;
		s = getRealStat(usedon, STAT_STR);
		d = getRealStat(usedon, STAT_DEX);
		i = getRealStat(usedon, STAT_INT);
		systemMessage(user, "Stats=" + s + "s " + d + "d " + i + "i  Total=" + (s + d + i));
		s = getStatMod(usedon, STAT_STR);
		d = getStatMod(usedon, STAT_DEX);
		i = getStatMod(usedon, STAT_INT);
		systemMessage(user, "StatMods=" + s + "s " + d + "d " + i + "i  Total=" + (s + d + i));
		systemMessage(user, "Skill Total=" + getSkillTotal(usedon));
		int total_skill_mods = 0x00;
		for (i = 0x00; i < 0x2E; i++) {
			mod = getSkillMod(usedon, i);
			if (mod > 0x00) {
				total_skill_mods = total_skill_mods + mod;
				systemMessage(user, "#" + i + ": " + getSkillName(i) + " mod=" + mod);
			}
		}
		systemMessage(user, "Total skill mods=" + total_skill_mods);
	} else {
		systemMessage(user, "Type=" + getObjType(usedon));
		int hue = getHue(usedon);
		if (hue != 0x00) {
			systemMessage(user, "Hue=" + hue);
		}
	}
	systemMessage(user, "Value=" + getValue(usedon));
	systemMessage(user, "Weight=" + getWeight(usedon));
	if (isWeapon(usedon)) {
		getWeaponClass(usedon, num, die_sides, mod, wc_extra);
		systemMessage(user, "WC=" + num + "d" + die_sides + "+" + mod);
		systemMessage(user, "AC=" + getCurArmorClass(usedon));
		systemMessage(user, "HP=(" + getWeaponCurHP(usedon) + "/" + getWeaponMaxHP(usedon) + ")");
		systemMessage(user, "Speed=" + getWeaponSpeed(usedon));
		systemMessage(user, "Eqpos=" + getEquipSlot(usedon));
		return();
	}
	return();
}

trigger use {
	targetObj(user, this);
	return(0x01);
}

trigger lookedat {
	show_debug_info(this, looker);
	return(0x01);
}

trigger oortargetobj {
	show_debug_info(usedon, user);
	return(0x00);
}
