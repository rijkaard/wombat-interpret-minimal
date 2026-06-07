inherits spelskil;

member obj spell_obj;

function void end_casting(obj it) {
	setMobFlag(this, 0x02, 0x00);
	detachScript(it, "casting");
	return();
}

trigger creation {
	spell_obj = getObjVar(this, "spellObj");
	removeObjVar(this, "spellObj");
	setMobFlag(this, 0x02, 0x01);
	return(0x01);
}

trigger callback(0x80) {
	list f_args;
	appendToList(f_args, this);
	message(spell_obj, "castspell", f_args);
	end_casting(this);
	return(0x00);
}

trigger callback(0x82) {
	do_cast_anim(this, 0x01);
	shortcallback(this, 0x04, 0x82);
	return(0x01);
}

trigger washit {
	int difficulty = (get_spell_circle(spell_obj) - 0x01) * 0x03E8 / 0x07;
	difficulty = difficulty + damamt * 0x14;
	int check = getSkillSuccessChance(this, SKILL_MAGERY, difficulty, 0x28) - random(0x00, 0x03E7);
	if (check <= 0x00) {
		systemMessage(this, "Your concentration is disturbed, thus ruining thy spell.");
		end_casting(this);
		return(0x01);
	}
	return(0x01);
}
