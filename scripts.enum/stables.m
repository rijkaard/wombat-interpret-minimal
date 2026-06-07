inherits globals;

forward void handle_stable_request(obj , obj );

forward void claim_pets(obj , obj );

function void respawn_self() {
	obj new_npc = createGlobalNPCAtSpecificLoc(getTemplate(this), getLocation(this));
	if (!isValid(new_npc)) {
		return();
	}
	copyAllObjVars(new_npc, this);
	list contents;
	getContents(contents, this);
	debugMessage("Items found:" + numInList(contents));
	for (int i = numInList(contents) - 0x01; i >= 0x00; i--) {
		debugMessage(getName(contents[0x00]) + "(" + i + ")");
		int rc;
		if (isMobile(contents[0x00])) {
			rc = putMobContainer(contents[0x00], new_npc);
		} else {
			rc = putObjContainer(contents[0x00], new_npc);
		}
		removeItem(contents, 0x00);
	}
	return();
}

function int handle_armageddon(int stage) {
	debugMessage("Armageddon! (Stables)");
	if (stage < 0x02) {
		return(0x01);
	}
	respawn_self();
	return(0x01);
}

trigger message("armageddon") {
	return(handle_armageddon(args[0x00]));
}

trigger message("stablescleanup") {
	deleteObject(this);
	return(0x01);
}

function int obj_list_var_contains(obj m_target, string var_name, obj list_member) {
	if (!hasObjListVar(m_target, var_name)) {
		return(0x00);
	}
	list items;
	getObjListVar(items, m_target, var_name);
	return(isInList(items, list_member));
}

trigger speech("*") {
	if (hasObjListVar(speaker, "petsStoredInStables")) {
		removeObjVar(speaker, "petsStoredInStables");
	}
	list words;
	split(words, arg);
	if (isInList(words, "stable")) {
		handle_stable_request(this, speaker);
		return(0x00);
	}
	if (isInList(words, "claim")) {
		claim_pets(this, speaker);
		return(0x00);
	}
	return(0x01);
}

function void handle_stable_request(obj this, obj speaker) {
	if (getMoney(speaker) < 0x1E) {
		if (amtGoldInBank(speaker) < 0x1E) {
			bark(this, "Thou dost not have 30 gold, not even in thy bank account.");
			return();
		}
	}
	list stabled_animals;
	getContents(stabled_animals, this);
	if (numInList(stabled_animals) > 0x64) {
		bark(this, "I am sorry, my stables are full.");
		return();
	}
	bark(this, "I charge 30 gold per pet for a real week's stable time. I will withdraw it from thy bank account. Which animal wouldst thou like to stable here?");
	setObjVar(this, "petStablerAsker", speaker);
	targetObj(speaker, this);
	return();
}

function void claim_pets(obj this, obj speaker) {
	int result;
	list contents;
	getContents(contents, this);
	if (numInList(contents) < 0x01) {
		bark(this, "But I have no animals stabled with me at the moment!");
		return();
	}
	obj pet;
	list pet_list;
	obj current_pet;
	string response;
	for (int i = 0x00; i < numInList(contents); i++) {
		current_pet = contents[i];
		if (obj_list_var_contains(current_pet, "myBoss", speaker)) {
			response = response + "I have thy pet, " + getName(current_pet) + "... let me fetch it. ";
			result = teleport(current_pet, getLocation(speaker));
			removeObjVar(current_pet, "isInStables");
			detachScript(current_pet, "petzap");
			if (!result) {
				response = response + "I am sorry to inform thee that... well... it died. ";
				deleteObject(current_pet);
			}
		}
	}
	bark(this, response);
	return();
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (isHuman(usedon)) {
		bark(this, "HA HA HA! Sorry, I am not an inn.");
		return(0x00);
	}
	if (hasScript(usedon, "destcrea")) {
		bark(this, "I can not stable summoned creatures.");
		return(0x00);
	}
	if (!hasObjVar(usedon, "myLoyalty")) {
		bark(this, "That's not tame to anyone!");
		return(0x00);
	}
	if (!hasObjListVar(usedon, "myBoss")) {
		bark(this, "That's not tame to anyone!");
		return(0x00);
	}
	if (!obj_list_var_contains(usedon, "myBoss", user)) {
		bark(this, "That's not your pet!");
		return(0x00);
	}
	if (getMoney(user) < 0x1E) {
		if (!withdrawAndDestroy(user, 0x1E)) {
			bark(this, "But thou hast not the funds in thy bank account!");
			return(0x00);
		}
	} else {
		destroyGeneric(user, 0x0EED, 0x1E);
	}
	int success = putMobContainer(usedon, this);
	if (!success) {
		bark(this, "I am sorry, but my stables are full.");
		return(0x00);
	}
	attachScript(usedon, "petzap");
	setObjVar(user, "lastStablemasterUsed", this);
	setObjVar(usedon, "isInStables", 0x01);
	bark(this, "Very well, thy pet is stabled. Thou mayst recover it by saying 'claim' to me. In one real world week, I shall sell it off if it is not claimed!");
	return(0x00);
}
