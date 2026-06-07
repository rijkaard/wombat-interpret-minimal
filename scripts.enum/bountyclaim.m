inherits sndfx;

function obj find_bounty_posting(obj guard, obj killer) {
	obj posting;
	obj posted_killer;
	obj board = findClosestBBoard(getLocation(guard));
	list contents;
	int found = 0x00;
	int blah;
	string gold_str;
	int gold;
	getContents(contents, board);
	int count = numInList(contents);
	for (int i = 0x00; i < count; i++) {
		posting = contents[i];
		if (getObjType(posting) == 0x0EB0) {
			if (0x00) {
				blah = getResource(gold, posting, "gold", 0x03, 0x02);
				gold_str = gold;
				bark(guard, "Message has " + gold_str + " gold reward.");
			}
			if (hasObjVar(posting, "killer")) {
				posted_killer = getObjVar(posting, "killer");
				if (killer == posted_killer) {
					if (0x00) {
						bark(guard, "Posting for " + getName(killer) + " found!");
						blah = getResource(gold, posting, "gold", 0x03, 0x02);
						gold_str = gold;
						bark(guard, "Message has " + gold_str + " gold reward.");
					}
					return(posting);
				}
			}
		}
	}
	return(NULL());
}

trigger give {
	if (getObjType(givenobj) != 0x1DA0) {
		return(0x01);
	}
	if (!hasObjVar(givenobj, "bountyObjID")) {
		bark(this, "'Tis a decapitated head. How disgusting.");
		return(0x00);
	}
	if (!hasObjVar(givenobj, "bountyClaimant")) {
		bark(this, "'Tis a decapitated head. How disgusting.");
		return(0x00);
	}
	obj killer = getObjVar(givenobj, "bountyObjID");
	obj claimant = getObjVar(givenobj, "bountyClaimant");
	obj claim = find_bounty_posting(this, killer);
	if (claim == NULL()) {
		bark(this, "There is indeed a price on this head, but not here. Travel on, my friend, to a precinct of the guards that will pay thee.");
		return(0x00);
	}
	if (getNotorietyLevel(giver) < 0x01) {
		bark(this, "We only accept bounty hunting from honorable folk! Away with thee!");
		return(0x00);
	}
	if (giver != claimant) {
		bark(this, "I had heard that this scum was taken care of. But thou didst not do the deed, and thus shall not get the reward!");
		deleteObject(claim);
		return(0x00);
	}
	deleteObject(givenobj);
	int gold_amount;
	string gold_str;
	int blah = getResource(gold_amount, claim, "gold", 0x03, 0x02);
	gold_str = gold_amount;
	obj reward = createNoResObjectAt(0x0EED, getLocation(giver));
	transferResources(reward, claim, gold_amount, "gold");
	if (giveItem(giver, reward) == NULL()) {
		int ok = teleport(reward, getLocation(giver));
	}
	string msg = "The reward is " + gold_amount + " gold pieces. Here you go!");
	bark(this, msg);
	deleteObject(claim);
	sfx(getLocation(giver), 0x35, 0x00);
	return(0x00);
}
