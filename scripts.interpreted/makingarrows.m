inherits sndfx;

member obj feathers;

member obj shafts;

trigger message("makearrows") {
	feathers = args[0x00];
	shafts = args[0x01];
	list fletching = 0x0F3F, 0x1BFB;
	selectType(this, this, 0x28, "Choose an item to make.", fletching);
	return(0x01);
}

trigger typeselected(0x28) {
	obj backpack = getBackpack(this);
	int feather_count;
	int shaft_count;
	int i;
	int qty;
	int result;
	obj made;
	obj owner = getTopmostContainer(feathers);
	if (isMobile(owner) && (owner != this)) {
		detachScript(this, "makingarrows");
		return(0x00);
	}
	owner = getTopmostContainer(shafts);
	if (isMobile(owner) && (owner != this)) {
		detachScript(this, "makingarrows");
		return(0x00);
	}
	if ((objtype == 0x0F3F) || (objtype == 0x1BFB)) {
		result = getResource(feather_count, feathers, "feathers", 0x03, 0x02);
		result = getResource(shaft_count, shafts, "wood", 0x03, 0x02);
		qty = shaft_count;
		if (qty > feather_count) {
			qty = feather_count;
		}
		made = createNoResObjectIn(objtype, backpack);
		returnResourcesToBank(feathers, qty, "feathers");
		transferResources(made, shafts, qty, "wood");
		result = putObjContainer(made, backpack);
		i = qty;
		if (objtype == 0x0F3F) {
			if (i == 0x01) {
				systemMessage(user, "You make an arrow and put it in your backpack.");
			}
			if (i > 0x01) {
				systemMessage(user, "You make some arrows and put them in your backpack.");
			}
			sfx(getLocation(user), 0x4F, 0x00);
		}
		if (objtype == 0x1BFB) {
			if (i == 0x01) {
				systemMessage(user, "You make a bolt and put it in your backpack.");
			}
			if (i > 0x01) {
				systemMessage(user, "You make some bolts and put them in your backpack.");
			}
			sfx(getLocation(user), 0x4F, 0x00);
		}
	}
	result = getResource(feather_count, feathers, "feathers", 0x03, 0x02);
	result = getResource(shaft_count, shafts, "wood", 0x03, 0x02);
	if (feather_count < 0x01) {
		deleteObject(feathers);
	}
	if (shaft_count < 0x01) {
		deleteObject(shafts);
	}
	detachScript(this, "makingarrows");
	return(0x00);
}
