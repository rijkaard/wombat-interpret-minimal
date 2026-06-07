inherits globals;

member obj requester;

member loc where;

member int check_width;

member int check_height;

trigger message("telecheck") {
	requester = args[0x00];
	where = args[0x01];
	check_width = args[0x02];
	check_height = args[0x03];
	callback(this, 0x00, 0x86);
	int teleport_result = teleport(this, where);
	return(0x01);
}

trigger callback(0x86) {
	int success = 0x00;
	if (getLocation(this) == where) {
		if (canExistAt(where, check_width, check_height) == 0x07) {
			success = 0x01;
		}
	}
	list reply;
	if (success) {
		appendToList(reply, 0x01);
	} else {
		appendToList(reply, 0x00);
	}
	appendToList(reply, where);
	multimessage(requester, "telereply", reply);
	deleteObject(this);
	return(0x01);
}
