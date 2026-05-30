inherits globals;

function void clear_bad_person_flag(obj it) {
	if (hasObjVar(it, "badPerson")) {
		removeObjVar(it, "badPerson");
	}
	detachScript(it, "badmessage");
	return();
}

trigger callback(0x87) {
	obj player = NULL();
	if (hasObjVar(this, "badPerson")) {
		systemMessage(this, "What message do you wish to send to the player?");
		textEntry(this, this, 0x19, 0x00, "");
		callback(this, 0x5A, 0x7B);
	} else {
		clear_bad_person_flag(this);
	}
	return(0x01);
}

trigger creation {
	shortcallback(this, 0x00, 0x87);
	return(0x01);
}

trigger textentry(0x19) {
	removeCallback(this, 0x7B);
	if ((button == 0x00) || (text == "") || (sender != this)) {
		clear_bad_person_flag(this);
		return(0x00);
	}
	obj bad_person = getObjVar(this, "badPerson");
	string cmd = "dc tell ";
	concat(cmd, objToStr(bad_person));
	concat(cmd, " GM ");
	concat(cmd, text);
	doSCommand(this, cmd);
	string msg = "Sent: ";
	concat(msg, text);
	systemMessage(this, msg);
	clear_bad_person_flag(this);
	return(0x01);
}

trigger callback(0x7B) {
	systemMessage(this, "Text entry timed out");
	clear_bad_person_flag(this);
	return(0x01);
}
