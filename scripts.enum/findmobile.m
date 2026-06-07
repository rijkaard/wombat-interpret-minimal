member list scan_results;

member int match_count;

function int filter_candidates(list candidates) {
	int count = numInList(candidates);
	if (hasObjVar(this, "findScript")) {
		int total = count;
		count = 0x00;
		string script_name = getObjVar(this, "findScript");
		for (int i = 0x00; i < total; i++) {
			obj candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (hasScript(candidate, script_name)) {
				count++;
				append(candidates, candidate);
			}
		}
	}
	if (hasObjVar(this, "findTemplate")) {
		total = count;
		count = 0x00;
		int template_id = getObjVar(this, "findTemplate");
		for (i = 0x00; i < total; i++) {
			candidate = candidates[0x00];
			removeItem(candidates, 0x00);
			if (getTemplate(candidate) == template_id) {
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
		getMobsInRange(scan_results, getLocation(this), 0x01F4);
	} else {
		if (hasObjVar(this, "findPlayers")) {
			getPlayersInRange(scan_results, getLocation(this), 0x01F4);
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
	int result = teleport(sender, getLocation(scan_results[idx]));
	return(0x00);
}
