inherits globals;

function void init_warning(obj it) {
	if (!hasObjVar(it, "warn0")) {
		string default_msg = "unknown warning";
		setObjVar(it, "warn0", default_msg);
	}
	return();
}

trigger creation {
	init_warning(this);
	return(0x01);
}

trigger message("warning") {
	init_warning(this);
	return(0x01);
}

trigger lookedat {
	if ((!isGameMaster(looker)) && (!isCounselor(looker))) {
		return(0x01);
	}
	int header_shown = 0x00;
	int num = 0x00;
	int default_num = 0x01;
	string warn_key;
	string warn_num_key;
	string display_line;
	string warn_text;
	int warn_num = 0x01;
	while (num < 0x0A) {
		warn_key = "warn";
		warn_key = warn_key + num;
		if (hasObjVar(this, warn_key)) {
			warn_num_key = warn_key + "num";
			if (hasObjVar(this, warn_num_key)) {
				warn_num = getObjVar(this, warn_num_key);
			} else {
				warn_num = 0x01;
			}
			warn_text = getObjVar(this, warn_key);
			display_line = warn_num;
			concat(display_line, ": ");
			concat(display_line, warn_text);
			if (!header_shown) {
				header_shown = 0x01;
				barkToHued(this, looker, 0x22, "Warnings: ")}
			barkToHued(this, looker, 0x22, display_line)}
		num++;
	}
	return(0x01);
}
