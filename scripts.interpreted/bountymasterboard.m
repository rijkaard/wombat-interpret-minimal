inherits globals;

member list bounty_list;

member list registered_board_list;

trigger decay {
	return(0x00);
}

trigger objectloaded {
	clearList(bounty_list);
	clearList(registered_board_list);
	callback(this, 0x0A, 0x2F);
	return(0x01);
}

function int get_display_start() {
	int count = numInList(bounty_list);
	int start = count - 0x14;
	if (start < 0x00) {
		start = 0x00;
	}
	return(start);
}

function int get_bounty_count() {
	return(numInList(bounty_list));
}

trigger lookedat {
	int start = get_display_start();
	int count = get_bounty_count();
	int max_bounty = 0x00;
	int min_bounty = 0x00;
	if (count > 0x00) {
		max_bounty = oprlist(bounty_list[count - 0x01], 0x01);
		min_bounty = oprlist(bounty_list[start], 0x01);
	}
	barkTo(this, looker, "" + count + " bounties starting at #" + start + " and ranging from " + min_bounty + " to " + max_bounty + " are posted on " + numInList(registered_board_list) + " bounty boards.");
	return(0x00);
}

function void update_boards(int start, int count) {
	if (hasCallback(this, 0x2F)) {
		return();
	}
	for (int board_idx = numInList(registered_board_list) - 0x01; board_idx >= 0x00; board_idx--) {
		list args;
		multiMessage(registered_board_list[board_idx], "clearBounties", args);
		for (int i = count - 0x01; i >= start; i--) {
			debugMessage("updating board#" + board_idx + " with bounty#" + i + ".");
			multiMessage(registered_board_list[board_idx], "setBounty", bounty_list[i]);
		}
	}
	return();
}

trigger callback(0x2F) {
	update_boards(get_display_start(), get_bounty_count());
	return(0x01);
}

trigger message("registerBoard") {
	appendToList(registered_board_list, sender);
	return(0x01);
}

function int addBounty(list args) {
	int bounty = args[0x01];
	int count = numInList(bounty_list);
	for (int i = 0x00; i < count; i++) {
		int cur_bounty = oprlist(bounty_list[i], 0x01);
		if (bounty <= cur_bounty) {
			break;
		}
	}
	if (count >= 0x32) {
		if (i <= 0x00) {
			return(0x00 - 0x01);
		}
		i--;
		removeItem(bounty_list, 0x00);
	}
	insertInList(bounty_list, args, i);
	return(i);
}

trigger message("updateBounty") {
	obj subject = args[0x00];
	int bounty = args[0x01];
	int count = numInList(bounty_list);
	string name = args[0x02];
	debugMessage("Bounty updating:  " + bounty + " gold for " + name + ".");
	for (int i = 0x00; i < count; i++) {
		obj entry_obj = oprlist(bounty_list[i], 0x00);
		if (entry_obj == subject) {
			break;
		}
	}
	int new_idx;
	int start;
	if (i == count) {
		if (bounty == 0x00) {
			return(0x01);
		}
		new_idx = addBounty(args);
		start = get_display_start();
		if (new_idx < start) {
			return(0x01);
		}
		update_boards(start, get_bounty_count());
	} else {
		int old_bounty = oprlist(bounty_list[i], 0x01);
		debugMessage("updating existing bounty from " + old_bounty + " to " + bounty + ".");
		if (old_bounty == bounty) {
			return(0x01);
		}
		removeItem(bounty_list, i);
		if (bounty > 0x00) {
			new_idx = addBounty(args);
			if (i < new_idx) {
				i = new_idx;
			}
		}
		start = get_display_start();
		if (i < start) {
			return(0x01);
		}
		update_boards(start, get_bounty_count());
	}
	return(0x01);
}
