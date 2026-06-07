inherits globals;

trigger enterrange(0x00) {
	if (isPlayer(target)) {
		checkTransferAccount(this, target);
	}
	return(0x01);
}

trigger transaccountcheck {
	string s;
	list server_list;
	list selectList;
	int server_count;
	int i;
	int menu_idx;
	if (transok) {
		if (hasObjVar(this, "servers")) {
			s = getObjVar(this, "servers");
			splitCommaDelimitedString(server_list, s);
			server_count = numInList(server_list) - 0x01;
			if (server_count > 0x00) {
				i = 0x00;
				menu_idx = 0x00;
				while (i < server_count) {
					appendToList(selectList, menu_idx);
					s = server_list[i];
					appendToList(selectList, s);
					menu_idx++;
					i = i + 0x02;
				}
				appendToList(selectList, menu_idx);
				appendToList(selectList, "Don't transfer characters.");
				selectType(target, this, 0x31, "Select a world to which to transfer your characters.", selectList);
				return(0x01);
			}
		}
		systemMessage(target, "This gate is messed up.");
	} else {
		systemMessage(target, "You have already transferred your characters to another world.  This can only be done once.");
	}
	return(0x01);
}

trigger typeselected(0x31) {
	string s;
	list servers;
	if (hasObjVar(this, "servers")) {
		s = getObjVar(this, "servers");
		splitCommaDelimitedString(servers, s);
		if ((listindex > 0x00) && (listindex <= (numInList(servers) / 0x02))) {
			transferPlayer(this, user, servers[(listindex - 0x01) * 0x02 + 0x01]);
		} else {
			systemMessage(user, "Characters not transferred.");
		}
	} else {
		systemMessage(user, "This gate is messed up.");
	}
	return(0x01);
}

trigger transresponse {
	if (transok) {
		systemMessage(target, "Characters transferred.");
	} else {
		systemMessage(target, "Character transfer failed.");
	}
	return(0x01);
}
