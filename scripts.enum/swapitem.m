inherits globals;

function void change_item_type(obj item, int newType) {
	int old_type = getObjType(item);
	string old_script = old_type;
	string new_script = newType;
	if (old_type != newType) {
		setType(item, newType);
		attachScript(item, new_script);
		detachScript(item, old_script);
	}
	return();
}
