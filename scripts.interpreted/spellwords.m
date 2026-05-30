inherits spelskil;

function void clear_cast_timeout(obj user) {
	removeCallback(user, 0x89);
	return();
}

function void detach_spellwords(obj it) {
	if (hasScript(it, "spellwords")) {
		detachScript(it, "spellwords");
	}
	return();
}

trigger message("spellstartcast") {
	callback(this, 0x05, 0x89);
	return(0x01);
}

trigger message("spellcanstartcast") {
	return(0x00);
}

trigger speech("*") {
	list args;
	split(args, arg);
	if (numInList(args) == 0x03) {
		string word1 = args[0x00];
		string word2 = args[0x01];
		string word3 = args[0x02];
		if ((word1 == "Kal") && (word2 == "Corp") && (word3 == "Xen")) {
			clear_cast_timeout(this);
			attachScript(speaker, "sumdead");
			list cast_args;
			appendToList(cast_args, this);
			appendToList(cast_args, speaker);
			message(speaker, "startcasting", cast_args);
		}
	}
	return(0x01);
}

trigger callback(0x89) {
	detach_spellwords(this);
	return(0x01);
}
