inherits globals;

function void record_stat_fix(obj m_target) {
	int num = 0x00;
	if (hasObjVar(m_target, "fixStats")) {
		num = getObjVar(m_target, "fixStats");
	}
	num++;
	setObjVar(m_target, "fixStats", num);
	return();
}

function int reset_stat_mods(obj m_target) {
	int mod;
	int real_val;
	int max_val;
	int result;
	int changed = 0x00;
	for (int i = 0x00; i < 0x03; i++) {
		mod = getStatMod(m_target, i);
		if (mod != 0x00) {
			result = setStatMod(m_target, i, 0x00);
			changed = 0x01;
		}
		real_val = getRealStat(m_target, i);
		max_val = getStatAttributeMax(m_target, i);
		if (real_val != max_val) {
			result = setStatAttributeMax(m_target, i, real_val);
			changed = 0x01;
		}
	}
	return(changed);
}

function int fixStats(obj mob) {
	list equipped;
	loc mob_loc = getLocation(mob);
	int slot;
	obj item;
	int discard;
	int fixed;
	for (slot = 0x01; slot < 0x1A; slot++) {
		item = getItemAtSlot(mob, slot);
		append(equipped, item);
		if (item != NULL()) {
			discard = teleport(item, mob_loc);
		}
	}
	fixed = reset_stat_mods(mob);
	int count = numInList(equipped) + 0x01;
	for (slot = 0x01; slot < count; slot++) {
		item = equipped[slot - 0x01];
		if (item != NULL()) {
			discard = equipObj(item, mob, slot);
		}
	}
	setNaturalAC(mob, 0x00);
	return(fixed);
}

function void fix_and_detach(obj it) {
	if (fixStats(it)) {
		bark(it, "Stat(s) fixed");
		record_stat_fix(it);
	}
	detachScript(it, "statfix");
	return();
}

function int is_allowed_script(string script_name) {
	if (script_name == "bounty") {
		return(0x01);
	}
	if (script_name == "giftbag") {
		return(0x01);
	}
	if (script_name == "statfix") {
		return(0x01);
	}
	if (script_name == "amnesty3") {
		return(0x01);
	}
	if (script_name == "amnesty4") {
		return(0x01);
	}
	if (script_name == "guarded") {
		return(0x01);
	}
	if (script_name == "counokay") {
		return(0x01);
	}
	if (script_name == "info") {
		return(0x01);
	}
	return(0x00);
}

function int has_only_recognized_scripts(obj it) {
	list scripts;
	getScripts(scripts, it);
	int num = numInList(scripts);
	string script_name;
	for (int i = 0x00; i < num; i++) {
		script_name = scripts[i];
		if (!is_allowed_script(script_name)) {
			return(0x00);
		}
	}
	return(0x01);
}

function void check_and_fix_stats(obj it) {
	if (has_only_recognized_scripts(it)) {
		fix_and_detach(it);
	} else {
		callback(it, random(0x1E, 0x3C), 0x77);
	}
	return();
}

trigger creation {
	check_and_fix_stats(this);
	return(0x01);
}

trigger callback(0x77) {
	check_and_fix_stats(this);
	return(0x01);
}
