trigger message("activate") {
	int sum = 0x00;
	int targetVal;
	if (hasObjVar(this, "targetVal")) {
		targetVal = getobjvar_int(this, "targetVal");
	} else {
		bark(this, "Must have a target value!");
	}
	int val;
	for (int i = 0x00; i < 0x08; i++) {
		string c;
		assignstrint(c, i);
		string s = "val" + c;
		if (hasObjVar(this, s)) {
			val = getobjvar_int(this, s);
			sum = sum + val;
		}
	}
	if (sum == targetVal) {
		processTriggerCmds(this, "a");
	} else {
		processTriggerCmds(this, "d");
	}
	return(0x00);
}
