inherits spelskil;

function string get_magic_name(obj item) {
	string name;
	if (hasObjVar(item, "MagicItemName")) {
		name = getObjVar(item, "MagicItemName");
	} else {
		name = "";
	}
	return(name);
}

function string get_display_name(obj item) {
	string prefix = "";
	string full_name = "";
	int has_magic = 0x00;
	int val = 0x00;
	prefix = getArticle(getObjType(item));
	has_magic = getResource(val, item, "magic", 0x03, 0x02);
	if (has_magic) {
		if (val > 0x00) {
			if (prefix != "") {
				prefix = prefix + " ";
			}
			prefix = prefix + "magic";
		}
	}
	if (prefix != "") {
		prefix = prefix + " ";
	}
	full_name = prefix + getNameByType(getObjType(item));
	return(full_name);
}

function obj find_owner(obj item) {
	obj container;
	obj current = item;
	int first = 0x01;
	while ((first == 0x01) || (isContainer(current))) {
		first = 0x00;
		container = containedBy(current);
		if (container == NULL()) {
			return(NULL());
		}
		if (isPlayer(container)) {
			return(container);
		}
		if (isNPC(container)) {
			return(container);
		}
		current = container;
	}
	return(NULL());
}

function string identify_item(obj user, obj usedon) {
	string name;
	name = get_magic_name(usedon);
	if (name == "") {
		doLookAt(user, usedon);
		return(name);
	} else {
		if (hasObjVar(usedon, "charges")) {
			int charges = getObjVar(usedon, "charges");
			if (charges > 0x00) {
				name = name + " with " + charges + " charges";
			}
		}
		if (!(hasObjVar(usedon, "appraising"))) {
			systemMessage(user, "It is: " + name);
		}
		setObjVar(usedon, "beenIdentified", 0x01);
		setObjVar(usedon, "owner", user);
		setObjVar(usedon, "lookAtText2", name);
		attachScript(usedon, "magicitem");
		removeObjVar(usedon, "appraising");
	}
	return(name);
}
