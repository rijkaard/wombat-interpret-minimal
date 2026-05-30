inherits globals;

trigger use {
	targetObj(user, this);
	return(0x00);
}

function void dump_resource_type(obj m_target, int res_type) {
	list res_names;
	int res_count;
	int count;
	string res_name;
	string val0;
	string val1;
	string val2;
	string val3;
	int res_val;
	string msg = "Type ";
	string type_str = res_type;
	msg = msg + type_str;
	msg = msg + ":";
	bark(m_target, msg);
	int ok = getResourcesOnObj(m_target, res_type, res_names);
	if (ok == 0x00) {
		bark(m_target, "error");
		return();
	}
	res_count = numInList(res_names);
	for (count = 0x00; count < res_count; count++) {
		res_name = res_names[count];
		ok = getResource(res_val, m_target, res_name, res_type, 0x00);
		if (ok == 0x00) {
			val0 = "error";
		} else {
			val0 = res_val;
		}
		ok = getResource(res_val, m_target, res_name, res_type, 0x01);
		if (ok == 0x00) {
			val1 = "error";
		} else {
			val1 = res_val;
		}
		ok = getResource(res_val, m_target, res_name, res_type, 0x02);
		if (ok == 0x00) {
			val2 = "error";
		} else {
			val2 = res_val;
		}
		ok = getResource(res_val, m_target, res_name, res_type, 0x03);
		if (ok == 0x00) {
			val3 = "error";
		} else {
			val3 = res_val;
		}
		msg = res_name;
		msg = msg + " ";
		msg = msg + val0;
		msg = msg + " ";
		msg = msg + val1;
		msg = msg + " ";
		msg = msg + val2;
		msg = msg + " ";
		msg = msg + val3;
		bark(m_target, msg);
	}
	return();
}

trigger targetobj {
	dump_resource_type(usedon, 0x00);
	dump_resource_type(usedon, 0x01);
	dump_resource_type(usedon, 0x02);
	dump_resource_type(usedon, 0x03);
	return(0x00);
}
