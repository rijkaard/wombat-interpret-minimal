inherits globals;

forward void addMessage(list );

forward void show_messages();

forward int find_message_index(string );

member string pending_message_text;

trigger creation {
	list messages;
	setObjVar(this, "oracleMessages", messages);
	return(0x00);
}

function void addMessage(list msg) {
	list messages;
	getObjListVar(messages, this, "oracleMessages");
	appendToList(messages, msg);
	setObjVar(this, "oracleMessages", messages);
	bark(this, "Message added.");
	return();
}

function void show_messages() {
	list messages;
	getObjListVar(messages, this, "oracleMessages");
	if (numInList(messages) < 0x01) {
		bark(this, "No messages are set.");
		return();
	}
	string keyword;
	string t;
	list entry;
	for (int i = 0x00; i < numInList(messages); i++) {
		copyList(entry, messages[i]);
		keyword = entry[0x00];
		t = entry[0x01];
		bark(this, "'" + t + "', Keyword: '" + keyword + "'.'");
	}
	return();
}

function int find_message_index(string keyword) {
	int idx;
	list a;
	getObjListVar(a, this, "oracleMessages");
	list entry;
	string stored_keyword;
	for (int i = 0x00; i < numInList(a); i++) {
		copyList(entry, a[i]);
		stored_keyword = entry[0x00];
		if (keyword == stored_keyword) {
			return(idx);
		}
	}
	return(0x00 - 0x01);
}

trigger textentry(0x22) {
	pending_message_text = text;
	bark(this, "Adding text '" + pending_message_text + "'.");
	systemMessage(sender, "Enter the keyword that will trigger this response.");
	textEntry(this, sender, 0x24, 0x00, "");
	return(0x00);
}

trigger textentry(0x24) {
	list u = text, pending_message_text;
	addMessage(u);
	return(0x00);
}

trigger textentry(0x23) {
	int idx = find_message_index(text);
	if (idx == (0x00 - 0x01)) {
		systemMessage(sender, "That keyword was not found.");
		return(0x00);
	}
	list a;
	getObjListVar(a, this, "oracleMessages");
	removeItem(a, idx);
	systemMessage(sender, "Oracle string removed.");
	setObjVar(this, "oracleMessages", a);
	return(0x00);
}

trigger use {
	int can_edit = 0x00;
	if (hasObjVar(user, "allowedToEditOracle")) {
		can_edit = 0x01;
	}
	if (isEditing(user)) {
		can_edit = 0x01;
	}
	if (!can_edit) {
		return(0x01);
	}
	list menu;
	appendToList(menu, 0x00);
	appendToList(menu, "View conversation strings.");
	appendToList(menu, 0x01);
	appendToList(menu, "Add a conversation string.");
	appendToList(menu, 0x02);
	appendToList(menu, "Remove a conversation string.");
	appendToList(menu, 0x03);
	appendToList(menu, "Clear all conversation strings.");
	selectType(user, this, 0x3A, "ORACLE CONTROL MENU", menu);
	return(0x00);
}

trigger typeselected(0x3A) {
	if (listindex == 0x00) {
		return(0x00);
	}
	switch(objtype) {
	case 0x00
		show_messages();
		break;
	case 0x01
		systemMessage(user, "Enter the text of the oracle message:");
		textEntry(this, user, 0x22, 0x00, "");
		break;
	case 0x02
		systemMessage(user, "Enter the keyword of the message to remove:");
		textEntry(this, user, 0x23, 0x00, "");
		break;
	case 0x03
		list empty_list;
		setObjVar(this, "oracleMessages", empty_list);
		systemMessage(user, "All oracle messages cleared.");
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int match_keyword_index(list w) {
	list a;
	getObjListVar(a, this, "oracleMessages");
	string keyword;
	string word;
	list entry;
	for (int i = 0x00; i < numInList(w); i++) {
		word = w[i];
		for (int j = 0x00; j < numInList(a); j++) {
			copyList(entry, a[j]);
			keyword = entry[0x00];
			if (keyword == word) {
				return(j);
			}
		}
	}
	return(0xFF);
}

function string get_message_text(int idx) {
	list entry;
	list a;
	getObjListVar(a, this, "oracleMessages");
	copyList(entry, a[idx]);
	string text = entry[0x01];
	return(text);
}

trigger speech("*") {
	if (getDistanceInTiles(getLocation(this), getLocation(speaker)) > 0x04) {
		return(0x01);
	}
	list words;
	split(words, arg);
	int msg_index = match_keyword_index(words);
	if (msg_index != 0xFF) {
		bark(this, get_message_text(msg_index));
		return(0x00);
	}
	return(0x01);
}
