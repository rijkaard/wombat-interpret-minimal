inherits globals;

function string get_rumor_text(obj this) {
	obj m_target;
	int hint_id;
	int amount;
	string name;
	string hint_desc;
	loc location;
	obj related;
	string subject;
	int flags;
	int found;
	int loc_result;
	string desc;
	loc region_loc;
	found = getHint(this, 0x03, hint_id, m_target, amount, name, hint_desc, location, related, subject, flags);
	if (found) {
		string result;
		string buf;
		result = "I have heard rumors that ";
		if (subject == "") {
			result = result + name;
			result = result + " is ";
		} else {
			result = result + subject;
			result = result + " has ";
			result = result + name;
		}
		desc = "";
		loc_result = getLocalizedDesc(buf, region_loc, location, getLocation(this));
		loc dest = location;
		if (loc_result > 0x00) {
			if ((loc_result == 0x02) || (loc_result == 0x04)) {
				desc = desc + "here ";
			}
			desc = desc + "in ";
			desc = desc + buf;
			if (loc_result == 0x03) {
				dest = region_loc;
			}
		}
		if (desc != "") {
			result = result + " ";
			result = result + desc;
			result = result + ", ";
		}
		loc my_loc = getLocation(this);
		string dir = getDirection(my_loc, dest);
		result = result + dir;
		result = result + ".";
	} else {
		result = "I have heard no rumors.";
	}
	return(result);
}

function string get_hint_debug_text(obj this) {
	obj m_target;
	int hint_id;
	int amount;
	string name;
	string hint_desc;
	loc location;
	obj related;
	string subject;
	int flags;
	int found;
	int loc_result;
	string desc;
	loc region_loc;
	found = getHint(this, 0x03, hint_id, m_target, amount, name, hint_desc, location, related, subject, flags);
	if (found) {
		string result;
		string buf;
		result = objToStr(m_target);
		result = result + " ";
		buf = amount;
		result = result + buf;
		result = result + " ";
		result = result + name;
		result = result + " ";
		result = result + hint_desc;
		result = result + " ";
		buf = getX(location);
		result = result + buf;
		result = result + " ";
		buf = getY(location);
		result = result + buf;
		result = result + " ";
		buf = getZ(location);
		result = result + buf;
		result = result + " ";
		buf = objToStr(related);
		result = result + buf;
		result = result + " ";
		result = result + subject;
		result = result + " ";
		buf = flags;
		result = result + buf;
		result = result + " ";
		desc = "";
		loc_result = getLocalizedDesc(buf, region_loc, location, getLocation(this));
		if (loc_result > 0x00) {
			if (loc_result == 0x02) {
				desc = desc + "here ";
			}
			desc = desc + "in ";
			desc = desc + buf;
		}
		result = result + "+";
		result = result + desc;
		result = result + "+ ";
		buf = getX(region_loc);
		result = result + buf;
		result = result + " ";
		buf = getY(region_loc);
		result = result + buf;
		result = result + " ";
		buf = getZ(region_loc);
		result = result + buf;
		result = result + " ";
	} else {
		result = "None";
	}
	return(result);
}

trigger speech("*") {
	list args;
	split(args, arg);
	string word;
	string hint;
	int num_args = numInList(args);
	int i;
	for (i = 0x00; i < num_args; i++) {
		word = args[i];
		if (word == "hint") {
			hint = get_rumor_text(this);
			bark(this, hint);
			return(0x01);
		}
		if (word == "hinttest") {
			hint = get_hint_debug_text(this);
			bark(this, hint);
			return(0x01);
		}
	}
	return(0x00);
}
