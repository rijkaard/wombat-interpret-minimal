inherits globals;

member list phrases;

trigger creation {
	clearList(phrases);
	phrases = "The ghostly shadows have...";
	return(0x00);
}

trigger use {
	bark(this, phrases[random(0x00, numInList(phrases) - 0x01)]);
	return(0x00);
}

trigger speech("*") {
	appendToList(phrases, arg);
	if (numInList(phrases) > 0x0A) {
		removeItem(phrases, 0x00);
	}
	return(0x00);
}

trigger message("makeMeTalk") {
	bark(sender, phrases[random(0x00, numInList(phrases) - 0x01)]);
	return(0x00);
}

trigger message("newAddition") {
	string phrase = args[0x00];
	appendToList(phrases, phrase);
	if (numInList(phrases) > 0x00) {
		removeItem(phrases, 0x00);
	}
	return(0x00);
}
