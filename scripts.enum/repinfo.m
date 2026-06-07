trigger use {
	if (!hasObjVar(this, "usableByPublic")) {
		if (!isEditing(user)) {
			return(0x01);
		}
	}
	systemMessage(user, "Who would you like the status of?");
	targetObj(user, this);
	return(0x00);
}

function void show_list_var(obj user, obj target, string var_name) {
	if (!hasObjVar(target, var_name)) {
		return();
	}
	string msg = var_name + ": ";
	list entries;
	getObjListVar(entries, target, var_name);
	for (int i = 0x00; i < numInList(entries); i++) {
		obj entry = entries[i];
		if (!isValid(entries[i])) {
			concat(msg, "(" + objtoint(entry) + "), ");
		} else {
			concat(msg, getName(entry) + ", ");
		}
	}
	systemMessage(user, msg);
	return();
}

function void show_int_var(obj user, obj target, string var_name) {
	if (!hasObjVar(target, var_name)) {
		return();
	}
	string msg = var_name + ": ";
	int val = getObjVar(target, var_name);
	systemMessage(user, msg + val);
	return();
}

function void show_obj_var(obj user, obj target, string var_name) {
	if (!hasObjVar(target, var_name)) {
		return();
	}
	string msg = var_name + ": ";
	obj obj_val = getObjVar(target, var_name);
	if (!isValid(obj_val)) {
		concat(msg, "(" + objtoint(obj_val) + "), ");
	} else {
		concat(msg, getName(obj_val) + ", ");
	}
	systemMessage(user, msg);
	return();
}

trigger targetobj {
	if (!hasObjVar(this, "usableByPublic")) {
		if (!isEditing(user)) {
			return(0x01);
		}
	}
	if (usedon == NULL()) {
		return(0x00);
	}
	systemMessage(user, "" + getName(usedon) + " has the following flags:");
	show_list_var(user, usedon, "aggressionVictimList");
	show_list_var(user, usedon, "lawfullyDamaged");
	show_list_var(user, usedon, "canReportIdList");
	show_list_var(user, usedon, "crimeVictimList");
	show_int_var(user, usedon, "murderCount");
	show_int_var(user, usedon, "criminal");
	show_obj_var(user, usedon, "controller");
	return(0x00);
}
