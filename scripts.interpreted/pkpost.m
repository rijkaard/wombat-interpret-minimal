function obj find_pk_post(obj bboard) {
	list contents;
	getContents(contents, bboard);
	int count = numInList(contents);
	for (int i = 0x00; i < count; i++) {
		obj item = contents[i];
		if (getObjType(item) == 0x0EB0) {
			if (hasObjVar(item, "isPkMsg")) {
				return(item);
			}
		}
	}
	return(NULL());
}

trigger pkpost {
	setObjVar(killee, "bountyKiller", killer);
	attachScript(killee, "bounty");
	obj board = findClosestBBoard(getLocation(this));
	if (board == NULL()) {
		return(0x00);
	}
	obj post = find_pk_post(board);
	if (post == NULL()) {
		post = createNoResObjectIn(0x0EB0, board);
		if (post == NULL()) {
			return(0x00);
		}
		setObjVar(post, "isPkMsg", 0x04);
	} else {
		int pk_msg_flag = getObjVar(post, "isPkMsg");
		if (pk_msg_flag != 0x04) {
			removeObjVar(post, "postText");
			removeObjVar(post, "lineTimes");
			setObjVar(post, "isPkMsg", 0x04);
		}
	}
	setPostTime(post);
	list postText;
	list lineTimes;
	if (hasObjListVar(post, "postText")) {
		getObjListVar(postText, post, "postText");
	}
	if (hasObjListVar(post, "lineTimes")) {
		getObjListVar(lineTimes, post, "lineTimes");
	}
	string title;
	if (numInList(postText) == 0x00) {
		append(postText, title);
	}
	title = "Recent Killings";
	setItem(postText, title, 0x00);
	int now = getTimeSecs();
	while (numInList(lineTimes) >= 0x0F) {
		removeItem(lineTimes, 0x01);
		removeItem(postText, 0x01);
		removeItem(postText, 0x01);
		removeItem(postText, 0x01);
		removeItem(postText, 0x01);
	}
	for (int i = 0x00; i < numInList(lineTimes); i++) {
		int age = now - (lineTimes[i]);
		if (age > 0x0708) {
			removeItem(lineTimes, i);
			removeItem(postText, i * 0x04 + 0x01);
			removeItem(postText, i * 0x04 + 0x01);
			removeItem(postText, i * 0x04 + 0x01);
			removeItem(postText, i * 0x04 + 0x01);
			i--;
		}
	}
	append(lineTimes, now);
	append(postText, getTitledName(killer));
	append(postText, "  killed  ");
	append(postText, getTitledName(killee));
	append(postText, "");
	setObjVar(post, "lineTimes", lineTimes);
	setObjVar(post, "postText", postText);
	return(0x00);
}
