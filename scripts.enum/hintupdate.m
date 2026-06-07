inherits identify;

function void hintupdate(int hint_type, obj item) {
	obj item_obj = item;
	int magic_val = 0x00;
	string description = "";
	string magic_name = "";
	loc location;
	obj owner = NULL();
	string owner_name = "";
	int flags = 0x00;
	int unused;
	int val = 0x00;
	string article;
	article = getArticle(getObjType(item));
	if (getResource(val, item, "magic", 0x03, 0x02)) {
		magic_val = val;
	}
	description = get_display_name(item);
	magic_name = get_magic_name(item);
	location = getLocation(item);
	owner = find_owner(item);
	if (owner != NULL()) {
		owner_name = getName(owner);
	}
	updateHint(hint_type, item_obj, magic_val, description, magic_name, location, owner, owner_name, flags);
	return;
}
