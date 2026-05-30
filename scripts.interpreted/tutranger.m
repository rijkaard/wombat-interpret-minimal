inherits globals;

trigger creation {

member int asked = 0x00;

member int taught = 0x00;
	return(0x01);
}

trigger enterrange(0x04) {
	if (isPlayer(target)) {
		list args = 0x06;
		multimessage(target, "foundme", args)}
	return(0x01);
}

trigger speech("*") {
	if (!isPlayer(speaker)) {
		return(0x01);
	}
	list text;
	string word;
	split(text, arg);
	for (int i = 0x00; i < numInList(text); i++) {
		word = text[i];
		if (((word == "tracking") || (word == "track") || (word == "hunt")) && !taught) {
			bark(this, "You would like to learn tracking, eh?  Are you perchance going after that dragon?");
			asked = 0x01;
			return(0x00);
		}
		if (word == "dragon") {
			if (!taught) {
				bark(this, "What of the dragon, are you on the hunt for it?");
				asked = 0x01;
			} else {
				bark(this, "I am just relieved that the terrible monster will be dead soon.");
			}
			return(0x00);
		}
		if (((word == "no") || (word == "nope") || (word == "n") || (word == "nay")) && !taught) {
			if (asked) {
				bark(this, "That is a shame, the town was hoping someone like you could help us.");
				asked = 0x00;
				return(0x00);
			}
		}
		if (((word == "yes") || (word == "yup") || (word == "y") || (word == "aye")) && !taught) {
			if (asked) {
				list args = 0x06;
				if (getSkillLevel(speaker, 0x26) < 0x3C) {
					bark(this, "Bless thee sir, for that cause I will teach you to track it down for free!");
					systemMessage(speaker, "Your skill level increases.");
					addSkillLevel(speaker, 0x26, (0x64 - getSkillLevel(speaker, 0x26)) * 0x0A);
					multimessage(speaker, "usedme", args);
					taught = 0x01;
				} else {
					multimessage(speaker, "usedme", args);
					bark(this, "I wish I could help you, but there is nothing more I can do to aid you on your quest.");
				}
				return(0x00);
				asked = 0x00;
			}
		}
	}
	asked = 0x00;
	return(0x01);
}
