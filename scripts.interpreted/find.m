member list scan_results;

member int match_count;

function int filter_candidates(list candidates) {
	int count = numInList(candidates);
	if (hasObjVar(this, "findScript")) {
		int pass_count = count;
		count = 0x00;
		string script_name = getObjVar(this, "findScript");
		for (int i = 0x00; i < pass_count; i++) {
			obj candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (hasScript(candidate, script_name)) {
				count++;
				append(candidates, candidate);
			}
		}
	}
	if (hasObjVar(this, "findTemplate")) {
		pass_count = count;
		count = 0x00;
		int template_id = getObjVar(this, "findTemplate");
		for (i = 0x00; i < pass_count; i++) {
			candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (getTemplate(candidate) == template_id) {
				count++;
				append(candidates, candidate);
			}
		}
	}
	if (hasObjVar(this, "findObjVarInt")) {
		pass_count = count;
		count = 0x00;
		string var_name = getObjVar(this, "findObjVarInt");
		int min_val = getObjVar(this, "minValue");
		int max_val = getObjVar(this, "maxValue");
		for (i = 0x00; i < pass_count; i++) {
			candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (hasObjVar(candidate, var_name)) {
				int val = getObjVar(candidate, var_name);
				if ((val >= min_val) && (val <= max_val)) {
					count++;
					append(candidates, candidate);
				}
			}
		}
	}
	if (hasObjVar(this, "findObjVarObj")) {
		pass_count = count;
		count = 0x00;
		var_name = getObjVar(this, "findObjVarObj");
		obj obj_val = getObjVar(this, "objValue");
		for (i = 0x00; i < pass_count; i++) {
			candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (hasObjVar(candidate, var_name)) {
				if (obj_val == getObjVar(candidate, var_name)) {
					count++;
					append(candidates, candidate);
				}
			}
		}
	}
	if (hasObjVar(this, "findFame")) {
		pass_count = count;
		count = 0x00;
		int min_fame = getObjVar(this, "findFame");
		for (i = 0x00; i < pass_count; i++) {
			candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (getFame(candidate) >= min_fame) {
				count++;
				append(candidates, candidate);
			}
		}
	}
	return(count);
}

function void scan() {
	clearList(scan_results);
	if (hasObjVar(this, "findMobiles")) {
		getMobsInRange(scan_results, getLocation(this), 0x1388);
	} else {
		if (hasObjVar(this, "findPlayers")) {
			getPlayersInRange(scan_results, getLocation(this), 0x1388);
		}
	}
	match_count = filter_candidates(scan_results);
	return();
}

trigger use {
	if (!isEditing(user)) {
		systemMessage(user, "This is a GM only tool.");
		return(0x01);
	}
	systemMessage(user, "Enter a search command:");
	textEntry(this, user, 0x029A, 0x00, "Enter a search command:");
	return(0x01);
}

trigger textentry(0x029A) {
	if (!isEditing(sender)) {
		systemMessage(sender, "This is a GM only tool.");
		return(0x00);
	}
	if (text == "scan") {
		scan();
		systemMessage(sender, "" + match_count + " matching mobiles were found.");
		return(0x00);
	}
	int idx = text;
	if ((idx < 0x00) || (idx >= match_count)) {
		systemMessage(sender, "Invalid mobile");
		return(0x00);
	}
	int ok = teleport(sender, getLocation(scan_results[idx]));
	return(0x00);
}
