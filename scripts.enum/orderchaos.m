inherits globals;

member obj recruit_candidate;

member int is_order_faction;

function int has_order_shield(obj mobile) {
	if (hasObjType(mobile, 0x1BC3) || hasObjTypeInBank(mobile, 0x1BC3)) {
		return(0x01);
	}
	return(0x00);
}

function int has_chaos_shield(obj mobile) {
	if (hasObjType(mobile, 0x1BC4) || hasObjTypeInBank(mobile, 0x1BC4) || hasObjType(mobile, 0x1BC5) || hasObjTypeInBank(mobile, 0x1BC5)) {
		return(0x01);
	}
	return(0x00);
}

function int has_faction_sigil(obj player) {
	if (is_order_faction) {
		return(has_order_shield(player));
	}
	return(has_chaos_shield(player));
}

function int has_rival_sigil(obj player) {
	if (is_order_faction) {
		return(has_chaos_shield(player));
	}
	return(has_order_shield(player));
}

function int handle_virtue_guard_speech(obj speaker, obj this) {
	list responses;
	string response;
	if (has_faction_sigil(speaker)) {
		responses = "Hail and well met!", "Greetings, fellow guard.", "In the name of our liege, greetings!", "Greetings, my friend.", "Hail, my friend.", "Yes, thou'rt a virtue guard.", "Hmm? Yes, I am one. So art thou.", "Yes, as thou knowest, it is a great thing to be one!", "Isn't it wonderful being a virtue guard?", "Why dost thou ask about virtue guards when thou art one?";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		bark(this, response);
		return(0x00);
	}
	if (has_rival_sigil(speaker)) {
		responses = "Stay away, lest our rivalry develop into something worse!", "Thou'rt not of my brotherhood! Away with thee!", "Whilst I grant respect to thy lord, I mislike thy emblem.", "Art thou here to harass me?", "Tch tch... thou wearest the wrong emblem!", "'Tis a pity that thou art in the wrong camp!", "There is a rivalry between thy group and mine--be careful.", "Is not thy emblem a sign that thou art a member of our rival guards?";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		bark(this, response);
		return(0x00);
	}
	if (getNotoriety(speaker) < 0x7F) {
		responses = "Thou art not worthy of being a member of our fraternity.", "The guards will not accept thee until thy reputation improves.", "Thou hast not the unblemished record we expect from our members.", "Thy record is not good enough to join the guards.", "Only those of utmost probity are accepted into the guards.", "Only the very best of citizens may join the guards.", "Thou dost not qualify for the virtue guards; thy record is not good enough.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		if (getNotorietyLevel(speaker) > 0x04) {
			response = response + " Thou'rt extremely close, however.";
		} else {
			if (getNotorietyLevel(speaker) < 0x00) {
				response = response + " Do not dishonor us by asking again, scum.";
			}
		}
		bark(this, response);
		return(0x00);
	}
	if (is_order_faction) {
		responses = "Thou hast the look of a likely candidate for joining Lord Blackthorn's guards.", "Wouldst thou be interested in joining Blackthorn's guard?", "Blackthorn's guard hath been looking for folk like thee.", "Thou'rt a good and honest person. Care to join Lord Blackthorn's guard?", "If thou art interested in joining Lord Blackthorn's guard, a place can be found for thee.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		response = response + " Say 'yea' if thou art interested.";
		bark(this, response);
	} else {
		responses = "Thou hast the look of a likely candidate for joining Lord British's guards.", "Wouldst thou be interested in joining British's guard?", "British's guard hath been looking for folk like thee.", "Thou'rt a good and honest person. Care to join Lord British's guard?", "If thou art interested in joining Lord British's guard, a place can be found for thee.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		response = response + " Say 'yea' if thou art interested.";
		bark(this, response);
	}
	recruit_candidate = speaker;
	return(0x00);
}

trigger speech("virtue*guard") {
	if (getCompileFlag(0x01)) {
		return(0x01);
	}
	int result = handle_virtue_guard_speech(speaker, this);
	return(0x00);
}

function int isChaosGuard(obj speaker) {
	return(hasScript(speaker, "chaosguild"));
}

function int isOrderGuard(obj speaker) {
	return(hasScript(speaker, "orderguild"));
}

function int is_rival_guard(obj speaker) {
	if (is_order_faction) {
		return(isOrderGuard(speaker));
	}
	return(isChaosGuard(speaker));
}

function int is_allied_guard(obj speaker) {
	if (is_order_faction) {
		return(isChaosGuard(speaker));
	}
	return(isOrderGuard(speaker));
}

function void handle_shield_speech(obj speaker) {
	list responses;
	string response;
	if (is_allied_guard(speaker)) {
		responses = "Hail and well met!", "Greetings, fellow guard.", "In the name of our liege, greetings!", "Greetings, my friend.", "Hail, my friend.", "Yes, thou'rt a virtue guard.", "Hmm? Yes, I am one. So art thou.", "Yes, as thou knowest, it is a great thing to be one!", "Isn't it wonderful being a virtue guard?";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		if (!has_faction_sigil(speaker)) {
			response = response + "  I see you are in need of our shield.  Here you go.";
			obj sigil;
			if (is_order_faction) {
				sigil = requestCreateObjectIn(0x1BC3, getBackpack(speaker));
			} else {
				sigil = requestCreateObjectIn(0x1BC4, getBackpack(speaker));
			}
		}
		bark(this, response);
		return();
	}
	if (is_rival_guard(speaker)) {
		responses = "Stay away, lest our rivalry develop into something worse!", "Thou'rt not of my brotherhood! Away with thee!", "Whilst I grant respect to thy lord, I mislike thy emblem.", "Art thou here to harass me?", "Tch tch... thou wearest the wrong emblem!", "'Tis a pity that thou art in the wrong camp!", "There is a rivalry between thy group and mine--be careful.", "Is not thy emblem a sign that thou art a member of our rival guards?";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		bark(this, response);
		return();
	}
	if (isMurderer(speaker) || (getFameLevel(speaker) < 0x03)) {
		responses = "Thou art not worthy of being a member of our fraternity.", "The guards will not accept thee until thy reputation improves.", "Thou hast not the unblemished record we expect from our members.", "Thy record is not good enough to join the guards.", "Only those of utmost probity are accepted into the guards.", "Only the very best of citizens may join the guards.", "Thou dost not qualify for the virtue guards; thy record is not good enough.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		bark(this, response);
		return();
	}
	if (is_order_faction) {
		responses = "Thou hast the look of a likely candidate for joining Lord Blackthorn's guards.", "Wouldst thou be interested in joining Blackthorn's guard?", "Blackthorn's guard hath been looking for folk like thee.", "Thou'rt a good and honest person. Care to join Lord Blackthorn's guard?", "If thou art interested in joining Lord Blackthorn's guard, a place can be found for thee.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		response = response + " Sign up with a guild of chaos if thou art interested.";
		bark(this, response);
	} else {
		responses = "Thou hast the look of a likely candidate for joining Lord British's guards.", "Wouldst thou be interested in joining British's guard?", "British's guard hath been looking for folk like thee.", "Thou'rt a good and honest person. Care to join Lord British's guard?", "If thou art interested in joining Lord British's guard, a place can be found for thee.";
		response = responses[random(0x00, numInList(responses) - 0x01)];
		response = response + " Sign up with a guild of order if thou art interested.";
		bark(this, response);
	}
	return();
}

trigger speech("*order*shield*") {
	if (!getCompileFlag(0x01)) {
		return(0x01);
	}
	handle_shield_speech(speaker);
	return(0x00);
}

trigger speech("*chaos*shield*") {
	if (!getCompileFlag(0x01)) {
		return(0x01);
	}
	handle_shield_speech(speaker);
	return(0x00);
}

function int handle_yea_response(obj speaker) {
	if (speaker != recruit_candidate) {
		return(0x01);
	}
	if ((getNotoriety(speaker) < 0x7F) || has_chaos_shield(speaker) || has_order_shield(speaker)) {
		recruit_candidate = NULL();
		return(0x00);
	}
	obj sigil;
	if (is_order_faction) {
		sigil = requestCreateObjectIn(0x1BC3, getBackpack(speaker));
	} else {
		sigil = requestCreateObjectIn(0x1BC4, getBackpack(speaker));
	}
	if (sigil == NULL()) {
		bark(this, "I'm sorry, the ranks of the knights are currently full.");
		return(0x00);
	}
	setObjVar(sigil, "owner", speaker);
	list responses = "Excellent! Welcome to our ranks!", "Welcome to our ranks!", "Excellent!", "'Tis a good choice.", "Congratulations!", "I congratulate thee!";
	string msg = responses[random(0x00, numInList(responses) - 0x01)];
	msg = msg + " Thy shield is in thy backpack. Be sure that thou dost not lose thy reputation, or else thou shalt lose thy life with it.";
	bark(this, msg);
	recruit_candidate = NULL();
	return(0x00);
}

function int handle_decline(obj speaker) {
	if (speaker != recruit_candidate) {
		return(0x01);
	}
	bark(this, "A pity.");
	recruit_candidate = NULL();
	return(0x00);
}

trigger speech("yes") {
	return(handle_yea_response(speaker));
}

trigger speech("yea") {
	return(handle_yea_response(speaker));
}

trigger speech("no") {
	return(handle_decline(speaker));
}

trigger speech("nay") {
	return(handle_decline(speaker));
}
