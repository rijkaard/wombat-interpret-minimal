inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "stealing");
	return(0x00);
}

function int is_unstealable(obj item) {
	if (getObjType(item) == 0x0FA6) {
		return(0x01);
	}
	if (isSpellbook(item)) {
		return(0x01);
	}
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	int num_targets;
	num_targets = getNumTargets(this);
	if (num_targets > 0x00) {
		systemMessage(this, "You cannot attempt to steal in the heat of combat!");
		return(0x00);
	}
	systemMessage(this, "Which item will you attempt to steal?");
	targetObj(this, this);
	return(0x00);
}

trigger oortargetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (isDead(this)) {
		return(0x00);
	}
	obj top_container = getTopmostContainer(usedon);
	int dist = getDistanceInTiles(getLocation(usedon), getLocation(this));
	if (getDistanceInTiles(getLocation(usedon), getLocation(this)) > 0x01) {
		systemMessage(this, "You must be standing next to an item to steal it.");
		return(0x00);
	}
	obj owner = NULL();
	if (top_container == NULL()) {
		if (isMobile(usedon)) {
			owner = usedon;
		}
	} else {
		if (isMobile(top_container)) {
			owner = top_container;
		}
	}
	obj owner_pack;
	if (owner != NULL()) {
		if (owner == this) {
			barkTo(this, this, "You catch yourself red-handed.");
			return(0x00);
		}
		if (isPlayer(owner)) {
			if (isEditing(owner) || isGameMaster(owner) || isCounselor(owner)) {
				systemMessage(this, "You can't steal from this.");
				return(0x00);
			}
		}
		if (hasScript(owner, "vendor")) {
			systemMessage(this, "You can't steal from vendors.");
			return(0x00);
		}
		owner_pack = getBackpack(owner);
		if (owner_pack == NULL()) {
			systemMessage(user, "You can't steal that.");
			return(0x00);
		}
	}
	int steal_mult = 0x01;
	if (owner != NULL()) {
		if (owner == usedon) {
			list pack_contents;
			clearList(pack_contents);
			getContents(pack_contents, owner_pack);
			int count = numInList(pack_contents);
			if (count == 0x00) {
				systemMessage(this, "You reach into " + getName(owner) + "'s backpack... but find it's empty.");
				return(0x00);
			}
			usedon = pack_contents[random(0x00, count - 0x01)];
			systemMessage(this, "You reach into " + getName(owner) + "'s backpack... and try to take something.");
		} else {
			obj cur_container = containedBy(usedon);
			while (cur_container != owner_pack) {
				if (cur_container == NULL()) {
					systemMessage(user, "You can't steal that.");
					return(0x00);
				}
				cur_container = containedBy(cur_container);
			}
			steal_mult = 0x03;
		}
	}
	if (!isMoveable(usedon, this)) {
		systemMessage(this, "You could not carry this item.");
		return(0x00);
	}
	if (!canHold(this, usedon)) {
		systemMessage(this, "You could not carry this item.");
		return(0x00);
	}
	if (getValue(usedon) == 0x00) {
		systemMessage(this, "This item has no value to you.");
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		systemMessage(user, "You can't steal that.");
		return(0x00);
	}
	if (is_unstealable(usedon)) {
		systemMessage(user, "You can't steal that.");
		return(0x00);
	}
	if (containedBy(usedon) != NULL()) {
		if (is_unstealable(usedon)) {
			systemMessage(user, "You can't steal that.");
			return(0x00);
		}
	}
	int weight = getWeight(usedon);
	int quantity = getQuantity(usedon);
	if ((weight > 0x0A) && (quantity <= 0x01) && (owner != NULL())) {
		systemMessage(this, "This item is too heavy to steal from someone's backpack.");
		return(0x00);
	}
	int capped_weight = weight;
	if (capped_weight > 0x0A) {
		capped_weight = 0x0A;
	}
	list tmp;
	int skill_factor = 0x64 + getSkillLevelReal(this, 0x21);
	int steal_chance = capped_weight * steal_mult * 0x1388 / skill_factor;
	int witnessed = witnessCrime(getLocation(usedon), this, owner, getName(usedon), steal_chance, (getValue(usedon) + 0x04) / 0x05, 0x01);
	changeKarma(this, 0x00 - 0x1388);
	if (!getCompileFlag(0x01)) {
		criminalActAdvanced(this, owner, 0x01, 0x06, 0x18 * 0x02, 0x00);
	}
	if (witnessed > 0x00) {
		if (!getCompileFlag(0x01)) {
			setCriminal(this, 0x01E0);
		}
		steal_chance = capped_weight * steal_mult * 0x1E + 0x64;
		if (testAndLearnSkill(this, 0x21, steal_chance, 0x32) <= 0x00) {
			systemMessage(this, "You fail to steal the item.");
			return(0x00);
		}
	}
	systemMessage(this, "You successfully steal the item.");
	if (owner == NULL()) {
		setCriminal(this, 0x01E0);
	} else {
		if (!canBeFreelyAggressedBy(owner, this)) {
			int r = addToObjVarListSet(this, "crimeVictimList", owner);
		}
	}
	int steal_qty = 0x01;
	if (quantity > 0x01) {
		int roll = random(0x01, 0x0A);
		if (roll > weight) {
			steal_qty = quantity;
		} else {
			steal_qty = (quantity * roll) / weight;
			if (steal_qty < 0x01) {
				steal_qty = 0x01;
			}
		}
	}
	obj my_pack = getBackpack(this);
	if (steal_qty < quantity) {
		obj stolen_obj = createNoResObjectIn(getObjType(usedon), my_pack);
		transferGeneric(stolen_obj, usedon, steal_qty);
		return(0x01);
	}
	int r2 = putObjContainer(usedon, my_pack);
	return(0x01);
}
