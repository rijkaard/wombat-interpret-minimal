inherits human;

trigger message("armageddon") {
	int quest_level = args[0x00];
	if (quest_level >= 0x02) {
		return(0x00);
	}
	return(0x01);
}

trigger creation {
	loc job_loc = getLocation(this);
	setObjVar(this, "myJobLocation", job_loc);
	setLoiterMode(this, 0x01);
	goLoiter(this, job_loc, 0x03E8);
	return(0x01);
}

trigger time("hour:**") {
	if (hasObjVar(this, "myJobLocation")) {
		loc place = getObjVar(this, "myJobLocation");
		walkTo(this, place, 0x06);
		setLoiterMode(this, 0x01);
		goLoiter(this, place, 0x03E8);
		return(0x01);
	}
	return(0x01);
}

trigger speech("*") {
	string word;
	list words;
	int i;
	int cmd = 0x00;
	int withdraw = 0x01;
	int amount_idx = 0x00;
	int amount = 0x00;
	int balance = 0x02;
	int bank_cmd = 0x03;
	obj tmp_obj;
	string phrases;
	obj spare_obj;
	if (speaker == this) {
		return(0x00);
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	if (getDistanceInTiles(getLocation(speaker), getLocation(this)) > 0x08) {
		return(0x01);
	}
	split(words, arg);
	for (i = 0x00; i < numInList(words); i++) {
		word = words[i];
		if (word == "withdraw" || (word == "withdrawal")) {
			cmd = withdraw;
			amount_idx = i + 0x01;
		}
		if (word == "balance" || (word == "statement")) {
			cmd = balance;
		}
		if (word == "bank") {
			cmd = bank_cmd;
		}
	}
	if (!cmd) {
		return(0x01);
	}
	if (amount_idx > (numInList(words) - 0x01)) {
		return(0x01);
	}
	if (cmd == withdraw) {
		word = words[amount_idx];
		amount = word;
		if (amount < 0x01) {
			bark(this, "Thou must tell me how much thou wishest to withdraw.");
			return(0x00);
		}
		if (amount > amtGoldInBank(speaker)) {
			bark(this, "Ah, art thou trying to fool me? Thou hast not so much gold!");
			amount = amtGoldInBank(speaker);
		}
		if (amount > 0xEA60) {
			bark(this, "Thou canst not withdraw so much at one time!");
			return(0x00);
		}
		if (!withdrawFromBank(speaker, amount)) {
			bark(this, "Thou dost not have sufficient funds in thy account to withdraw that much.");
			return(0x00);
		}
		word = words[amount_idx];
		phrases = "Thou hast withdrawn " + word + " gold from thy account.";
		bark(this, phrases);
		return(0x00);
	}
	if (cmd == balance) {
		phrases = "Thy current bank balance is " + amtGoldInBank(speaker) + " gold.";
		bark(this, phrases);
		return(0x00);
	}
	if (cmd == bank_cmd) {
		openBank(speaker);
		return(0x00);
	}
	return(0x01);
}

trigger give {
	string phrases;
	string amount_str;
	int result = 0x00;
	int qty = 0x00;
	result = getResource(qty, givenobj, "gold", 0x03, 0x02);
	if (!result) {
		bark(this, "This is not gold!");
		return(0x00);
	}
	result = getObjType(givenobj);
	if (result < 0x0EED || (result > 0x0EEF)) {
		bark(this, "I only accept gold coins.");
		return(0x00);
	}
	int prev_balance = amtGoldInBank(giver);
	result = depositIntoBank(giver, givenobj, qty);
	if (result == (0x00 - 0x01)) {
		amount_str = qty;
		phrases = "Thou hast deposited " + amount_str + " gold.");
		bark(this, phrases);
		return(0x00);
	}
	if (result == 0x01) {
	}
	if (result == 0x02) {
	}
	return(0x01);
}
