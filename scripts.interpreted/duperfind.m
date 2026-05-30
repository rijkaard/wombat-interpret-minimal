inherits sk_table;

member int gold_total;

member int reagent_total;

member int item_total;

forward int check_list_totals(obj it, list items);

function int is_gold(obj item) {
	int type = getObjType(item);
	if (type == 0x0EED) {
		return(0x01);
	}
	return(0x00);
}

function int is_reagent(obj item) {
	int type = getObjType(item);
	if ((type >= 0x0F78) && (type <= 0x0F91)) {
		return(0x01);
	}
	return(0x00);
}

function int is_bolt(obj item) {
	int type = getObjType(item);
	if ((type >= 0x1BE3) && (type <= 0x1BFA)) {
		return(0x01);
	}
	return(0x00);
}

function int check_item_totals(obj item) {
	if (is_reagent(item)) {
		reagent_total = reagent_total + getQuantity(item);
		if (reagent_total > 0x00013880) {
			return(0x01);
		}
	}
	if (is_gold(item)) {
		gold_total = gold_total + getQuantity(item);
		if (gold_total > 0x00061A80) {
			return(0x01);
		}
	}
	if (is_bolt(item)) {
		item_total = item_total + getQuantity(item);
		if (item_total > 0x2710) {
			return(0x01);
		}
	}
	if (isContainer(item)) {
		list contents;
		getContents(contents, item);
		if (check_list_totals(item, contents)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int check_list_totals(obj it, list items) {
	obj item;
	int num = numInList(items);
	for (int i = 0x00; i < num; i++) {
		item = items[i];
		if (check_item_totals(item)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int check_item_duped(obj it) {
	if (isMobile(it)) {
		list equip;
		getEquipment(equip, it);
		obj bank = getItemAtSlot(it, 0x1D);
		if (bank != NULL()) {
			appendToList(equip, bank);
		}
		if (check_list_totals(it, equip)) {
			return(0x01);
		}
	}
	if (isContainer(it)) {
		list contents;
		getContents(contents, it);
		if (check_list_totals(it, contents)) {
			return(0x01);
		}
	}
	if (!isMobile(it)) {
		if (check_item_totals(it)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int has_illegal_stats(obj mobile) {
	int s = getRealStrength(mobile);
	int d = getRealDexterity(mobile);
	int i = getRealIntelligence(mobile);
	int stat_sum = abs(s) + abs(d) + abs(i);
	int str_mod = abs(getStatMod(mobile, 0x00));
	int dex_mod = abs(getStatMod(mobile, 0x01));
	int int_mod = abs(getStatMod(mobile, 0x02));
	int stat_mod_sum = str_mod + dex_mod + int_mod;
	if ((s < 0x00) || (d < 0x00) || (i < 0x00) || (s > 0x69) || (d > 0x69) || (i > 0x69) || (stat_sum > 0xEB)) {
		return(0x01);
	}
	if ((str_mod > 0x0F) || (dex_mod > 0x0F) || (int_mod > 0x0F) || (stat_mod_sum > 0x28)) {
		return(0x01);
	}
	int skill_total = 0x00;
	int skill_mod_total = 0x00;
	for (int skill_idx = 0x00; skill_idx < 0x2E; skill_idx++) {
		int skill_level = getSkillLevelNoStatNoMod(mobile, skill_idx);
		int abs_skill = abs(skill_level);
		int skill_mod = getSkillMod(mobile, skill_idx);
		int abs_mod = abs(skill_mod);
		if ((skill_level < 0x00) || (skill_level > 0x041A) || (abs_mod > 0x012C)) {
			return(0x01);
		}
		skill_total = skill_total + abs_skill;
		skill_mod_total = skill_mod_total + abs_mod;
	}
	if ((skill_total > 0x1BBC) || (skill_mod_total > 0x01F4)) {
		return(0x01);
	}
	return(0x00);
}

trigger creation {
	if ((!isEditing(this)) && (!hasObjVar(this, "checked"))) {
		string reason;
		int flagged;
		if (check_item_duped(this)) {
			flagged = 0x01;
			reason = "autocheck: possible duper";
		}
		if (flagged) {
			if (getGMCallStatus()) {
				addHelpRequestToQueue(this, 0x01, 0x00, reason);
			} else {
				int account_num = getAccountNum(this);
				int char_num = getCharacterNum(this);
				string name = getName(this);
				logEntry(account_num, char_num, this, name, "cheating", "cheater", reason);
			}
		}
	}
	detachScript(this, "duperfind");
	return(0x01);
}
