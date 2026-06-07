function void register_with_parent() {
	obj parent = containedBy(this);
	if (parent == NULL()) {
		return();
	}
	list transmitList;
	clearList(transmitList);
	if (hasObjVar(parent, "transmitList")) {
		getObjListVar(transmitList, parent, "transmitList");
	} else {
		attachScript(parent, "speechrelay");
	}
	prependToList(transmitList, this);
	setObjVar(parent, "transmitList", transmitList);
	return();
}

function void unregister_from_parent() {
	obj parent = containedBy(this);
	if (parent == NULL()) {
		return();
	}
	if (hasObjVar(parent, "transmitList")) {
		list transmitList;
		clearList(transmitList);
		getObjListVar(transmitList, parent, "transmitList");
		removeSpecificItem(transmitList, this);
		if (numInList(transmitList) == 0x00) {
			removeObjVar(parent, "transmitList");
			list f_args;
			message(parent, "removefromparent", f_args);
			detachScript(parent, "speechrelay");
		} else {
			setObjVar(parent, "transmitList", transmitList);
		}
	}
	return();
}

trigger message("removefromparent") {
	unregister_from_parent();
	return(0x01);
}

trigger creation {
	register_with_parent();
	return(0x01);
}

trigger wasdropped {
	register_with_parent();
	return(0x01);
}

trigger wasgotten {
	unregister_from_parent();
	return(0x01);
}

trigger message("speechrelay") {
	debugMessage("(speechrelay):" + getName(this) + ":");
	if (hasObjVar(this, "transmitList")) {
		list transmitList;
		clearList(transmitList);
		getObjListVar(transmitList, this, "transmitList");
		int removed_count = 0x00;
		for (int i = 0x00; i < numInList(transmitList); i++) {
			if (containedBy(transmitList[i]) == this) {
				message(transmitList[i], "speechrelay", args);
			} else {
				removeItem(transmitList, i);
				removed_count++;
				i--;
			}
		}
		if (removed_count) {
			if (numInList(transmitList) == 0x00) {
				unregister_from_parent();
				removeObjVar(this, "transmitList");
				detachScript(this, "speechrelay");
			} else {
				setObjVar(this, "transmitList", transmitList);
			}
		}
		return(0x00);
	}
	message(this, "speechrelayed", args);
	return(0x00);
}

trigger speech("*") {
	list args;
	appendToList(args, speaker);
	appendToList(args, arg);
	message(this, "speechrelay", args)return(0x01);
}
