inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "forensic");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	systemMessage(this, "Show me the corpse.");
	targetObj(this, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	list users;
	string user_name;
	int obj_type = getObjType(usedon);
	switch(obj_type) {
	case 0x3D67
	case 0x3D68
	case 0x2006
		if (hasObjVar(usedon, "forensicist")) {
			string forensicist = getObjVar(usedon, "forensicist");
			barkTo(user, user, "The forensicist " + forensicist + " has already discovered that:");
		} else {
			if (testAndLearnSkill(user, SKILL_FORENSIC, 0x32, 0x64) <= 0x00) {
				barkTo(user, user, "You cannot determine anything useful.");
				return(0x00);
			}
			setObjVar(usedon, "forensicist", getName(user));
		}
		if (hasObjVar(usedon, "murderer")) {
			string murderer = getObjVar(usedon, "murderer");
			barkTo(user, user, "This person was killed by " + murderer + " .");
		}
		if (hasObjVar(usedon, "users")) {
			getObjListVar(users, usedon, "users");
			int user_count = numInList(users);
			string msg;
			msg = "This body has been disturbed by ";
			for (int i = 0x00; i < user_count; i++) {
				user_name = users[i];
				msg = msg + user_name;
				if (i < (user_count - 0x02)) {
					msg = msg + ", ";
				}
				if (i == (user_count - 0x02)) {
					msg = msg + ", and ";
				}
				if (i == (user_count - 0x01)) {
					msg = msg + ".";
				}
			}
			barkTo(user, user, msg);
		} else {
			barkTo(user, user, "This corpse has not been desecrated.");
		}
		break;
	default
		barkTo(user, user, "Can't use forensic skill on that.");
		break;
	}
	return(0x00);
}
