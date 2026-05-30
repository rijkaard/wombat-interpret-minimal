trigger speech("*") {
	if (speaker == this) {
		list args;
		split(args, arg);
		if (numInList(args) == 0x03) {
			string cmd;
			string stat_arg;
			string idx_arg;
			cmd = args[0x00];
			stat_arg = args[0x01];
			idx_arg = args[0x02];
			int stat_id = stat_arg;
			int idx = idx_arg;
			if ((cmd == "sb") || (cmd == "sbg")) {
				list players;
				int ret = getPlayerBugStat(players, stat_id);
				string msg;
				msg = "not found";
				if (numInList(players) > idx) {
					obj player = players[idx];
					msg = "found ";
					msg = msg + getName(player);
					msg = msg + " ";
					msg = msg + objToStr(player);
					msg = msg + " ";
					msg = msg + getX(getLocation(player));
					msg = msg + " ";
					msg = msg + getY(getLocation(player));
					msg = msg + " ";
					msg = msg + getZ(getLocation(player));
					barkTo(speaker, speaker, msg);
					if (cmd == "sbg") {
						int tele_ok = teleport(this, getLocation(player));
						if (!tele_ok) {
							barkTo(speaker, speaker, "teleport unsuccessful");
						}
					}
				} else {
					barkTo(speaker, speaker, msg);
				}
			}
		}
	}
	return(0x01);
}
