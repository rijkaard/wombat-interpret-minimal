inherits globals;

member list crier_list;

trigger message("towncrieradd") {
	obj it = args[0x00];
	if (!isInList(crier_list, it)) {
		appendToList(crier_list, it);
	}
	return(0x01);
}

trigger message("towncrierremove") {
	obj it = args[0x00];
	if (isInList(crier_list, it)) {
		removeSpecificItem(crier_list, it);
	}
	return(0x01);
}

function void broadcast_to_criers(string msg_key, list args) {
	int num = numInList(crier_list);
	for (int i = 0x00; i < num; i++) {
		obj it = crier_list[i];
		multiMessage(it, msg_key, args);
	}
	return();
}

trigger message("towncrieraddmessage") {
	broadcast_to_criers("towncrieraddmessage", args);
	return(0x01);
}

trigger message("towncrierremovemessage") {
	broadcast_to_criers("towncrierremovemessage", args);
	return(0x01);
}

trigger decay {
	return(0x00);
}
