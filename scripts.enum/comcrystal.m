member int charges;

member list linked_crystals;

member int is_active;

member int max_charges;

function int get_link_count() {
	return(numInList(linked_crystals));
}

function int has_charges() {
	if (charges != 0x00) {
		return(0x01);
	}
	return(0x00);
}

function int get_charges() {
	return(charges);
}

function void update_value(obj crystal) {
	int value = 0x00;
	if (hasObjVar(crystal, "mybasevalue")) {
		value = getObjVar(crystal, "mybasevalue");
	}
	int cur_charges = get_charges();
	int new_value = 0x00;
	if (cur_charges < 0x00) {
		new_value = 0x03E7;
	} else {
		new_value = 0x01 * cur_charges / 0x0A;
	}
	new_value = new_value + 0x05;
	if (new_value != value) {
		setObjVar(crystal, "mybasevalue", new_value);
	}
	return();
}

function void set_charges(int newcharges) {
	charges = newcharges;
	update_value(this);
	return();
}

function void init_charges(int newcharges) {
	set_charges(newcharges);
	return();
}

function int adjust_charges(int delta) {
	charges = charges + delta;
	update_value(this);
	return(charges);
}

function int is_com_crystal(obj it) {
	int result = hasObjVar(it, "isComCrystal");
	return(result);
}

function void set_crystal_type(obj it, int status) {
	int newType = 0x1ECD;
	if (status) {
		newType = 0x1ED0;
	}
	if (getObjType(it) != newType) {
		setType(it, newType);
	}
	return();
}

function void set_active_state(obj it, int status) {
	is_active = status;
	set_crystal_type(it, is_active);
	return();
}

function int toggle_active(obj user, obj crystal) {
	if (is_active) {
		set_active_state(crystal, 0x00);
		systemMessage(user, "You turn the crystal off.");
	} else {
		set_active_state(crystal, 0x01);
		systemMessage(user, "You turn the crystal on.");
	}
	return(is_active);
}

function int link_crystal(obj user, obj m_target) {
	if (isInList(linked_crystals, m_target)) {
		systemMessage(user, "This crystal is already linked with that crystal.");
		return(0x00);
	}
	appendToList(linked_crystals, m_target);
	systemMessage(user, "That crystal has been linked to this crystal.");
	return(0x01);
}

function int check_usable(obj crystal, obj user) {
	if (!has_charges()) {
		systemMessage(user, "This crystal is out of charges.");
		return(0x00);
	}
	return(0x01);
}

function int relay_speech(obj sender, obj speaker, string arg) {
	if (!has_charges()) {
		return(0x00);
	}
	list relay_args;
	appendToList(relay_args, speaker);
	string speaker_name = getName(speaker);
	appendToList(relay_args, speaker_name);
	int text_hue = getDefaultTextHue(speaker);
	appendToList(relay_args, text_hue);
	appendToList(relay_args, arg);
	int num = numInList(linked_crystals);
	int i;
	for (i = 0x00; i < num; i++) {
		obj linked_crystal = linked_crystals[i];
		multimessage(linked_crystal, "comspeech", relay_args);
		if (adjust_charges((0x00 - 0x01)) == 0x00) {
			toggle_active(speaker, sender);
			break;
		}
	}
	return(i);
}

function void apply_pending_charges() {
	if (hasObjVar(this, "newcharges")) {
		int newcharges = getObjVar(this, "newcharges");
		removeObjVar(this, "newcharges");
		set_charges(newcharges);
	}
	return();
}

function string get_display_name() {
	string name;
	if (is_active) {
		concat(name, "an active ");
	} else {
		concat(name, "an inactive ");
	}
	concat(name, "crystal of communication");
	concat(name, " with ");
	int charges = get_charges();
	if (charges < 0x00) {
		concat(name, "infinite");
	} else {
		name = name + charges;
	}
	concat(name, " charges");
	int link_count = get_link_count();
	if (link_count > 0x00) {
		concat(name, " and ");
		name = name + link_count;
		concat(name, " links");
	}
	return(name);
}

function void refresh_display_name() {
	string name = get_display_name();
	setObjVar(this, "lookAtText", name);
	return();
}

function int get_recharge_power(obj it) {
	int type = getObjType(it);
	int power = 0x00 - 0x01;
	switch(type) {
	case 0x0F25
	case 0x0F15
	case 0x0F23
	case 0x0F24
	case 0x0F2C
		power = 0x01F4;
		break;
	case 0x0F0A
	case 0x0F14
	case 0x0F1A
	case 0x0F1C
	case 0x0F1D
	case 0x0F2A
	case 0x0F2B
	case 0x0F18
	case 0x0F1E
	case 0x0F20
	case 0x0F2D
		power = 0x02EE;
		break;
	case 0x0F10
	case 0x0F2F
	case 0x0F11
	case 0x0F12
	case 0x0F19
	case 0x0F1F
	case 0x0F16
	case 0x0F17
	case 0x0F22
	case 0x0F2E
		power = 0x03E8;
		break;
	case 0x0F0F
	case 0x0F1B
	case 0x0F21
		power = 0x04E2;
		break;
	case 0x0F26
	case 0x0F27
	case 0x0F28
	case 0x0F29
	case 0x0F30
		power = 0x07D0;
		break;
	}
	return(power);
}

function void destroy_item(obj it) {
	destroyOne(it);
	return();
}

function int try_recharge_with_item(obj it, obj user) {
	obj container = getTopmostContainer(it);
	if ((container != NULL()) && (container != user)) {
		return(0x00);
	}
	int power;
	power = get_recharge_power(it);
	if (power <= 0x00) {
		return(0x00);
	}
	if (get_charges() < 0x00) {
		systemMessage(user, "This crystal can not be recharged.");
		return(0x00);
	}
	if (get_charges() >= max_charges) {
		systemMessage(user, "This crystal is already fully charged.");
		return(0x00);
	}
	int num = charges + power;
	if (num >= max_charges) {
		num = max_charges;
		systemMessage(user, "You completely recharge the crystal.");
	} else {
		systemMessage(user, "You recharge the crystal.");
	}
	set_charges(num);
	destroy_item(it);
	refresh_display_name();
	return(0x01);
}

trigger creation {
	max_charges = 0x07D0;
	init_charges(0x01F4);
	setObjVar(this, "isComCrystal", 0x01);
	set_active_state(this, 0x00);
	apply_pending_charges();
	refresh_display_name();
	attachScript(this, "speechrelay");
	return(0x01);
}

trigger lookedat {
	refresh_display_name();
	string name = get_display_name();
	barkTo(this, looker, name);
	return(0x00);
}

trigger use {
	targetobj(user, this);
	return(0x01);
}

trigger targetobj {
	if (!isValid(usedon)) {
		return(0x00);
	}
	if (try_recharge_with_item(usedon, user)) {
		return(0x00);
	}
	if (!check_usable(this, user)) {
		return(0x00);
	}
	if (usedon == this) {
		toggle_active(user, this);
	} else {
		if (is_com_crystal(usedon)) {
			link_crystal(user, usedon);
		} else {
			systemMessage(user, "You can not use this crystal on that.");
		}
	}
	return(0x01);
}

trigger message("speechrelayed") {
	apply_pending_charges();
	if (is_active) {
		int result = relay_speech(this, args[0x00], args[0x01]);
		refresh_display_name();
	}
	return(0x00);
}

trigger message("comspeech") {
	string speaker_name = args[0x01];
	int hue = args[0x02];
	string speech_text = args[0x03];
	string msg;
	obj owner = getTopmostContainer(this);
	if ((owner != NULL())) {
		if (isPlayer(owner)) {
			concat(msg, "Crystal: ");
		}
	}
	concat(msg, speaker_name);
	concat(msg, " says ");
	concat(msg, speech_text);
	int result = 0x01;
	if (owner == NULL()) {
		result = superBark(this, msg, hue, 0x03, 0x07);
	} else {
		if (isPlayer(owner)) {
			result = textMessage(owner, msg, hue, 0x03, 0x06);
		} else {
			result = superBark(owner, msg, hue, 0x03, 0x07);
		}
	}
	return(0x01);
}
