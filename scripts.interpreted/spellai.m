inherits spelskil;

member int cur_mana;

member int caster_level;

member int initial_hp;

member int prev_hp;

member int max_hp;

member int last_damage_taken;

member int difficulty;

member int magery_difficulty;

member int attack_difficulty;

member int difficulty_roll_min;

member int selected_spell_level;

member int hp_threshold_high;

member int hp_heal_threshold;

member int hp_threshold_low;

member int hp_threshold_critical;

member int adjusted_spell_level;

member int spell_scroll_type;

forward void try_cast_spell(obj caster);

forward int spend_mana(obj user, int mana_cost);

forward int get_alt_spell_idx(int selected_spell_level);

forward void pick_and_cast_spell(obj caster);

member list spell_list;

function int calc_percent(int maxValue, int percent) {
	return((maxValue * percent) / 0x64);
}

function int get_base_floor() {
	magery_difficulty = 0x00;
	attack_difficulty = 0x00;
	if (cur_mana < 0x4E) {
		magery_difficulty++;
	}
	if (cur_mana < 0x1A) {
		magery_difficulty++;
	}
	if (cur_mana < 0x10) {
		magery_difficulty++;
	}
	if (cur_mana < 0x0A) {
		magery_difficulty++;
	}
	if (cur_mana < 0x06) {
		magery_difficulty++;
	}
	if (caster_level < 0x08) {
		attack_difficulty++;
	}
	if (caster_level < 0x06) {
		attack_difficulty++;
	}
	if (caster_level < 0x05) {
		attack_difficulty++;
	}
	if (caster_level < 0x04) {
		attack_difficulty++;
	}
	if (caster_level < 0x03) {
		attack_difficulty++;
	}
	if (magery_difficulty < attack_difficulty) {
		difficulty = attack_difficulty;
	} else {
		difficulty = magery_difficulty;
	}
	string mana_pen = magery_difficulty;
	string level_pen = attack_difficulty;
	string b = difficulty;
	return(difficulty);
}

function int get_offense_floor() {
	magery_difficulty = 0x00;
	attack_difficulty = 0x00;
	if (cur_mana < 0x4E) {
		magery_difficulty++;
	}
	if (cur_mana < 0x1A) {
		magery_difficulty++;
	}
	if (cur_mana < 0x10) {
		magery_difficulty++;
	}
	if (cur_mana < 0x0A) {
		magery_difficulty++;
	}
	if (cur_mana < 0x06) {
		magery_difficulty++;
	}
	if (cur_mana < 0x04) {
		magery_difficulty++;
	}
	if (caster_level < 0x07) {
		attack_difficulty++;
	}
	if (caster_level < 0x06) {
		attack_difficulty++;
		attack_difficulty++;
	}
	if (caster_level < 0x05) {
		attack_difficulty++;
	}
	if (caster_level < 0x04) {
		attack_difficulty++;
	}
	if (caster_level < 0x03) {
		attack_difficulty++;
	}
	if (caster_level < 0x02) {
		attack_difficulty++;
	}
	if (magery_difficulty < attack_difficulty) {
		difficulty = attack_difficulty;
	} else {
		difficulty = magery_difficulty;
	}
	string mana_pen = magery_difficulty;
	string level_pen = attack_difficulty;
	string b = difficulty;
	return(difficulty);
}

function int get_neutral_floor() {
	magery_difficulty = 0x00;
	attack_difficulty = 0x00;
	if (cur_mana < 0x34) {
		magery_difficulty++;
	}
	if (cur_mana < 0x10) {
		magery_difficulty++;
	}
	if (caster_level < 0x07) {
		attack_difficulty++;
	}
	if (caster_level < 0x05) {
		attack_difficulty++;
	}
	if (magery_difficulty < attack_difficulty) {
		difficulty = attack_difficulty;
	} else {
		difficulty = magery_difficulty;
	}
	string mana_pen = magery_difficulty;
	string level_pen = attack_difficulty;
	string b = difficulty;
	return(difficulty);
}

function int get_good_floor() {
	magery_difficulty = 0x00;
	attack_difficulty = 0x00;
	if (cur_mana < 0x06) {
		magery_difficulty++;
	}
	if (caster_level < 0x04) {
		attack_difficulty++;
	}
	if (magery_difficulty < attack_difficulty) {
		difficulty = attack_difficulty;
	} else {
		difficulty = magery_difficulty;
	}
	string mana_pen = magery_difficulty;
	string level_pen = attack_difficulty;
	string b = difficulty;
	return(difficulty);
}

function int pick_offensive_spell_level() {
	selected_spell_level = 0x00;
	if (random(0x00, 0x01) == 0x01) {
		difficulty_roll_min = get_offense_floor();
		selected_spell_level = selected_spell_level + 0x08;
	} else {
		if (cur_mana < 0x06) {
			if (random(0x00, 0x01) == 0x00) {
				selected_spell_level = selected_spell_level + 0x08;
			}
		}
		difficulty_roll_min = get_base_floor();
	}
	selected_spell_level = selected_spell_level + random(difficulty_roll_min, 0x07);
	adjusted_spell_level = get_alt_spell_idx(selected_spell_level);
	if (adjusted_spell_level == 0x00) {
		return(selected_spell_level);
	}
	return(adjusted_spell_level);
}

function int pick_combat_spell_level() {
	selected_spell_level = 0x08;
	difficulty_roll_min = get_offense_floor();
	selected_spell_level = selected_spell_level + random(difficulty_roll_min, 0x07);
	adjusted_spell_level = get_alt_spell_idx(selected_spell_level);
	if (adjusted_spell_level == 0x00) {
		return(selected_spell_level);
	}
	return(adjusted_spell_level);
}

function int pick_neutral_spell_level() {
	selected_spell_level = 0x10;
	if (cur_mana < 0x0A) {
		selected_spell_level = 0x0F;
	} else {
		difficulty_roll_min = get_neutral_floor();
		selected_spell_level = selected_spell_level + random(difficulty_roll_min, 0x02);
	}
	if (caster_level < 0x04) {
		return(0x00 - 0x10);
	}
	adjusted_spell_level = get_alt_spell_idx(selected_spell_level);
	if (adjusted_spell_level == 0x00) {
		return(selected_spell_level);
	}
	return(adjusted_spell_level);
}

function int pick_good_spell_level() {
	selected_spell_level = 0x13;
	if (cur_mana < 0x04) {
		selected_spell_level = 0x0F;
	} else {
		difficulty_roll_min = get_good_floor();
		selected_spell_level = selected_spell_level + random(difficulty_roll_min, 0x04);
	}
	if (caster_level < 0x02) {
		return(0x00 - 0x13);
	}
	adjusted_spell_level = get_alt_spell_idx(selected_spell_level);
	if (adjusted_spell_level == 0x00) {
		return(selected_spell_level);
	}
	return(adjusted_spell_level);
}

function int pick_heal_spell_level() {
	selected_spell_level = 0x18;
	hp_heal_threshold = calc_percent(max_hp, 0x32);
	if (cur_mana < 0x0C) {
		selected_spell_level = 0x19;
	}
	if (hp_heal_threshold < initial_hp) {
		selected_spell_level = 0x19;
	}
	string spell_level_str = selected_spell_level;
	return(selected_spell_level);
}

function int select_divine_spell() {
	string spell_idx = selected_spell_level;
	if (caster_level < 0x06) {
		return(0x00);
	}
	return(0x1A);
}

trigger creation {
	initial_hp = getCurHP(this);
	max_hp = getMaxHP(this);
	hp_threshold_high = calc_percent(max_hp, 0x4B);
	hp_threshold_low = calc_percent(max_hp, 0x19);
	hp_threshold_critical = calc_percent(max_hp, 0x0A);
	prev_hp = initial_hp;
	return(0x01);
}

function void pick_and_cast_spell(obj caster) {
	obj target = getFirstVisableTargetInRange(caster, 0x09);
	if (target == NULL()) {
		return();
	}
	loc there = getLocation(target);
	int cur_hp = getCurHP(caster);
	cur_mana = getCurMana(caster);
	int intelligence = getIntelligence(caster);
	if (!hasObjVar(this, "spellCastersLevel")) {
		return();
	}
	caster_level = getObjVar(caster, "spellCastersLevel");
	int alignment;
	if (!getCompileFlag(0x01)) {
		alignment = getNotoriety(caster);
	} else {
		alignment = getKarmaLevel(caster);
	}
	int unused;
	int hp_zone;
	int spell_idx;
	int roll;
	int targetType;
	int mana_cost;
	int offensive_thresh;
	int neutral;
	int good;
	int heal;
	if (hp_threshold_high <= cur_hp) {
		hp_zone = 0x01;
	}
	if (hp_threshold_low <= cur_hp) {
		if (cur_hp < hp_threshold_high) {
			hp_zone = 0x02;
		}
	}
	if (hp_threshold_critical <= cur_hp) {
		if (cur_hp < hp_threshold_low) {
			hp_zone = 0x03;
		}
	} else {
		hp_zone = 0x04;
	}
	string s_hp_high = hp_threshold_high;
	string s_hp_low = hp_threshold_low;
	string s_hp_crit = hp_threshold_critical;
	string s_cur_hp = cur_hp;
	string s_hp_zone = hp_zone;
	spell_idx = 0x00;
	switch(hp_zone) {
	case 0x01
		offensive_thresh = 0x00;
		break;
	case 0x02
		offensive_thresh = 0x37;
		neutral = 0x28;
		good = 0x1C;
		heal = 0x03;
		break;
	case 0x03
		offensive_thresh = 0x50;
		neutral = 0x46;
		good = 0x3C;
		heal = 0x0F;
		break;
	case 0x04
		offensive_thresh = 0x5F;
		neutral = 0x5A;
		good = 0x55;
		heal = 0x0F;
		break;
	case 0x05
		offensive_thresh = 0x64;
		neutral = 0x64;
		good = 0x55;
		heal = 0x0F;
		break;
	default
		break;
	}
	list offensive_spells = 0x1F4A, 0x03, 0x0A, 0x1F5A, 0x02, 0x1A, 0x1F3E, 0x03, 0x06, 0x1F47, 0x03, 0x0A, 0x1F40, 0x03, 0x06, 0x1F2E, 0x03, 0x02, 0x1F30, 0x03, 0x02, 0x1F34, 0x03, 0x02;
	list combat_spells = 0x1F5F, 0x03, 0x34, 0x1F57, 0x03, 0x1A, 0x1F56, 0x03, 0x1A, 0x1F52, 0x03, 0x10, 0x1F4A, 0x03, 0x0A, 0x1F3E, 0x03, 0x06, 0x1F38, 0x03, 0x04, 0x1F32, 0x03, 0x02;
	list neutral_spells = 0x1F61, 0x03, 0x34, 0x1F50, 0x01, 0x10, 0x1F4B, 0x02, 0x0A;
	list good_spells = 0x1F3D, 0x01, 0x06, 0x1F3B, 0x01, 0x04, 0x1F3C, 0x01, 0x04, 0x1F36, 0x01, 0x04, 0x1F35, 0x01, 0x04;
	list heal_spells = 0x1F49, 0x01, 0x0A, 0x1F31, 0x01, 0x02;
	list power_spells = 0x1F58, 0x01, 0x1A;
	string s_mana = cur_mana;
	if (cur_mana < 0x02) {
		int attack_roll = random(0x01, 0x64);
		if (attack_roll < 0x23) {
			attack(this, target);
			return();
		} else {
			return();
		}
	}
	roll = random(0x00, 0x64);
	if (offensive_thresh <= roll) {
		if (alignment < 0x00) {
			spell_idx = pick_offensive_spell_level();
			if (spell_idx < 0x08) {
				spell_scroll_type = offensive_spells[spell_idx * 0x03];
				targetType = offensive_spells[(spell_idx * 0x03) + 0x01];
				mana_cost = offensive_spells[(spell_idx * 0x03) + 0x02];
			} else {
				spell_idx = (spell_idx - 0x08);
				spell_scroll_type = combat_spells[spell_idx * 0x03];
				targetType = combat_spells[(spell_idx * 0x03) + 0x01];
				mana_cost = combat_spells[(spell_idx * 0x03) + 0x02];
			}
		} else {
			spell_idx = (pick_combat_spell_level() - 0x08);
			spell_scroll_type = combat_spells[spell_idx * 0x03];
			targetType = combat_spells[(spell_idx * 0x03) + 0x01];
			mana_cost = combat_spells[(spell_idx * 0x03) + 0x02];
		}
	}
	if (neutral <= roll) {
		if (roll < offensive_thresh) {
			spell_idx = (pick_neutral_spell_level() - 0x10);
			if (spell_idx == (0x00 - 0x10)) {
				pick_and_cast_spell(this);
				return();
			}
			spell_scroll_type = neutral_spells[spell_idx * 0x03];
			targetType = neutral_spells[(spell_idx * 0x03) + 0x01];
			mana_cost = neutral_spells[(spell_idx * 0x03) + 0x02];
		}
	}
	if (good <= roll) {
		if (roll < neutral) {
			spell_idx = (pick_good_spell_level() - 0x13);
			if (spell_idx == (0x00 - 0x13)) {
				pick_and_cast_spell(this);
				return();
			}
			spell_scroll_type = good_spells[spell_idx * 0x03];
			targetType = good_spells[(spell_idx * 0x03) + 0x01];
			mana_cost = good_spells[(spell_idx * 0x03) + 0x02];
		}
	}
	if (heal <= roll) {
		if (roll < good) {
			spell_idx = (pick_heal_spell_level() - 0x18);
			spell_scroll_type = heal_spells[spell_idx * 0x03];
			targetType = heal_spells[(spell_idx * 0x03) + 0x01];
			mana_cost = heal_spells[(spell_idx * 0x03) + 0x02];
		}
	} else {
		spell_idx = (select_divine_spell() - 0x1A);
		if (spell_idx == (0x00 - 0x1A)) {
			pick_and_cast_spell(this);
			return();
		}
		spell_scroll_type = power_spells[spell_idx * 0x03];
		targetType = power_spells[(spell_idx * 0x03) + 0x01];
		mana_cost = power_spells[(spell_idx * 0x03) + 0x02];
	}
	obj scroll = createGlobalObjectIn(spell_scroll_type, caster);
	if (scroll == NULL()) {
		return();
	}
	obj spell_target;
	loc unused_loc;
	if (spend_mana(caster, mana_cost) == 0x00) {
		deleteObject(scroll);
		list unused_list;
		shortcallback(this, 0x01, 0x48);
		return();
	}
	setObjVar(scroll, "user", caster);
	string s_target_type = targetType;
	switch(targetType) {
	case 0x01
		spell_target = caster;
		setObjVar(scroll, "target", spell_target);
		break;
	case 0x02
		spell_target = target;
		setObjVar(scroll, "target", spell_target);
		break;
	case 0x03
		spell_target = target;
		setObjVar(scroll, "target", spell_target);
		break;
	default
	}
	shortcallback(scroll, 0x00, 0x49);
	callback(caster, 0x03, 0x48);
	return();
}

function void try_cast_spell(obj caster) {
	if (getNumTargets(caster) <= 0x00) {
		return();
	}
	pick_and_cast_spell(caster);
	return();
}

function int on_attacked(obj me, obj attacker) {
	int unused;
	last_damage_taken = prev_hp - getCurHP(me);
	prev_hp = getCurHP(me);
	schedule_callback_if_idle(this, 0x2D, 0x06, 0x0C);
	return(0x00);
}

trigger gotattacked {
	return(on_attacked(this, attacker));
}

trigger washit {
	return(on_attacked(this, attacker));
}

function int spend_mana(obj user, int cost) {
	if (cost > (getCurMana(this))) {
		return(0x00);
	}
	loseMana(this, cost);
	return(0x01);
	return(0x00);
}

function int get_alt_spell_idx(int spell_idx) {
	obj target = getFirstVisableTargetInRange(this, 0x09);
	if (target == NULL()) {
		return(spell_idx);
	}
	int alt_idx;
	switch(spell_idx) {
	case 0x04
		if (hasScript(target, "poisoned")) {
			alt_idx = 0x0D;
		}
		break;
	case 0x05
		if (hasScript(target, "dexdown")) {
			alt_idx = 0x0F;
		}
		break;
	case 0x06
		if (hasScript(target, "intdown")) {
			alt_idx = 0x0F;
		}
		break;
	case 0x07
		if (hasScript(target, "strdown")) {
			alt_idx = 0x0F;
		}
		break;
	case 0x0B
		if (hasScript(target, "rempara")) {
			alt_idx = 0x0C;
		}
		break;
	case 0x11
		if (hasScript(this, "reflctor")) {
			alt_idx = 0x12;
		}
		break;
	case 0x14
		if (hasScript(this, "remprtct")) {
			alt_idx = 0x19;
		}
		break;
	case 0x15
		if (hasScript(this, "strup")) {
			alt_idx = 0x19;
		}
		break;
	case 0x16
		if (hasScript(this, "intup")) {
			alt_idx = 0x19;
		}
		break;
	case 0x17
		if (hasScript(this, "dexup")) {
			alt_idx = 0x19;
		}
		break;
	default
		alt_idx = 0x00;
	}
	return(alt_idx);
}

trigger callback(0x48) {
	schedule_callback_if_idle(this, 0x2D, 0x06, 0x0C);
	return(0x01);
}

trigger callback(0x2D) {
	try_cast_spell(this);
	return(0x01);
}
