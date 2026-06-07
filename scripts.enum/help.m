inherits globals;

function void notify_browser_starting(obj player) {
	systemMessageHued(player, 0x35, "Please wait for your web browser to start...");
	return();
}

function void show_problem_prompt(obj player) {
	systemMessageHued(player, 0x35, "Please enter a description of your problem:");
	return();
}

function void show_request_submitted(obj player) {
	systemMessageHued(player, 0x35, "Your help request has been entered.");
	systemMessageHued(player, 0x35, "The next available game master will respond as soon as possible.");
	return();
}

forward void end_help_session(obj player, int cancelled);

forward void submit_help_request(obj player, int call_type, string category, string text);

forward void close_if_invalid(obj player, int num, int category);

forward void schedule_timeout(obj player);

forward void show_main_menu(obj player);

forward void show_tech_billing_menu(obj player);

forward void show_general_help_menu(obj player);

forward void show_tech_support_menu(obj player);

forward void show_phone_support_menu(obj player);

forward void show_email_support_menu(obj player);

forward void show_billing_menu(obj player);

forward void show_gameplay_help_menu(obj player);

forward void show_character_help_menu(obj player);

forward void show_item_problem_menu(obj player);

forward void show_unusable_item_menu(obj player);

forward void show_invisible_item_menu(obj player);

forward void show_skill_help_menu(obj player);

function void end_help_session(obj player, int aborted) {
	if (aborted) {
		systemMessageHued(player, 0x35, "Help request aborted.");
	}
	detachScript(player, "help");
	return();
}

function int check_gm_available(obj it) {
	if (!getGMCallStatus()) {
		systemMessageHued(this, 0x35, "We are sorry, but currently a GM is unavailable to answer your call.  Our in-game support hours are 2:00pm-12:00am CST, although we are monitoring the servers for problems during these off peak times.  Please try again during these times.");
		end_help_session(this, 0x00);
		return(0x00);
	}
	return(0x01);
}

function void increment_call_count(obj player, int priority) {
	if (priority == 0x01) {
		int num = 0x00;
		if (hasObjVar(player, "calls")) {
			num = getObjVar(player, "calls");
		}
		num = num + 0x01;
		setObjVar(player, "calls", num);
	}
	return();
}

function void submit_help_request(obj player, int call_type, string category, string text) {
	string message = category;
	concat(message, ": ");
	string loc_str;
	loc location = getLocation(player);
	loc_str = "(";
	loc_str = loc_str + getX(location);
	concat(loc_str, " ");
	loc_str = loc_str + getY(location);
	concat(loc_str, " ");
	loc_str = loc_str + getZ(location);
	concat(loc_str, ") ");
	concat(message, loc_str);
	concat(message, text);
	addHelpRequestToQueue(player, call_type, 0x00, message);
	increment_call_count(player, call_type);
	return();
}

function void close_if_invalid(obj player, int num, int cancelled) {
	if ((num == 0x00) || (!isValid(player))) {
		end_help_session(this, cancelled);
	}
	return();
}

function void schedule_timeout(obj player) {
	callback(player, 0x78, 0x70);
	return();
}

trigger callback(0x70) {
	end_help_session(this, 0x01);
	return(0x00);
}

trigger creation {
	close_if_invalid(this, 0x01, 0x00);
	schedule_timeout(this);
	show_main_menu(this);
	return(0x01);
}

function void show_main_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "CHARACTER IS PHYSICALLY STUCK:  This type of call can only be handled by a Game Master.  Game Master hours are 2:00pm to 12:00am CST.");
	appendToList(options, 0x01);
	appendToList(options, "ANOTHER PLAYER IS HARASSING ME:  Again, the only way for us to verify this kind of issue directly is for you to call a Game Master.  If the harassment occurs outside of Game Master hours, please send a message to our e-mail support.");
	appendToList(options, 0x02);
	appendToList(options, "CHARACTER CAN NOT CONTINUE: If your character is suffering from an error which is considered drastic and is preventing you from continuing within the game, please page a Game Master during the posted hours or write to our e-mail support.");
	appendToList(options, 0x03);
	appendToList(options, "CONTINUE:  If your choice was not listed here, select this option.");
	appendToList(options, 0x04);
	appendToList(options, "DONE");
	selectType(player, player, 0x64, "Please remember, Game Masters are only available to help with the following types of calls:  character cannot move, you are being harassed, or your character cannot continue.  Please choose the area in which you require assistance from below.", options);
	return();
}

function void show_tech_billing_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "TECHNICAL SUPPORT:  Sound or video problems, client crashes, lag, latency, or other technical issues.  You may try to resolve these issues through our web page trouble-shooter, email, or you may speak to a technical support representative directly.");
	appendToList(options, 0x01);
	appendToList(options, "BILLING ISSUES:  If you cannot log into the game, if you believe your billing statement is in error, or just have general billing questions.");
	appendToList(options, 0x02);
	appendToList(options, "PREVIOUS:  If the option you need was not listed above.");
	appendToList(options, 0x03);
	appendToList(options, "CONTINUE: If the option you need was not listed above, nor on the previous menu.");
	appendToList(options, 0x04);
	appendToList(options, "DONE");
	selectType(player, player, 0x65, "Please select from the following options:", options);
	return();
}

function void show_general_help_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "GENERAL HINTS / GAMEPLAY QUESTIONS:  If you need a hint or just a push in the right direction, select this option.");
	appendToList(options, 0x01);
	appendToList(options, "REQUEST LATEST GAME INFORMATION:  We continuously update all new information regarding Ultima Online, plus any information about upcoming updates on our web page.");
	appendToList(options, 0x02);
	appendToList(options, "BUG SUBMISSION / LOST ITEMS:  You may submit any bugs which have adversely, or even beneficially, affected your character to our web page.");
	appendToList(options, 0x03);
	appendToList(options, "PREVIOUS:  If the option you need was not listed above.");
	appendToList(options, 0x04);
	appendToList(options, "DONE");
	selectType(player, player, 0x66, "Please select from the following options:", options);
	return();
}

function void show_tech_support_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "PHONE SUPPORT:  For information on phone support, choose this option.");
	appendToList(options, 0x01);
	appendToList(options, "E-MAIL SUPPORT:  For information on e-mail technical support, choose this option.");
	appendToList(options, 0x02);
	appendToList(options, "WEB SUPPORT:  Our web page has a full line of technical support issues currently known.  Please visit http://www.owo.com for the complete listing.  Select this option to automatically open your web browser to our support issues.");
	appendToList(options, 0x03);
	appendToList(options, "Select this option to return to the main page.");
	appendToList(options, 0x04);
	appendToList(options, "DONE");
	selectType(player, player, 0x67, "Technical support is considered to be sound/video problems, client crashes, lag, latency, or other technical issues.  If you have lost items or stats within the game, this is not a technical support issue, please return to the Main Menu.", options);
	return();
}

function void show_phone_support_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "Select this option to return to the main page.");
	appendToList(options, 0x01);
	appendToList(options, "Select this option to return to the previous menu.");
	appendToList(options, 0x02);
	appendToList(options, "DONE");
	selectType(player, player, 0x68, "Phone support can be reached at (512) 434-HELP.  Our technicians will be available to help you from 10:00am to 7:00pm CST.  We shut our phones down at 1:00pm to let your hard working technicians eat lunch.", options);
	return();
}

function void show_email_support_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "Select this option to return to the main page.");
	appendToList(options, 0x01);
	appendToList(options, "Select this option to return to the previous menu.");
	appendToList(options, 0x02);
	appendToList(options, "DONE");
	selectType(player, player, 0x69, "E-mail support can be reach by e-mailing:  support@owo.com.  Please give our representatives four working days when answering your e-mail request.", options);
	return();
}

function void show_billing_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "If you were not able to find the information you needed through the web page, you may also try to call (512) 434-HELP.  A representative will be available to help you from 10:00am to 7:00pm CST (M-F).  We do break from 1:00pm to 2:00pm for lunch.");
	appendToList(options, 0x01);
	appendToList(options, "Select this option to open your browser to the registration site.");
	appendToList(options, 0x02);
	appendToList(options, "Select this option to return to the main menu.");
	appendToList(options, 0x03);
	appendToList(options, "DONE");
	selectType(player, player, 0x6A, "Most billing inquiries are able to be answered through our billing web page.  To see the status of your account, you may either open your browser and go to:  http://ultima-registration.com , or you may select the option below to open your browser.", options);
	return();
}

function void show_gameplay_help_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "If you were not able to find the information you needed through the web page, you may also write our e-mail support at:  support@owo.com");
	appendToList(options, 0x01);
	appendToList(options, "Would you like some information within the game?  Page a counselor.  Counselors are players, just like you, that have volunteered to avail their knowledge to other players.  There is no guarantee that a counselor will be in the game at this time as they are volunteer support.");
	appendToList(options, 0x02);
	appendToList(options, "Select this option to open your browser to the online guide.");
	appendToList(options, 0x03);
	appendToList(options, "Select this option to return to the main menu.");
	appendToList(options, 0x04);
	appendToList(options, "DONE");
	selectType(player, player, 0x6B, "Many of the gameplay questions that you may have are answered on our website.  To manually go to this address, you may open your browser to:  http://www.owo.com/guide/index.html", options);
	return();
}

function void show_character_help_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "ITEMS:  If you have lost an item, cannot use an item, have a problem with an item, or have general item questions.  Select this option.");
	appendToList(options, 0x01);
	appendToList(options, "SKILLS AND STATS:  Information about how to increase skills or stats, questions as to why they go up or down, or things that might influence stats or skills.  Select this option.");
	appendToList(options, 0x02);
	appendToList(options, "DONE");
	selectType(player, player, 0x6C, "Help for problems with your character.", options);
	return();
}

function void show_item_problem_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "SUBMIT:  Submit a bug report.");
	appendToList(options, 0x01);
	appendToList(options, "You see the item, but you cannot use it, equip it, or unequip it; even though it is on your person.");
	appendToList(options, 0x02);
	appendToList(options, "You cannot see the item, but others can see it, even though it is on your person.");
	appendToList(options, 0x03);
	appendToList(options, "DONE");
	selectType(player, player, 0x6D, "If you have lost items in the game, we are sorry.  Items can be lost to decay, theft, and rarely bugs.  We do not replace lost items within the game no matter how they were lost.  We encourage you to submit a bug report.", options);
	return();
}

function void show_unusable_item_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "If you have tried both of these options, select this option to have a call entered into the Game Master queue, and someone will come to help you as soon as possible.");
	appendToList(options, 0x01);
	appendToList(options, "DONE");
	selectType(player, player, 0x6E, "Try the following suggestions if you can see the item but you cannot use it.  1) Try to log out of the game and back in.  This often fixes the problem.  2) Try to enter a dungeon and exit it.  This can also solve the problem.", options);
	return();
}

function void show_invisible_item_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "If you have tried both of these options, select this option to have a call entered into the Game Master queue, and someone will come to help you as soon as possible.");
	appendToList(options, 0x01);
	appendToList(options, "DONE");
	selectType(player, player, 0x6F, "Help with items that you cannot see, but others can see.  1) Try to log out of the game and back in.  This often fixes the problem.  2) Try to enter a dungeon and exit it.  This can also solve the problem.", options);
	return();
}

function void show_skill_help_menu(obj player) {
	list options;
	appendToList(options, 0x00);
	appendToList(options, "To visit the web site and see the skill documentation, select this option.");
	appendToList(options, 0x01);
	appendToList(options, "If your character is losing skill or attribute points quickly, say 10 points an hour, you may have a corrupted character.  Select this option to call a Game Master.");
	selectType(player, player, 0x70, "Ultima Online does have things which lower skills as well as raise them.  Skill atrophy occurs when a skill is used very little or when you have reached the pinnacle of the skills.  Sometimes a skill might be lowered so that another skill can raise.", options);
	return();
}

trigger typeselected(0x64) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		if (check_gm_available(this)) {
			show_problem_prompt(this);
			textEntry(this, this, 0x01, 0x00, "");
		}
		break;
	case 0x01
		if (check_gm_available(this)) {
			show_problem_prompt(this);
			textEntry(this, this, 0x02, 0x00, "");
		}
		break;
	case 0x02
		show_character_help_menu(this);
		break;
	case 0x03
		show_tech_billing_menu(this);
		break;
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x65) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_tech_support_menu(this);
		break;
	case 0x01
		show_billing_menu(this);
		break;
	case 0x02
		show_main_menu(this);
		break;
	case 0x03
		show_general_help_menu(this);
		break;
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x66) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_gameplay_help_menu(this);
		break;
	case 0x01
		notify_browser_starting(this);
		webBrowse(this, "http://update.owo.com/");
		end_help_session(this, 0x00);
		break;
	case 0x02
		notify_browser_starting(this);
		webBrowse(this, "http://www.owo.com/help/tech/bugs/bus_main.html");
		end_help_session(this, 0x00);
		break;
	case 0x03
		show_tech_billing_menu(this);
		break;
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x67) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_phone_support_menu(this);
		break;
	case 0x01
		show_email_support_menu(this);
		break;
	case 0x02
		notify_browser_starting(this);
		webBrowse(this, "http://www.owo.com/help/index.html");
		end_help_session(this, 0x00);
		break;
	case 0x03
		show_main_menu(this);
		break;
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x68) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_main_menu(this);
		break;
	case 0x01
		show_tech_support_menu(this);
		break;
	case 0x02
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x69) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_main_menu(this);
		break;
	case 0x01
		show_tech_support_menu(this);
		break;
	case 0x02
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6A) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x01
		notify_browser_starting(this);
		webBrowse(this, "http://ultima-registration.com");
		end_help_session(this, 0x00);
		break;
	case 0x02
		show_main_menu(this);
		break;
	case 0x00
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6B) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_email_support_menu(this);
		break;
	case 0x01
		show_problem_prompt(this);
		textEntry(this, this, 0x03, 0x00, "");
		break;
	case 0x02
		notify_browser_starting(this);
		webBrowse(this, "http://www.owo.com/guide/index.html");
		end_help_session(this, 0x00);
		break;
	case 0x03
		show_main_menu(this);
		break;
	case 0x04
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6C) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		show_item_problem_menu(this);
		break;
	case 0x01
		show_skill_help_menu(this);
		break;
	case 0x02
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6D) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		notify_browser_starting(this);
		webBrowse(this, "http://www.owo.com/help/tech/bugs/bus_main.html");
		end_help_session(this, 0x00);
		break;
	case 0x01
		show_unusable_item_menu(this);
		break;
	case 0x02
		show_invisible_item_menu(this);
		break;
	case 0x03
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6E) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		if (check_gm_available(this)) {
			show_problem_prompt(this);
			textEntry(this, this, 0x04, 0x00, "");
		}
		break;
	case 0x01
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x6F) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		if (check_gm_available(this)) {
			show_problem_prompt(this);
			textEntry(this, this, 0x05, 0x00, "");
		}
		break;
	case 0x01
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger typeselected(0x70) {
	close_if_invalid(this, listindex, 0x01);
	schedule_timeout(this);
	switch(objtype) {
	case 0x00
		notify_browser_starting(this);
		webBrowse(this, "http://www.owo.com/guide/skills/main.html");
		end_help_session(this, 0x00);
		break;
	case 0x01
		if (check_gm_available(this)) {
			show_problem_prompt(this);
			textEntry(this, this, 0x06, 0x00, "");
		}
		break;
	case 0x02
		default
		end_help_session(this, 0x01);
		break;
	}
	return(0x00);
}

trigger textentry(0x01) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x01, "Stuck", text)end_help_session(this, 0x00);
	return(0x00);
}

trigger textentry(0x02) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x01, "Harassment", text)end_help_session(this, 0x00);
	return(0x00);
}

trigger textentry(0x03) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x00, "", text)end_help_session(this, 0x00);
	return(0x00);
}

trigger textentry(0x04) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x01, "Unusable item", text)end_help_session(this, 0x00);
	return(0x00);
}

trigger textentry(0x05) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x01, "Invisible item", text)end_help_session(this, 0x00);
	return(0x00);
}

trigger textentry(0x06) {
	close_if_invalid(this, button, 0x01);
	show_request_submitted(this);
	submit_help_request(this, 0x01, "Stat/Skill Problem", text)end_help_session(this, 0x00);
	return(0x00);
}
