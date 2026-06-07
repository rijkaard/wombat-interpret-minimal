inherits sndfx;

function int get_skill_threshold(int circle) {
	return((circle - 0x01) * 0x03E8 / 0x07);
}

function void do_cast_anim(obj user, int anim_id) {
	int body_type = getObjType(user);
	if (body_type < 0xC8) {
		if (body_type == 0x16) {
			animateMobile(user, 0x04 + anim_id - 0x01, 0x04, 0x01, 0x00, 0x00);
			return();
		}
		if ((body_type != 0x18) && (body_type != 0x09) && (body_type != 0x0A) && (body_type != 0x04)) {
			return();
		}
		switch(anim_id) {
		case 0x01
			animateMobile(user, 0x0C, 0x07, 0x01, 0x00, 0x00);
			break;
		case 0x02
		case 0x03
			animateMobile(user, 0x0D, 0x07, 0x01, 0x00, 0x00);
			break;
		}
	} else {
		if (body_type >= 0x0190) {
			if (getItemAtSlot(user, EQUIP_MOUNT) != NULL()) {
				return();
			}
			switch(anim_id) {
			case 0x01
				animateMobile(user, 0x10, 0x07, 0x01, 0x00, 0x00);
				break;
			case 0x02
			case 0x03
				animateMobile(user, 0x11, 0x06, 0x01, 0x00, 0x00);
				break;
			}
		}
	}
	return();
}

function int is_scroll(obj it) {
	int obj_type = getObjType(it);
	if ((obj_type < 0x1F2D) || (obj_type > 0x1F6C)) {
		return(0x00);
	}
	return(0x01);
}

function int is_spellbook(obj it) {
	if (!isValid(it)) {
		return(0x00)}
	if (getObjType(it) == 0x0EFA) {
		return(0x01);
	}
	return(0x00);
}

function int is_loose_scroll(obj it) {
	if (is_scroll(it)) {
		obj container = containedBy(it);
		if (container == NULL()) {
			return(0x01);
		}
		if (!is_spellbook(container)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int isScroll() {
	return(is_loose_scroll(this));
}

function int check_mana(obj user, int mana_cost) {
	if (mana_cost > (getCurMana(user))) {
		barkToHued(user, user, 0x22, "Insufficient mana for this spell.");
		return(0x00);
	}
	return(0x01);
}

function int get_spell_index(obj it) {
	int num = getMiscData(it) - 0x01;
	return(num);
}

function int spell_num_from_index(int spell_index) {
	return(spell_index + 0x01);
}

function int get_spell_circle(obj spell_item) {
	int circle = 0x02;
	if (is_scroll(spell_item)) {
		circle = (get_spell_index(spell_item) / 0x08) + 0x01;
	}
	return(circle);
}

function int circle_from_index(int num) {
	return((num / 0x08) + 0x01);
}

function int mana_cost_for_circle(int circle) {
	int cost = 0x00;
	switch(circle) {
	case 0x01
		cost = 0x04;
		break;
	case 0x02
		cost = 0x06;
		break;
	case 0x03
		cost = 0x09;
		break;
	case 0x04
		cost = 0x0B;
		break;
	case 0x05
		cost = 0x0E;
		break;
	case 0x06
		cost = 0x14;
		break;
	case 0x07
		cost = 0x28;
		break;
	case 0x08
		cost = 0x32;
		break;
	}
	return(cost);
}

function int is_hand_free(obj it) {
	if (it == NULL()) {
		return(0x01);
	}
	if (is_spellbook(it)) {
		return(0x01);
	}
	return(0x00);
}

function int validate_cast_prereqs(obj user, int mana_cost) {
	obj rightHand = getItemAtSlot(user, EQUIP_RIGHT_HAND);
	obj leftHand = getItemAtSlot(user, EQUIP_LEFT_HAND);
	if (!is_hand_free(rightHand)) {
		barkToHued(user, user, 0x22, "Your hands must be free to cast spells.");
		return(0x00);
	}
	if (getCompileFlag(0x01)) {
		if (!is_hand_free(leftHand)) {
			barkToHued(user, user, 0x22, "Your hands must be free to cast spells.");
			return(0x00);
		}
	} else {
		if ((!isUsingVirtueShield(user)) && (!is_hand_free(leftHand))) {
			barkToHued(user, user, 0x22, "Your hands must be free to cast spells.");
			return(0x00);
		}
	}
	if (!check_mana(user, mana_cost)) {
		barkToHued(user, user, 0x22, "Not enough mana to cast this spell.");
		return(0x00);
	}
	if (isDead(user)) {
		return(0x00);
	}
	return(0x01);
}

function int check_cast_conditions(obj user, loc usedon, int mana_cost) {
	loc caster_loc = getLocation(user);
	if ((!areSpellsOkay(usedon)) || (!areSpellsOkay(caster_loc))) {
		barkToHued(user, user, 0x22, "You can not cast spells here.");
		return(0x00);
	}
	return(validate_cast_prereqs(user, mana_cost));
}

function int attempt_spell_cast(obj user, loc usedon, int spell_index, int from_scroll) {
	if (isPlayer(user)) {
		if (hasObjVar(user, "spellCastersLevel")) {
			removeObjVar(user, "spellCastersLevel");
		}
	}
	reveal_impl(user, 0x00);
	int circle = circle_from_index(spell_index);
	int mana_cost = mana_cost_for_circle(circle);
	if (!check_cast_conditions(user, usedon, mana_cost)) {
		return(0x00);
	}
	int circle_reduction = 0x00;
	if (from_scroll) {
		circle_reduction = 0x02;
	}
	int cast_time_ms = get_skill_threshold(circle - circle_reduction);
	if (testAndLearnSkill(user, SKILL_MAGERY, cast_time_ms, 0x28) <= 0x00) {
		return(0x00);
	}
	loseMana(user, mana_cost);
	return(0x01);
}

function int try_cast_spell(obj user, loc usedon, obj spell_item) {
	int from_scroll = is_loose_scroll(spell_item);
	int spell_index = get_spell_index(spell_item);
	return(attempt_spell_cast(user, usedon, spell_index, from_scroll));
}

function int consume_reagents(obj user, list reagents) {
	int reagent = 0x00;
	int missing = 0x00;
	for (int i = 0x00; (i < numInList(reagents)) && (missing == 0x00); i++) {
		reagent = reagents[i];
		if (getGeneric(user, reagent) <= 0x00) {
			missing = 0x01;
			break;
		}
	}
	if (missing == 0x01) {
		if (isPlayer(user)) {
			barkToHued(user, user, 0x22, "More reagents are needed for this spell.");
		}
		return(0x00);
	} else {
		for (int j = 0x00; j < numInList(reagents); j++) {
			reagent = reagents[j];
			destroyGeneric(user, reagent, 0x01);
		}
		return(0x01);
	}
	if (isPlayer(user)) {
		bark(user, "BUG! Please report: Invalid takeReagent return.");
	}
	return(0x00);
}

function void fizzle_spell(obj user) {
	if (isPlayer(user)) {
		barkTo(user, user, "The spell fizzles.");
	}
	doMobAnimation(user, 0x3735, 0x06, 0x1E, 0x00, 0x00);
	sfx(getLocation(user), 0x5C, 0x00);
	return();
}

function obj create_obj_at_z(int objtype, loc place) {
	int tile_height = getTileHeight(objtype);
	int z_max = getZ(place) + 0x10;
	int z_min = getZ(place) - 0x10;
	setZ(place, findGoodZ(place, z_min, z_max, tile_height, 0x01));
	if (getZ(place) != (0x00 - 0x80)) {
		return(createGlobalObjectAt(objtype, place));
	}
	return(NULL());
}

function int has_wall_at(loc where, int height) {
	list objects;
	int z = getZ(where);
	int z_top = z + height;
	getObjectsAtInZRange(objects, where, z, z_top);
	int num = numInList(objects);
	obj it;
	for (int i = 0x00; i < num; i++) {
		it = objects[i];
		if (hasScript(it, "crtwall")) {
			return(0x01);
		}
	}
	return(0x00);
}

function obj create_object_if_no_wall(int obj_type, loc place) {
	int tile_height = getTileHeight(obj_type);
	int upper_z = getZ(place) + 0x10;
	int lower_z = getZ(place) - 0x10;
	setZ(place, findGoodZ(place, lower_z, upper_z, tile_height, 0x01));
	if (getZ(place) != (0x00 - 0x80)) {
		if (!has_wall_at(place, tile_height)) {
			return(createGlobalObjectAt(obj_type, place));
		}
	}
	return(NULL());
}

function void get_spell_reagents(list reagents, int spell_index) {
	switch(spell_index) {
	case 0x00
		reagents = 0x0F7B, 0x0F88;
		break;
	case 0x01
		reagents = 0x0F84, 0x0F85, 0x0F86;
		break;
	case 0x02
		reagents = 0x0F85, 0x0F88;
		break;
	case 0x03
		reagents = 0x0F84, 0x0F85, 0x0F8D;
		break;
	case 0x04
		reagents = 0x0F7A, 0x0F88;
		break;
	case 0x05
		reagents = 0x0F8D, 0x0F8C;
		break;
	case 0x06
		reagents = 0x0F84, 0x0F8C, 0x0F8D;
		break;
	case 0x07
		reagents = 0x0F84, 0x0F88;
		break;
	case 0x08
		reagents = 0x0F7B, 0x0F86;
		break;
	case 0x09
		reagents = 0x0F86, 0x0F88;
		break;
	case 0x0A
		reagents = 0x0F84, 0x0F85;
		break;
	case 0x0B
		reagents = 0x0F88, 0x0F8D;
		break;
	case 0x0C
		reagents = 0x0F84, 0x0F8C, 0x0F8D;
		break;
	case 0x0D
		reagents = 0x0F7B, 0x0F8C;
		break;
	case 0x0E
		reagents = 0x0F84, 0x0F85, 0x0F8C;
		break;
	case 0x0F
		reagents = 0x0F86, 0x0F88;
		break;
	case 0x10
		reagents = 0x0F84, 0x0F86;
		break;
	case 0x11
		reagents = 0x0F7A, 0x0F8C;
		break;
	case 0x12
		reagents = 0x0F8C, 0x0F7B, 0x0F84;
		break;
	case 0x13
		reagents = 0x0F88;
		break;
	case 0x14
		reagents = 0x0F7B, 0x0F86;
		break;
	case 0x15
		reagents = 0x0F7B, 0x0F86;
		break;
	case 0x16
		reagents = 0x0F7B, 0x0F8C;
		break;
	case 0x17
		reagents = 0x0F7B, 0x0F84;
		break;
	case 0x18
		reagents = 0x0F84, 0x0F85, 0x0F86;
		break;
	case 0x19
		reagents = 0x0F84, 0x0F85, 0x0F86, 0x0F8C;
		break;
	case 0x1A
		reagents = 0x0F84, 0x0F88, 0x0F8C;
		break;
	case 0x1B
		reagents = 0x0F7A, 0x0F8D, 0x0F8C;
		break;
	case 0x1C
		reagents = 0x0F84, 0x0F85, 0x0F86, 0x0F8D;
		break;
	case 0x1D
		reagents = 0x0F7A, 0x0F86, 0x0F8C;
		break;
	case 0x1E
		reagents = 0x0F7A, 0x0F86, 0x0F8D;
		break;
	case 0x1F
		reagents = 0x0F7A, 0x0F7B, 0x0F86;
		break;
	case 0x20
		reagents = 0x0F7A, 0x0F86, 0x0F88;
		break;
	case 0x21
		reagents = 0x0F84, 0x0F7A, 0x0F8D, 0x0F8C;
		break;
	case 0x22
		reagents = 0x0F7B, 0x0F84, 0x0F88;
		break;
	case 0x23
		reagents = 0x0F84, 0x0F86, 0x0F8D;
		break;
	case 0x24
		reagents = 0x0F7A, 0x0F86, 0x0F88, 0x0F8C;
		break;
	case 0x25
		reagents = 0x0F84, 0x0F86, 0x0F8D;
		break;
	case 0x26
		reagents = 0x0F7A, 0x0F88, 0x0F8D;
		break;
	case 0x27
		reagents = 0x0F7B, 0x0F86, 0x0F8D;
		break;
	case 0x28
		reagents = 0x0F84, 0x0F86, 0x0F8C;
		break;
	case 0x29
		reagents = 0x0F7A, 0x0F88;
		break;
	case 0x2A
		reagents = 0x0F7A, 0x0F86, 0x0F8C;
		break;
	case 0x2B
		reagents = 0x0F7B, 0x0F88;
		break;
	case 0x2C
		reagents = 0x0F7A, 0x0F7B, 0x0F86;
		break;
	case 0x2D
		reagents = 0x0F84, 0x0F86, 0x0F88, 0x0F8C;
		break;
	case 0x2E
		reagents = 0x0F7A, 0x0F85, 0x0F8D;
		break;
	case 0x2F
		reagents = 0x0F7B, 0x0F8C;
		break;
	case 0x30
		reagents = 0x0F7A, 0x0F7B, 0x0F86, 0x0F8C;
		break;
	case 0x31
		reagents = 0x0F7A, 0x0F86, 0x0F8D, 0x0F8C;
		break;
	case 0x32
		reagents = 0x0F8D, 0x0F8C;
		break;
	case 0x33
		reagents = 0x0F7A, 0x0F86, 0x0F8C;
		break;
	case 0x34
		reagents = 0x0F86, 0x0F7A, 0x0F7B, 0x0F8D;
		break;
	case 0x35
		reagents = 0x0F7A, 0x0F84, 0x0F86, 0x0F8C;
		break;
	case 0x36
		reagents = 0x0F7B, 0x0F8D, 0x0F86, 0x0F8C;
		break;
	case 0x37
		reagents = 0x0F7B, 0x0F86, 0x0F8D;
		break;
	case 0x38
		reagents = 0x0F7B, 0x0F85, 0x0F86, 0x0F8C;
		break;
	case 0x39
		reagents = 0x0F7A, 0x0F7B, 0x0F86, 0x0F88;
		break;
	case 0x3A
		reagents = 0x0F7B, 0x0F84, 0x0F85;
		break;
	case 0x3B
		reagents = 0x0F7B, 0x0F86, 0x0F8D;
		break;
	case 0x3C
		reagents = 0x0F7B, 0x0F86, 0x0F8D, 0x0F8C;
		break;
	case 0x3D
		reagents = 0x0F7B, 0x0F86, 0x0F8D;
		break;
	case 0x3E
		reagents = 0x0F7B, 0x0F86, 0x0F8D, 0x0F8C;
		break;
	case 0x3F
		reagents = 0x0F7B, 0x0F86, 0x0F8D;
		break;
	}
	return();
}

function string get_spell_words(int spell_index) {
	string name;
	switch(spell_index) {
	case 0x00
		name = "Uus Jux";
		break;
	case 0x01
		name = "In Mani Ylem";
		break;
	case 0x02
		name = "Rel Wis";
		break;
	case 0x03
		name = "In Mani";
		break;
	case 0x04
		name = "In Por Ylem";
		break;
	case 0x05
		name = "In Lor";
		break;
	case 0x06
		name = "Flam Sanct";
		break;
	case 0x07
		name = "Des Mani";
		break;
	case 0x08
		name = "Ex Uus";
		break;
	case 0x09
		name = "Uus Wis";
		break;
	case 0x0A
		name = "An Nox";
		break;
	case 0x0B
		name = "An Mani";
		break;
	case 0x0C
		name = "In Jux";
		break;
	case 0x0D
		name = "An Jux";
		break;
	case 0x0E
		name = "Uus Sanct";
		break;
	case 0x0F
		name = "Uus Mani";
		break;
	case 0x10
		name = "Rel Sanct";
		break;
	case 0x11
		name = "Vas Flam";
		break;
	case 0x12
		name = "An Por";
		break;
	case 0x13
		name = "In Nox";
		break;
	case 0x14
		name = "Ort Por Ylem";
		break;
	case 0x15
		name = "Rel Por";
		break;
	case 0x16
		name = "Ex Por";
		break;
	case 0x17
		name = "In Sanct Ylem";
		break;
	case 0x18
		name = "Vas An Nox";
		break;
	case 0x19
		name = "Vas Uus Sanct";
		break;
	case 0x1A
		name = "Des Sanct";
		break;
	case 0x1B
		name = "In Flam Grav";
		break;
	case 0x1C
		name = "In Vas Mani";
		break;
	case 0x1D
		name = "Por Ort Grav";
		break;
	case 0x1E
		name = "Ort Rel";
		break;
	case 0x1F
		name = "Kal Ort Por";
		break;
	case 0x20
		name = "In Jux Hur Ylem";
		break;
	case 0x21
		name = "An Grav";
		break;
	case 0x22
		name = "Kal In Ex";
		break;
	case 0x23
		name = "In Jux Sanct";
		break;
	case 0x24
		name = "Por Corp Wis";
		break;
	case 0x25
		name = "An Ex Por";
		break;
	case 0x26
		name = "In Nox Grav";
		break;
	case 0x27
		name = "Kal Xen";
		break;
	case 0x28
		name = "An Ort";
		break;
	case 0x29
		name = "Corp Por";
		break;
	case 0x2A
		name = "Vas Ort Flam";
		break;
	case 0x2B
		name = "An Lor Xen";
		break;
	case 0x2C
		name = "Kal Por Ylem";
		break;
	case 0x2D
		name = "Vas Des Sanct";
		break;
	case 0x2E
		name = "In Ex Grav";
		break;
	case 0x2F
		name = "Wis Quas";
		break;
	case 0x30
		name = "Vas Ort Grav";
		break;
	case 0x31
		name = "In Sanct Grav";
		break;
	case 0x32
		name = "Kal Vas Flam";
		break;
	case 0x33
		name = "Vas Rel Por";
		break;
	case 0x34
		name = "Ort Sanct";
		break;
	case 0x35
		name = "Vas An Ort";
		break;
	case 0x36
		name = "Flam Kal Des Ylem";
		break;
	case 0x37
		name = "Vas Ylem Rel";
		break;
	case 0x38
		name = "In Vas Por";
		break;
	case 0x39
		name = "Vas Corp Por";
		break;
	case 0x3A
		name = "An Corp";
		break;
	case 0x3B
		name = "Kal Vas Xen Hur";
		break;
	case 0x3C
		name = "Kal Vas Xen Corp";
		break;
	case 0x3D
		name = "Kal Vas Xen Ylem";
		break;
	case 0x3E
		name = "Kal Vas Xen Flam";
		break;
	case 0x3F
		name = "Kal Vas Xen An Flam";
		break;
	}
	return(name);
}

function string get_spell_name(int spell_index) {
	string name;
	switch(spell_index) {
	case 0x00
		name = "Clumsy";
		break;
	case 0x01
		name = "Create Food";
		break;
	case 0x02
		name = "Feeblemind";
		break;
	case 0x03
		name = "Heal";
		break;
	case 0x04
		name = "Magic Arrow";
		break;
	case 0x05
		name = "Night Sight";
		break;
	case 0x06
		name = "Reactive Armor";
		break;
	case 0x07
		name = "Weaken";
		break;
	case 0x08
		name = "Agility";
		break;
	case 0x09
		name = "Cunning";
		break;
	case 0x0A
		name = "Cure";
		break;
	case 0x0B
		name = "Harm";
		break;
	case 0x0C
		name = "Magic Trap";
		break;
	case 0x0D
		name = "Magic Untrap";
		break;
	case 0x0E
		name = "Protection";
		break;
	case 0x0F
		name = "Strength";
		break;
	case 0x10
		name = "Bless";
		break;
	case 0x11
		name = "Fireball";
		break;
	case 0x12
		name = "Magic Lock";
		break;
	case 0x13
		name = "Poison";
		break;
	case 0x14
		name = "Telekinesis";
		break;
	case 0x15
		name = "Teleport";
		break;
	case 0x16
		name = "Unlock";
		break;
	case 0x17
		name = "Wall of Stone";
		break;
	case 0x18
		name = "Archcure";
		break;
	case 0x19
		name = "Archprotection";
		break;
	case 0x1A
		name = "Curse";
		break;
	case 0x1B
		name = "Fire Field";
		break;
	case 0x1C
		name = "Greater Heal";
		break;
	case 0x1D
		name = "Lightning";
		break;
	case 0x1E
		name = "Mana Drain";
		break;
	case 0x1F
		name = "Recall";
		break;
	case 0x20
		name = "Blade Spirits";
		break;
	case 0x21
		name = "Dispel Field";
		break;
	case 0x22
		name = "Incognito";
		break;
	case 0x23
		name = "Magic Reflection";
		break;
	case 0x24
		name = "Mind Blast";
		break;
	case 0x25
		name = "Paralyze";
		break;
	case 0x26
		name = "Poison Field";
		break;
	case 0x27
		name = "Summon Creature";
		break;
	case 0x28
		name = "Dispel";
		break;
	case 0x29
		name = "Energy Bolt";
		break;
	case 0x2A
		name = "Explosion";
		break;
	case 0x2B
		name = "Invisibility";
		break;
	case 0x2C
		name = "Mark";
		break;
	case 0x2D
		name = "Mass Curse";
		break;
	case 0x2E
		name = "Paralyze Field";
		break;
	case 0x2F
		name = "Reveal";
		break;
	case 0x30
		name = "Chain Lightning";
		break;
	case 0x31
		name = "Energy Field";
		break;
	case 0x32
		name = "Flamestrike";
		break;
	case 0x33
		name = "Gate Travel";
		break;
	case 0x34
		name = "Mana Vampire";
		break;
	case 0x35
		name = "Mass Dispel";
		break;
	case 0x36
		name = "Meteor Swarm";
		break;
	case 0x37
		name = "Polymorph";
		break;
	case 0x38
		name = "Earthquake";
		break;
	case 0x39
		name = "Energy Vortex";
		break;
	case 0x3A
		name = "Resurrection";
		break;
	case 0x3B
		name = "Summon Air Elemental";
		break;
	case 0x3C
		name = "Summon Daemon";
		break;
	case 0x3D
		name = "Summon Earth Elemental";
		break;
	case 0x3E
		name = "Summon Fire Elemental";
		break;
	case 0x3F
		name = "Summon Water Elemental";
		break;
	}
	return(name);
}

function string get_spell_script_name(int spell_index) {
	string name;
	switch(spell_index) {
	case 0x00
		name = "clumsy";
		break;
	case 0x01
		name = "creatfod";
		break;
	case 0x02
		name = "feblmind";
		break;
	case 0x03
		name = "heal";
		break;
	case 0x04
		name = "magarrow";
		break;
	case 0x05
		name = "nitesite";
		break;
	case 0x06
		name = "reactarm";
		break;
	case 0x07
		name = "weaken";
		break;
	case 0x08
		name = "agility";
		break;
	case 0x09
		name = "cunning";
		break;
	case 0x0A
		name = "cure";
		break;
	case 0x0B
		name = "harm";
		break;
	case 0x0C
		name = "magctrap";
		break;
	case 0x0D
		name = "mguntrap";
		break;
	case 0x0E
		name = "protect";
		break;
	case 0x0F
		name = "strength";
		break;
	case 0x10
		name = "bless";
		break;
	case 0x11
		name = "fireball";
		break;
	case 0x12
		name = "magclock";
		break;
	case 0x13
		name = "poison";
		break;
	case 0x14
		name = "telknsis";
		break;
	case 0x15
		name = "teleport";
		break;
	case 0x16
		name = "unlock";
		break;
	case 0x17
		name = "wallston";
		break;
	case 0x18
		name = "archcure";
		break;
	case 0x19
		name = "aprotect";
		break;
	case 0x1A
		name = "curse";
		break;
	case 0x1B
		name = "firefild";
		break;
	case 0x1C
		name = "grtheal";
		break;
	case 0x1D
		name = "lightng";
		break;
	case 0x1E
		name = "manadran";
		break;
	case 0x1F
		name = "recall";
		break;
	case 0x20
		name = "bldsprts";
		break;
	case 0x21
		name = "dsplfild";
		break;
	case 0x22
		name = "incognto";
		break;
	case 0x23
		name = "magrflct";
		break;
	case 0x24
		name = "mindblst";
		break;
	case 0x25
		name = "paralyze";
		break;
	case 0x26
		name = "posnfild";
		break;
	case 0x27
		name = "summoncr";
		break;
	case 0x28
		name = "dispel";
		break;
	case 0x29
		name = "nrgybolt";
		break;
	case 0x2A
		name = "exploson";
		break;
	case 0x2B
		name = "invis";
		break;
	case 0x2C
		name = "mark";
		break;
	case 0x2D
		name = "mascurse";
		break;
	case 0x2E
		name = "parafild";
		break;
	case 0x2F
		name = "reveal";
		break;
	case 0x30
		name = "chainltg";
		break;
	case 0x31
		name = "nrgyfild";
		break;
	case 0x32
		name = "flamstrk";
		break;
	case 0x33
		name = "gatetrvl";
		break;
	case 0x34
		name = "manavamp";
		break;
	case 0x35
		name = "massdspl";
		break;
	case 0x36
		name = "meteor";
		break;
	case 0x37
		name = "polymrph";
		break;
	case 0x38
		name = "earthquk";
		break;
	case 0x39
		name = "nrgyvrtx";
		break;
	case 0x3A
		name = "resurect";
		break;
	case 0x3B
		name = "sumaire";
		break;
	case 0x3C
		name = "sumdaem";
		break;
	case 0x3D
		name = "sumearth";
		break;
	case 0x3E
		name = "sumfire";
		break;
	case 0x3F
		name = "sumh2o";
		break;
	}
	return(name);
}

function int spell_num_to_circle(int num) {
	return((num / 0x08) + 0x01);
}

function int get_scroll_objtype(int num) {
	if ((num < 0x00) || (num > 0x3F)) {
		return(0x00 - 0x01);
	}
	int objtype;
	if (num == 0x06) {
		objtype = 0x1F2D;
	} else {
		if ((num >= 0x00) && (num <= 0x05)) {
			objtype = 0x1F2E + num;
		} else {
			objtype = 0x1F34 + num - 0x07;
		}
	}
	return(objtype);
}

function int get_spell_obj_type(int num) {
	return(get_scroll_objtype(num - 0x01));
}

function string get_spell_name_by_num(int spell_num) {
	return(get_spell_script_name(spell_num - 0x01));
}

function int check_and_consume_reagents(obj user, obj spell_item) {
	if (is_loose_scroll(spell_item)) {
		return(0x01);
	}
	list reagents;
	get_spell_reagents(reagents, get_spell_index(spell_item));
	return(consume_reagents(user, reagents));
}

function int can_drink_potion(obj user) {
	obj rightHand = getItemAtSlot(user, EQUIP_RIGHT_HAND);
	obj leftHand = getItemAtSlot(user, EQUIP_LEFT_HAND);
	if (leftHand != NULL()) {
		if (isWeapon(leftHand)) {
			barkToHued(user, user, 0x22, "You must have a free hand to drink a potion.");
			return(0x00);
		}
		if (rightHand != NULL()) {
			barkToHued(user, user, 0x22, "You must have a free hand to drink a potion.");
			return(0x00);
		}
	}
	return(0x01);
}

function int setup_follower(obj creature, obj boss, int loyalty, int is_pet) {
	list myBoss = boss;
	setObjVar(creature, "myBoss", myBoss);
	setObjVar(creature, "myLoyalty", loyalty);
	if (is_pet) {
		setObjVar(creature, "isPet", 0x01);
	}
	makeBeelineFailPathfind(creature, 0x01);
	disableBehaviors(creature);
	attachScript(creature, "pet");
	return(0x01);
}

function int damage_to_resist_difficulty(int damage) {
	int scaled = damage * 0x19;
	if (scaled > 0x03E8) {
		scaled = 0x03E8;
	}
	return(scaled);
}

function int circle_to_resist_difficulty(int circle) {
	int scaled = circle * 0x32;
	if (scaled > 0x03E8) {
		scaled = 0x03E8;
	}
	return(scaled);
}

function int apply_magic_resist_with_learn(obj user, obj usedon, int damage) {
	if (isDead(usedon)) {
		return(0x00);
	}
	if (testAndLearnSkill(usedon, SKILL_MAGIC_RESIST, damage_to_resist_difficulty(damage), 0x32) > 0x00) {
		systemMessage(usedon, "You feel yourself resisting magical energy!");
		return((damage + 0x01) / 0x02);
	}
	return(damage);
}

function int apply_magic_resist_no_learn(obj user, obj usedon, int damage) {
	if (isDead(usedon)) {
		return(0x00);
	}
	if (roll_skill_check(usedon, SKILL_MAGIC_RESIST, damage_to_resist_difficulty(damage), 0x28) > 0x00) {
		systemMessage(usedon, "You feel yourself resisting magical energy!");
		return((damage + 0x01) / 0x02);
	}
	return(damage);
}

function int check_magic_resist_with_learn(obj user, obj usedon, int circle_level) {
	if (isDead(usedon)) {
		return(0x00);
	}
	if (testAndLearnSkill(usedon, SKILL_MAGIC_RESIST, circle_to_resist_difficulty(circle_level), 0x32) > 0x00) {
		systemMessage(usedon, "You feel yourself resisting magical energy!");
		return(0x01);
	}
	return(0x00);
}

function int test_magic_resist(obj user, obj usedon, int circle_level) {
	if (isDead(usedon)) {
		return(0x00);
	}
	if (roll_skill_check(usedon, SKILL_MAGIC_RESIST, circle_to_resist_difficulty(circle_level), 0x28) > 0x00) {
		systemMessage(usedon, "You feel yourself resisting magical energy!");
		return(0x01);
	}
	return(0x00);
}

function void report_obj_aggression(obj user, obj usedon, int num, int swapped) {
	if (user == usedon) {
		return();
	}
	obj aggressor = user;
	obj victim = usedon;
	if (swapped) {
		aggressor = usedon;
		victim = user;
	}
	if (getCompileFlag(0x01)) {
		if (!canBeFreelyAggressedBy(victim, aggressor)) {
			committedCrimeAt(aggressor, getLocation(victim), 0x01E0);
		}
	} else {
		callGuards(aggressor, getLocation(victim), num);
	}
	return();
}

function void report_loc_aggression(obj user, loc where, int num, int swapped) {
	if (getCompileFlag(0x01)) {
		committedCrimeAt(user, where, 0x01E0);
	} else {
		callGuards(user, where, num);
	}
	return();
}

function int is_reflected(obj user, obj target) {
	int reflected = 0x00;
	if (hasScript(target, "reflctor")) {
		reflected = 0x01;
	}
	return(reflected);
}

function int is_human(obj it) {
	return(isHuman(it));
}

function int clamp_damage_in_justice_region(obj caster, obj target, int damage) {
	int adjusted_damage = damage;
	int human_flag = 0x01;
	int caster_in_justice = 0x00;
	if (caster != NULL()) {
		loc caster_loc = getLocation(caster);
		caster_in_justice = inJusticeRegion(caster_loc);
		if (isNPC(caster)) {
			if (!is_human(caster)) {
				human_flag = 0x00;
			}
		}
	}
	int target_in_justice = 0x00;
	if (target != NULL()) {
		loc target_loc = getLocation(target);
		target_in_justice = inJusticeRegion(target_loc);
		if (isNPC(target)) {
			if (!is_human(target)) {
				human_flag = 0x00;
			}
		}
	}
	if (human_flag && (caster_in_justice || target_in_justice)) {
		adjusted_damage = 0x00;
	}
	return(adjusted_damage);
}

function void apply_damage_clamped(obj caster, obj target, int damage, int reverse) {
	int clamped_damage = clamp_damage_in_justice_region(caster, target, damage);
	if (reverse) {
		doDamage(target, caster, 0x00);
	}
	doDamage(caster, target, clamped_damage);
	return();
}

function void apply_typed_damage_clamped(obj caster, obj target, int damage, int damage_type, int reverse) {
	int clamped_damage = clamp_damage_in_justice_region(caster, target, damage);
	if (reverse) {
		doDamage(target, caster, 0x00);
	}
	doDamageType(caster, target, clamped_damage, damage_type);
	return();
}

function int target_in_z_range(obj source, obj target) {
	if (isCounselor(target)) {
		return(0x00);
	}
	int in_range = 0x00;
	loc src_loc = getLocation(source);
	int src_z = getZ(src_loc);
	loc tgt_loc = getLocation(target);
	int tgt_z = getZ(tgt_loc);
	int z_range = 0x08;
	if (tgt_z >= src_z) {
		int z_ceiling = src_z + z_range;
		if (tgt_z <= z_ceiling) {
			in_range = 0x01;
		}
	}
	return(in_range);
}

function void normalize_scroll_scripts(obj scroll, string spell_script) {
	if (spell_script == "") {
		return();
	}
	string type_script;
	int objtype = getObjType(scroll);
	type_script = objtype;
	if (!hasScript(scroll, type_script)) {
		attachScript(scroll, type_script);
	}
	if (!hasScript(scroll, spell_script)) {
		attachScript(scroll, spell_script);
	}
	if (hasScript(scroll, "magscroll")) {
		detachScript(scroll, "magscroll");
	}
	list scripts;
	getScripts(scripts, scroll);
	int spell_count = 0x00;
	int type_count = 0x00;
	int magscroll_count = 0x00;
	int vended_count = 0x00;
	int keep = 0x00;
	int script_count = numInList(scripts);
	for (int i = 0x00; i < script_count; i++) {
		keep = 0x00;
		string script_name = scripts[i];
		if (script_name == spell_script) {
			spell_count++;
			keep = 0x01;
		}
		if (script_name == type_script) {
			type_count++;
			keep = 0x01;
		}
		if (script_name == "vended") {
			vended_count++;
			keep = 0x01;
		}
		if (!keep) {
			detachScript(scroll, script_name);
		}
	}
	return();
}

function void validate_and_configure_scroll(obj scroll) {
	int spell_num = getMiscData(scroll);
	int objtype = getObjType(scroll);
	if (objtype != get_spell_obj_type(spell_num)) {
		deleteObject(scroll);
		return();
	}
	normalize_scroll_scripts(scroll, get_spell_name_by_num(spell_num));
	return();
}

function int get_stat_dir(int stat, int delta) {
	int num = 0x00;
	switch(stat) {
	case 0x00
		if (delta > 0x00) {
			num = 0x01;
		} else {
			num = 0x02;
		}
		break;
	case 0x01
		if (delta > 0x00) {
			num = 0x03;
		} else {
			num = 0x04;
		}
		break;
	case 0x02
		if (delta > 0x00) {
			num = 0x05;
		} else {
			num = 0x06;
		}
		break;
	}
	return(num);
}

function string get_stat_effect_script_name(int stat_type, int delta) {
	string script_name;
	int num = get_stat_dir(stat_type, delta);
	switch(num) {
	case 0x01
		script_name = "strup";
		break;
	case 0x02
		script_name = "strdown";
		break;
	case 0x03
		script_name = "dexup";
		break;
	case 0x04
		script_name = "dexdown";
		break;
	case 0x05
		script_name = "intup";
		break;
	case 0x06
		script_name = "intdown";
		break;
	}
	return(script_name);
}

function int get_stat_effect_callback_type(int stat_type, int delta) {
	int num = get_stat_dir(stat_type, delta);
	int callback_type = 0x00;
	switch(num) {
	case 0x01
		callback_type = 0x67;
		break;
	case 0x02
		callback_type = 0x68;
		break;
	case 0x03
		callback_type = 0x69;
		break;
	case 0x04
		callback_type = 0x6A;
		break;
	case 0x05
		callback_type = 0x6B;
		break;
	case 0x06
		callback_type = 0x6C;
		break;
	}
	return(callback_type);
}

function int has_stat_effect(obj user, int stat_type, int delta) {
	if (delta == 0x00) {
		return(0x00);
	}
	return(hasScript(user, get_stat_effect_script_name(stat_type, delta)));
}

function void apply_stat_effect(obj user, int stat_type, int delta, int duration) {
	if (delta == 0x00) {
		return();
	}
	if (!isMobile(user)) {
		return();
	}
	string effect_script = get_stat_effect_script_name(stat_type, delta);
	int callback_type = get_stat_effect_callback_type(stat_type, delta);
	setObjVar(user, effect_script, delta);
	int stat_result = modifyStat(user, stat_type, delta);
	attachScript(user, effect_script);
	callback(user, duration, callback_type);
	return();
}

function void apply_stat_mod(obj user, int stat, int delta) {
	if (!isMobile(user)) {
		return();
	}
	if (delta == 0x00) {
		return();
	}
	int result = modifyStat(user, stat, delta);
	return();
}

function int apply_stat_effect_if_absent(obj user, int stat_type, int delta, int duration) {
	if (delta == 0x00) {
		return(0x01);
	}
	if (!isMobile(user)) {
		return(0x00);
	}
	if (!has_stat_effect(user, stat_type, delta)) {
		apply_stat_effect(user, stat_type, delta, duration);
		return(0x01);
	}
	return(0x00);
}

function int get_stat_effect_sfx_id(int stat_type, int delta) {
	int num = get_stat_dir(stat_type, delta);
	switch(num) {
	case 0x01
		return(0x01EE);
	case 0x02
		return(0x01E6);
	case 0x03
		return(0x01E7);
	case 0x04
		return(0x01DF);
	case 0x05
		return(0x01EB);
	case 0x06
		return(0x01E4);
	}
	return(0x00);
}

function int get_stat_change_anim(int stat, int is_buff) {
	if (is_buff) {
		return(0x375A);
	} else {
		return(0x3779);
	}
	return(0x00);
}

function int has_reflection(obj it) {
	return(hasScript(it, "reflctor"));
}

function void remove_stat_effect(obj it, int stat_type, int is_up) {
	int delta = 0x01;
	if (!is_up) {
		delta = 0x00 - 0x01;
	}
	if (!isMobile(it)) {
		return();
	}
	string name = get_stat_effect_script_name(stat_type, delta);
	if (hasObjVar(it, name)) {
		delta = getObjVar(it, name);
		apply_stat_mod(it, stat_type, 0x00 - delta);
		removeObjVar(it, name);
	}
	if (hasScript(it, name)) {
		detachScript(it, name);
	}
	return();
}

function void cure_poison(obj it) {
	setPoisoned(it, 0x00);
	if (hasObjVar(it, "poison_strength")) {
		removeObjVar(it, "poison_strength");
	}
	detachScript(it, "poisoned");
	handleHealthGain(it);
	return();
}

function void notify_spell_hit(obj caster, obj target, int reflected) {
	if (reflected) {
		scriptTrig(caster, 0x01, target);
	} else {
		scriptTrig(target, 0x01, caster);
	}
	return();
}

function int check_target_in_range(obj caster, obj m_target, int reflected) {
	obj user = caster;
	obj usedon = m_target;
	if (reflected) {
		user = m_target;
		usedon = caster;
	}
	if (usedon == NULL()) {
		return(0x00);
	}
	if (m_target != NULL()) {
		if (getTopmostContainer(m_target) != caster) {
			if (!canSeeObj(user, usedon)) {
				systemMessage(user, "Target can not be seen.");
				return(0x00);
			}
			if (getDistanceInTiles(getLocation(user), getLocation(usedon)) > 0x0C) {
				systemMessage(user, "Target is too far away.");
				return(0x00);
			}
		}
	}
	return(0x01);
}

function int is_worn_spellbook(obj item) {
	int type = getObjType(item);
	switch(type) {
	case 0x0DF2
	case 0x0DF3
	case 0x0DF4
	case 0x0DF5
	case 0x13F8
	case 0x13F9
		return(0x01);
		break;
	}
	return(0x00);
}

function int validate_spell_use(obj item, obj user_obj, obj m_target, int reverse) {
	if (m_target == NULL()) {
		return(0x00);
	}
	if (is_worn_spellbook(item)) {
		if ((!isEquipped(item)) || (containedBy(item) != user_obj)) {
			systemMessage(user_obj, "You must equip this item to use it.");
			return(0x00);
		}
	}
	return(check_target_in_range(user_obj, m_target, reverse));
}

function void remove_reflection(obj it) {
	if (hasScript(it, "reflctor")) {
		doMobAnimation(it, 0x37B9, 0x0A, 0x05, 0x00, 0x00);
		detachScript(it, "reflctor");
	}
	return();
}

function int roll_spell_damage(int circle) {
	int num;
	int die;
	int bonus;
	switch(circle) {
	case 0x01
		num = 0x01;
		die = 0x03;
		bonus = 0x03;
		break;
	case 0x02
		num = 0x01;
		die = 0x08;
		bonus = 0x04;
		break;
	case 0x03
		num = 0x04;
		die = 0x04;
		bonus = 0x04;
		break;
	case 0x04
		num = 0x03;
		die = 0x08;
		bonus = 0x05;
		break;
	case 0x05
		num = 0x05;
		die = 0x08;
		bonus = 0x06;
		break;
	case 0x06
		num = 0x06;
		die = 0x08;
		bonus = 0x08;
		break;
	case 0x07
		num = 0x07;
		die = 0x08;
		bonus = 0x0A;
		break;
	case 0x08
		num = 0x07;
		die = 0x08;
		bonus = 0x0A;
		break;
	default
		return(0x00);
		break;
	}
	int damage = (num * random(0x01, die)) + bonus;
	return(damage);
}

function int scale_damage_by_skill(int skill_bonus, int damage) {
	int scaled = (damage * (0x32 + skill_bonus)) / 0x64;
	return(scaled);
}

function int scale_damage_by_magery(obj spell_obj, obj caster, int damage) {
	int skill_bonus = 0x00;
	if (isValid(spell_obj)) {
		if (hasObjVar(spell_obj, "magicItemDamage")) {
			int item_damage_mod = getObjVar(spell_obj, "magicItemDamage");
			skill_bonus = item_damage_mod * 0x0A;
		} else {
			if (isValid(caster)) {
				if (isMobile(caster)) {
					skill_bonus = getSkillLevel(caster, SKILL_MAGERY);
				}
			}
		}
	} else {
		if (isValid(caster)) {
			if (isMobile(caster)) {
				skill_bonus = getSkillLevel(caster, SKILL_MAGERY);
			}
		}
	}
	return(scale_damage_by_skill(skill_bonus, damage));
}

function int apply_spell_damage_typed(obj spell, int base_damage, obj src_caster, obj dest, int damage_type, int reverse) {
	int damage = base_damage;
	if (isNPC(dest)) {
		damage = base_damage * 0x02;
	}
	obj caster = src_caster;
	if (reverse) {
		caster = dest;
	}
	damage = scale_damage_by_magery(spell, caster, damage);
	if (isValid(dest)) {
		if (inJusticeRegion(getLocation(dest))) {
			damage = apply_magic_resist_no_learn(src_caster, dest, damage);
		} else {
			damage = apply_magic_resist_with_learn(src_caster, dest, damage);
		}
	}
	apply_typed_damage_clamped(src_caster, dest, damage, damage_type, reverse);
	return(damage);
}

function int apply_spell_damage_by_circle(obj spell, int circle, obj caster, obj dest, int damage_type, int reverse) {
	int damage = roll_spell_damage(circle);
	return(apply_spell_damage_typed(spell, damage, caster, dest, damage_type, reverse));
}

function int apply_spell_damage(obj spell, obj caster, obj dest, int damage_type, int reverse) {
	int circle = get_spell_circle(spell);
	return(apply_spell_damage_by_circle(spell, circle, caster, dest, damage_type, reverse));
}

function int apply_typed_damage_to_targets(int range, obj spell, int base_damage, obj caster, list targets, int damage_type) {
	int num = numInList(targets);
	int damage = base_damage;
	if (num > 0x01) {
		damage = damage * 0x02;
	}
	int damage_per_target = damage / num;
	if ((base_damage > 0x00) && (damage_per_target <= 0x00)) {
		damage_per_target = 0x01;
	}
	obj m_target;
	int applied_damage;
	loc caster_loc = getLocation(caster);
	loc target_loc;
	int dist;
	int unused;
	for (int i = 0x00; i < num; i++) {
		m_target = targets[i];
		if (isValid(m_target)) {
			target_loc = getLocation(m_target);
			dist = getDistanceInTiles(caster_loc, target_loc);
			applied_damage = apply_spell_damage_typed(spell, damage_per_target, caster, m_target, damage_type, 0x00);
			scriptTrig(m_target, 0x01, caster);
		}
	}
	return(base_damage);
}

function int apply_circle_damage_to_targets(int range, obj spell, int circle, obj caster, list targets, int damage_type) {
	int damage = roll_spell_damage(circle);
	return(apply_typed_damage_to_targets(range, spell, damage, caster, targets, damage_type));
}

function int apply_circle_damage(int range, obj spell, obj caster, list targets, int damage_type) {
	int circle = get_spell_circle(spell);
	return(apply_circle_damage_to_targets(range, spell, circle, caster, targets, damage_type));
}

function void schedule_callback_if_idle(obj m_target, int cb_id, int min_delay, int max_delay) {
	if (!hasCallback(m_target, cb_id)) {
		shortcallback(m_target, random(min_delay, max_delay), cb_id);
	}
	return();
}

function int adjust_notoriety(obj it, int delta, int max, int min) {
	if (!isValid(it)) {
		return(0x00);
	}
	int current;
	current = getNotoriety(it);
	int new_val = current + delta;
	if (delta > 0x00) {
		if (current > max) {
			new_val = current;
		} else {
			if (new_val > max) {
				new_val = max;
			}
		}
	}
	if (delta < 0x00) {
		if (current < min) {
			new_val = current;
		} else {
			if (new_val < min) {
				new_val = min;
			}
		}
	}
	if (new_val != current) {
		setNotoriety(it, new_val);
		return(0x01);
	}
	return(0x00);
}

function int apply_helpful_spell_notoriety(obj caster, obj dest, int reverse, int action_type, int circle_level) {
	obj aggressor = caster;
	obj recipient = dest;
	if (aggressor == recipient) {
		return(0x00);
	}
	if (reverse) {
		aggressor = dest;
		recipient = caster;
	}
	if (getCompileFlag(0x01)) {
		if (action_type == 0x01) {
			receiveHelpfulActionFrom(recipient, aggressor);
			int value = getKarma(recipient) / 0x05;
			changeKarma(aggressor, value);
		}
	}
	if (!getCompileFlag(0x01)) {
		int notoriety_cmp = NotorietyCompare(aggressor, recipient);
		if ((action_type == 0x01) && (notoriety_cmp == 0x01) && (!is_boss_of(recipient, aggressor))) {
			int delta = 0x00 - ((circle_level + 0x01) / 0x02);
			int min_bound = (0x00 - (((circle_level + 0x01) / 0x02) * 0x18));
			if (adjust_notoriety(aggressor, delta, 0x00, min_bound)) {
				systemMessage(aggressor, "That action is frowned upon.");
			}
			return(delta);
		}
	}
	return(0x00);
}

function int apply_spell_notoriety(obj caster, obj dest, int reverse, obj spell) {
	return(apply_helpful_spell_notoriety(caster, dest, reverse, 0x01, get_spell_circle(spell)));
}

function void target_hostile_obj(obj caster, obj spell) {
	superTargetObj(caster, spell, 0x01);
	return();
}

function void target_hostile_loc(obj caster, obj spell, int range) {
	superTargetLoc(caster, spell, 0x01, range);
	return();
}

function void target_friendly_obj(obj caster, obj spell) {
	superTargetObj(caster, spell, 0x02);
	return();
}

function void target_friendly_loc(obj caster, obj spell, int range) {
	superTargetLoc(caster, spell, 0x02, range);
	return();
}

function void set_criminal(obj mobile, int duration) {
	setCriminal(mobile, duration);
	return();
}

function loc find_summon_location(obj user_obj) {
	loc origin = getLocation(user_obj);
	loc spot = origin;
	int find = findGoodSpotNearMin(spot, 0x01, 0x01, 0x10, 0x01);
	if ((!find) || (!on_same_multi_as_loc(user_obj, spot)) || (!canSeeLoc(user_obj, spot))) {
		spot = (0x00 - 0x01), (0x00 - 0x01), (0x00 - 0x01);
	}
	return(spot);
}

function int get_wall_duration(obj caster, int circle) {
	return(0x0F + ((getSkillLevel(caster, SKILL_MAGERY) * 0x02) / circle));
}

function int is_casting(obj mobile) {
	if (hasCallback(mobile, 0x80)) {
		return(0x01);
	}
	return(0x00);
}

function int get_cast_delay(int circle, int spell_idx) {
	switch(spell_idx) {
	case 0x20
		return((circle + 0x01) * 0x05);
		break;
	case 0x27
		return((circle + 0x01) * 0x05);
		break;
	case 0x3B
		return((circle + 0x01) * 0x05);
		break;
	case 0x3C
		return((circle + 0x01) * 0x05);
		break;
	case 0x3D
		return((circle + 0x01) * 0x05);
		break;
	case 0x3E
		return((circle + 0x01) * 0x05);
		break;
	case 0x3F
		return((circle + 0x01) * 0x05);
		break;
	}
	return(circle + 0x01);
}

function int is_targeting(obj mobile) {
	return(hasScript(mobile, "targeting"));
}

function void begin_spell_cast(obj spell, obj caster) {
	if (is_casting(caster) || is_targeting(caster)) {
		systemMessage(caster, "You are already casting a spell.");
		return();
	}
	if (getMobFlag(caster, 0x02)) {
		systemMessage(caster, "You can not cast a spell while frozen.");
		return();
	}
	int spell_index = get_spell_index(spell);
	int circle = circle_from_index(spell_index);
	int mana_cost = mana_cost_for_circle(circle);
	if (!validate_cast_prereqs(caster, mana_cost)) {
		return();
	}
	setObjVar(caster, "spellObj", spell);
	attachScript(caster, "casting");
	int cast_delay_ticks = get_cast_delay(circle, spell_index);
	shortcallback(caster, cast_delay_ticks, 0x80);
	shortcallback(caster, 0x00, 0x82);
	bark(caster, get_spell_words(get_spell_index(spell)));
	return();
}

function obj get_caster_2(obj this, list args) {
	obj user = args[0x00];
	obj container = getTopmostContainer(this);
	if ((container != NULL()) && (container != user)) {
		user = NULL();
	}
	return(user);
}

function int is_teleporter(obj it) {
	if (hasScript(it, "teleporter")) {
		return(0x01);
	}
	if (hasScript(it, "dec_teleport")) {
		return(0x01);
	}
	if (hasScript(it, "des1_ankh_tele_1")) {
		return(0x01);
	}
	if (hasScript(it, "des1_ankh_tele_2")) {
		return(0x01);
	}
	if (hasScript(it, "despise_teleporter_four")) {
		return(0x01);
	}
	if (hasScript(it, "despise_teleporter_one")) {
		return(0x01);
	}
	if (hasScript(it, "despise_teleporter_three")) {
		return(0x01);
	}
	if (hasScript(it, "despise_teleporter_two")) {
		return(0x01);
	}
	if (hasScript(it, "dest_tele_one")) {
		return(0x01);
	}
	if (hasScript(it, "sha_tele_new")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter2")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter3")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter4")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter5")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter6")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleporter7")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teler_lever_2")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teler_switch")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleroom_lever")) {
		return(0x01);
	}
	if (hasScript(it, "sha_teleroom_wall")) {
		return(0x01);
	}
	if (hasScript(it, "trap_tele_gen_er_one")) {
		return(0x01);
	}
	return(0x00);
}

function int has_teleporter_in_range(loc where, int range) {
	list objects;
	getObjectsInRange(objects, where, range);
	int num = numInList(objects);
	for (int i = 0x00; i < num; i++) {
		obj it = objects[i];
		if (is_teleporter(it)) {
			return(0x01);
		}
	}
	return(0x00);
}

function int create_field_wall(obj user, int objtype, loc place, int new_type, int wall_type, int walldur, int is_harmful, int delay_ticks) {
	if (!canSeeLoc(user, place)) {
		return(0x00);
	}
	if (has_teleporter_in_range(place, 0x03)) {
		return(0x00);
	}
	obj wall_obj = create_object_if_no_wall(objtype, place);
	if (wall_obj != NULL()) {
		set_caster(wall_obj, user);
		copyControllerInfo(wall_obj, user);
		setObjVar(wall_obj, "newType", new_type);
		setObjVar(wall_obj, "walltype", wall_type);
		setObjVar(wall_obj, "walldur", walldur);
		attachScript(wall_obj, "crtwall");
		shortcallback(wall_obj, delay_ticks, 0x2E);
		if (!getCompileFlag(0x01)) {
			if (is_harmful) {
				report_loc_aggression(user, place, 0x01, 0x00);
			}
		}
		return(0x01);
	}
	return(0x00);
}

function void begin_targeting(obj user_obj, obj spell) {
	if (!is_targeting(user_obj)) {
		attachScript(user_obj, "targeting");
	}
	setObjVar(user_obj, "targetingForObj", spell);
	return();
}

function int confirm_and_clear_targeting(obj user_obj, obj spell) {
	if (!is_targeting(user_obj)) {
		return(0x00);
	}
	obj targeting_obj;
	targeting_obj = getObjVar(user_obj, "targetingForObj");
	if (spell != targeting_obj) {
		return(0x00);
	}
	detachScript(user_obj, "targeting");
	removeObjVar(user_obj, "targetingForObj");
	return(0x01);
}

function int is_spell_guaranteed_success(obj caster, int circle) {
	if (getSkillSuccessChance(caster, SKILL_MAGERY, get_skill_threshold(circle), 0x28) >= 0x01F4) {
		return(0x01);
	}
	return(0x00);
}

function int can_attempt_spell(obj caster, int circle) {
	if (getSkillSuccessChance(caster, SKILL_MAGERY, get_skill_threshold(circle), 0x28) > 0x00) {
		return(0x01);
	}
	return(0x00);
}

function int can_target_victim(obj caster, obj victim) {
	if (caster == victim) {
		return(0x00);
	}
	if (getMobFlag(victim, 0x02)) {
		return(0x00);
	}
	if (isInvulnerable(victim)) {
		return(0x00);
	}
	return(0x01);
}

function void scatter_npc(obj it) {
	if (isNPC(it)) {
		if (can_target_victim(NULL(), it)) {
			loc where = getLocation(it);
			setX(where, getX(where) + random(0x00, 0x0A) - 0x05);
			setY(where, getY(where) + random(0x00, 0x0A) - 0x05);
			walkTo(it, where, 0x17);
		}
	}
	return();
}

function int can_teleport_in(loc where) {
	if (isInRegionWithPrefix("teleportation_in_no", where)) {
		return(0x00);
	}
	return(0x01);
}

function int can_teleport_out(loc where) {
	if (isInRegionWithPrefix("teleportation_out_no", where)) {
		return(0x00);
	}
	return(0x01);
}

function int check_visible_range(obj user, obj usedon, int range) {
	if (!canSeeObj(user, usedon)) {
		systemMessage(user, "Target cannot be seen.");
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(user), getLocation(usedon)) > range) {
		systemMessage(user, "Target is too far away.");
		return(0x00);
	}
	return(0x01);
}

function int is_gate(obj it) {
	int obj_type = getObjType(it);
	switch(obj_type) {
	case 0x0F6C
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int has_gate_at_loc(loc where, obj exclude) {
	list objects;
	getObjectsAt(objects, where);
	int num = numInList(objects);
	for (int i = 0x00; i < num; i++) {
		obj it = objects[i];
		if (it != exclude) {
			if (is_gate(it)) {
				return(0x01);
			}
		}
	}
	return(0x00);
}

function int gate_exists_at(loc where) {
	return(has_gate_at_loc(where, NULL()));
}

function int is_targetable_mobile(obj usedon) {
	if (isMobile(usedon)) {
		if (!isDead(usedon)) {
			if (!isCounselor(usedon)) {
				if (!getMobFlag(usedon, 0x01)) {
					return(0x01);
				}
			}
		}
	}
	return(0x00);
}

function int is_valid_obj(obj usedon) {
	return(isValid(usedon));
}

function int is_in_map(loc place) {
	return(isInMap(place));
}

function void schedule_cleanup(obj it) {
	shortcallback(it, 0x01, 0x48);
	return();
}

function void schedule_cleanup_if_miss(obj it, int hit) {
	if (!hit) {
		shortcallback(it, 0x01, 0x48);
	}
	return();
}
