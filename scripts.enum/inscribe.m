inherits spelskil;

member obj caster;

member obj scroll;

member obj source_book;

member obj inscribed_scroll;

member list spellbook_contents;

member list circle1_spells;

member list circle2_spells;

member list circle3_spells;

member list circle4_spells;

member list circle5_spells;

member list circle6_spells;

member list circle7_spells;

member list circle8_spells;

member int finished;

forward void inscribe_spell(int spell_id);

forward void clear_spell_lists();

function int show_inscription_menu(obj user, obj usedon) {
	if (isAtHome(usedon)) {
		systemMessage(user, "That scroll belongs to someone else.");
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		return(0x00);
	}
	obj spellbook = mobileContainsObjType(user, 0x0EFA);
	if (isValid(spellbook)) {
		int i;
		int n;
		obj scroll;
		int spell_index;
		int spell_circle;
		int mana_cost;
		int cur_mana = getCurMana(user);
		int flag;
		obj obj_ref;
		int result;
		list reagent_list;
		int count;
		int val;
		list list_buf;
		string spell_name;
		loc user_loc = getLocation(user);
		getContents(spellbook_contents, spellbook);
		int scroll_count;
		scroll_count = numInList(spellbook_contents);
		sortList(spellbook_contents, 0x04);
		for (i = 0x00; i < scroll_count; i++) {
			scroll = spellbook_contents[i];
			spell_index = get_spell_index(scroll);
			spell_circle = get_spell_circle(scroll);
			mana_cost = mana_cost_for_circle(spell_circle);
			if (!can_attempt_spell(caster, spell_circle)) {
				i++;
				continue;
			}
			if (cur_mana < mana_cost) {
				i++;
				continue;
			}
			spell_name = get_spell_name(spell_index);
			switch(spell_circle) {
			case 0x01
				appendToList(circle1_spells, spell_index + 0x2080);
				appendToList(circle1_spells, spell_name);
				break;
			case 0x02
				appendToList(circle2_spells, spell_index + 0x2080);
				appendToList(circle2_spells, spell_name);
				break;
			case 0x03
				appendToList(circle3_spells, spell_index + 0x2080);
				appendToList(circle3_spells, spell_name);
				break;
			case 0x04
				appendToList(circle4_spells, spell_index + 0x2080);
				appendToList(circle4_spells, spell_name);
				break;
			case 0x05
				appendToList(circle5_spells, spell_index + 0x2080);
				appendToList(circle5_spells, spell_name);
				break;
			case 0x06
				appendToList(circle6_spells, spell_index + 0x2080);
				appendToList(circle6_spells, spell_name);
				break;
			case 0x07
				appendToList(circle7_spells, spell_index + 0x2080);
				appendToList(circle7_spells, spell_name);
				break;
			case 0x08
				appendToList(circle8_spells, spell_index + 0x2080);
				appendToList(circle8_spells, spell_name);
				break;
			default
				break;
			}
		}
		list circle_options;
		if (numInList(circle1_spells) > 0x00) {
			appendToList(circle_options, 0x20C0);
			appendToList(circle_options, "First Circle");
		}
		if (numInList(circle2_spells) > 0x00) {
			appendToList(circle_options, 0x20C1);
			appendToList(circle_options, "Second Circle");
		}
		if (numInList(circle3_spells) > 0x00) {
			appendToList(circle_options, 0x20C2);
			appendToList(circle_options, "Third Circle");
		}
		if (numInList(circle4_spells) > 0x00) {
			appendToList(circle_options, 0x20C3);
			appendToList(circle_options, "Fourth Circle");
		}
		if (numInList(circle5_spells) > 0x00) {
			appendToList(circle_options, 0x20C4);
			appendToList(circle_options, "Fifth Circle");
		}
		if (numInList(circle6_spells) > 0x00) {
			appendToList(circle_options, 0x20C5);
			appendToList(circle_options, "Sixth Circle");
		}
		if (numInList(circle7_spells) > 0x00) {
			appendToList(circle_options, 0x20C6);
			appendToList(circle_options, "Seventh Circle");
		}
		if (numInList(circle8_spells) > 0x00) {
			appendToList(circle_options, 0x20C7);
			appendToList(circle_options, "Eighth Circle");
		}
	} else {
		systemMessage(user, "You don't have a spellbook.");
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		return(0x00);
	}
	if (numInList(circle_options) > 0x00) {
		selectType(caster, this, 0x1C, "Choose a circle.", circle_options);
		return(0x01);
	} else {
		systemMessage(user, "You can't inscribe any spells.");
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		return(0x00);
	}
	return(0x01);
}

function int copy_book(obj user, obj usedon) {
	int obj_type = getObjType(usedon);
	if (isAtHome(usedon)) {
		systemMessage(user, "That book belongs to someone else.");
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		return(0x00);
	}
	int pages = getBookPages(usedon);
	if (source_book == NULL()) {
		if (pages == 0x00) {
			systemMessage(user, "Can't copy an empty book.");
			if (hasObjVar(usedon, "inUse")) {
				removeObjVar(usedon, "inUse");
			}
			return(0x00);
		}
		source_book = usedon;
		systemMessage(user, "Select a book to copy this to.");
		targetObj(user, this);
	} else {
		if (obj_type == 0x0FEF) {
			systemMessage(user, "Cannot write into that book.");
			if (hasObjVar(source_book, "inUse")) {
				removeObjVar(source_book, "inUse");
			}
			if (hasObjVar(usedon, "inUse")) {
				removeObjVar(usedon, "inUse");
			}
			return(0x00);
		}
		if (obj_type == 0x0FF0) {
			systemMessage(user, "Cannot write into that book.");
			if (hasObjVar(source_book, "inUse")) {
				removeObjVar(source_book, "inUse");
			}
			if (hasObjVar(usedon, "inUse")) {
				removeObjVar(usedon, "inUse");
			}
			return(0x00);
		}
		if (usedon == source_book) {
			systemMessage(user, "Cannot copy a book onto itself.");
			if (hasObjVar(source_book, "inUse")) {
				removeObjVar(source_book, "inUse");
			}
			if (hasObjVar(usedon, "inUse")) {
				removeObjVar(usedon, "inUse");
			}
			return(0x00);
		}
		int difficulty = 0x96;
		int failed = 0x00;
		if (testAndLearnSkill(user, SKILL_INSCRIPTION, difficulty, 0x32) <= 0x00) {
			failed = 0x01;
		} else {
			int result;
			result = copybook(usedon, source_book);
			sfx(getLocation(caster), 0x0249, 0x00);
			if (result == 0x00) {
				failed = 0x01;
			}
		}
		if (hasObjVar(source_book, "inUse")) {
			removeObjVar(source_book, "inUse");
		}
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		source_book = NULL();
		if (failed) {
			systemMessage(user, "You fail to make a copy of the book.");
			return(0x00);
		} else {
			systemMessage(user, "You make a copy of the book.");
		}
	}
	return(0x01);
}

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	if (!finished) {
		systemMessage(this, "You have waited too long to make your inscribe selection, your inscription attempt has timed out.")}
	detachScript(this, "inscribe");
	clear_spell_lists();
	return(0x00);
}

function void schedule_timeout(obj it, int done) {
	int delay = 0x3C;
	if (done) {
		delay = 0x0A;
		finished = 0x01;
	}
	callback(it, delay, 0x4D);
	return();
}

trigger message("useSkill") {
	schedule_timeout(this, 0x00);
	systemMessage(this, "What would you like to inscribe?");
	source_book = NULL();
	targetObj(this, this);
	return(0x00);
}

function int handle_inscription_target(obj user, obj usedon) {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (hasObjVar(usedon, "inUse")) {
		systemMessage(user, "Someone else is inscribing that item.");
		return(0x00);
	}
	int obj_type = getObjType(usedon);
	switch(obj_type) {
	case 0x0EF3
	case 0x0E34
		scroll = usedon;
		caster = user;
		setObjVar(scroll, "inUse", 0x00);
		attachscript(scroll, "removeinuse");
		callback(scroll, 0x3C, 0x1B);
		return(show_inscription_menu(user, usedon));
		break;
	case 0x0FEF
	case 0x0FF0
	case 0x0FF1
	case 0x0FF2
		scroll = usedon;
		caster = user;
		setObjVar(scroll, "inUse", 0x00);
		attachscript(scroll, "removeinuse");
		callback(scroll, 0x3C, 0x1B);
		return(copy_book(user, usedon));
		break;
	default
		systemMessage(user, "Can't inscribe that item.");
		if (hasObjVar(source_book, "inUse")) {
			removeObjVar(source_book, "inUse");
		}
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		return(0x00);
		break;
	}
	return(0x01);
}

trigger targetobj {
	if (!handle_inscription_target(user, usedon)) {
		clear_spell_lists();
		schedule_timeout(this, 0x01);
	} else {
		schedule_timeout(this, 0x00);
	}
	return(0x00);
}

function int show_circle_spells(obj user, int listindex, int objtype) {
	if (listindex == 0x00) {
		return(0x00);
	}
	switch(objtype) {
	case 0x20C0
		selectType(caster, this, 0x1D, "Choose a first circle spell.", circle1_spells);
		break;
	case 0x20C1
		selectType(caster, this, 0x1E, "Choose a second circle spell.", circle2_spells);
		break;
	case 0x20C2
		selectType(caster, this, 0x1F, "Choose a third circle spell.", circle3_spells);
		break;
	case 0x20C3
		selectType(caster, this, 0x20, "Choose a fourth circle spell.", circle4_spells);
		break;
	case 0x20C4
		selectType(caster, this, 0x21, "Choose a fifth circle spell.", circle5_spells);
		break;
	case 0x20C5
		selectType(caster, this, 0x22, "Choose a sixth circle spell.", circle6_spells);
		break;
	case 0x20C6
		selectType(caster, this, 0x23, "Choose a seventh circle spell.", circle7_spells);
		break;
	case 0x20C7
		selectType(caster, this, 0x24, "Choose a eighth circle spell.", circle8_spells);
		break;
	default
		return(0x00);
		break;
	}
	if (hasObjVar(scroll, "inUse")) {
		removeObjVar(scroll, "inUse");
	}
	return(0x01);
}

trigger typeselected(0x1C) {
	if (!show_circle_spells(user, listindex, objtype)) {
		clear_spell_lists();
		schedule_timeout(this, 0x01);
	} else {
		schedule_timeout(this, 0x00);
	}
	return(0x00);
}

function void handle_spell_type_selected(int listindex, int objtype) {
	if (listindex != 0x00) {
		inscribe_spell(objtype - 0x2080);
	}
	clear_spell_lists();
	schedule_timeout(this, 0x01);
	return();
}

trigger typeselected(0x1D) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x1E) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x1F) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x20) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x21) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x22) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x23) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

trigger typeselected(0x24) {
	handle_spell_type_selected(listindex, objtype);
	return(0x00);
}

function void inscribe_spell(int spell_index) {
	list reagents;
	get_spell_reagents(reagents, spell_index);
	loc caster_loc = getLocation(caster);
	if (!consume_reagents(caster, reagents)) {
		systemMessage(caster, "You lack the necessary reagents to inscribe this spell.");
		return();
	}
	int circle = circle_from_index(spell_index);
	int mana_cost = mana_cost_for_circle(circle);
	if (check_cast_conditions(caster, caster_loc, mana_cost)) {
		loseMana(caster, mana_cost);
		int failed = 0x00;
		int cast_time = get_skill_threshold(spell_num_to_circle(spell_index));
		if (!can_attempt_spell(caster, spell_num_to_circle(spell_index))) {
			failed = 0x01;
		}
		if (!failed) {
			if (testAndLearnSkill(caster, SKILL_INSCRIPTION, cast_time, 0x32) <= 0x00) {
				failed = 0x01;
			}
		}
		if (failed) {
			systemMessage(caster, "You fail to inscribe the scroll, and the scroll is ruined.");
			destroyOne(scroll);
			return();
		}
		int scroll_type = get_scroll_objtype(spell_index);
		inscribed_scroll = requestCreateObjectAt(scroll_type, getLocation(caster));
		destroyOne(scroll);
		string scroll_script;
		scroll_script = scroll_type;
		attachscript(inscribed_scroll, scroll_script);
		int place_result;
		obj backpack = getBackpack(caster);
		if (canHold(backpack, inscribed_scroll)) {
			place_result = putObjContainer(inscribed_scroll, backpack);
			sfx(getLocation(caster), 0x0249, 0x00);
			systemMessage(caster, "You inscribe the spell and put the scroll in your backpack.");
		} else {
			if (isValid(scroll)) {
				place_result = teleport(scroll, getLocation(caster));
			}
			sfx(getLocation(caster), 0x0249, 0x00);
			systemMessage(caster, "You inscribe the spell and put the scroll at your feet.");
		}
		if (isValid(scroll)) {
			if (hasObjVar(scroll, "inUse")) {
				removeObjVar(scroll, "inUse");
			}
			if (hasScript(scroll, "removeinuse")) {
				detachScript(scroll, "removeinuse");
			}
		}
	} else {
		systemMessage(caster, "You fail to inscribe the scroll, and the scroll is ruined.");
		destroyOne(scroll);
		return();
	}
	return();
}

function void clear_spell_lists() {
	clearList(spellbook_contents);
	clearList(circle1_spells);
	clearList(circle2_spells);
	clearList(circle3_spells);
	clearList(circle4_spells);
	clearList(circle5_spells);
	clearList(circle6_spells);
	clearList(circle7_spells);
	clearList(circle8_spells);
	if (hasObjVar(scroll, "inUse")) {
		removeObjVar(scroll, "inUse");
	}
	if (hasScript(scroll, "removeinuse")) {
		removeObjVar(scroll, "removeinuse");
	}
	return();
}

trigger callback(0x1B) {
	if (hasObjVar(scroll, "inUse")) {
		removeObjVar(scroll, "inUse");
	}
	if (hasObjVar(source_book, "inUse")) {
		removeObjVar(source_book, "inUse");
	}
	return(0x01);
}
