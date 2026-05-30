inherits spelskil;

function int apply_heal(obj user, obj usedon) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int heal_amount;
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(user_loc, there));
		doMobAnimation(usedon, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x01F2, 0x00);
		if (hasObjVar(this, "magicItemBonus")) {
			heal_amount = 0x05 + dice(0x01, 0x06);
		} else {
			heal_amount = ((getSkillLevel(user, 0x19) / 0x0A) + dice(0x01, 0x06));
		}
		int hp_before = getCurHP(usedon);
		addHP(usedon, heal_amount);
		int hp_after = getCurHP(usedon);
		heal_amount = hp_after - hp_before;
		string heal_str = heal_amount;
		if (isPlayer(user)) {
			systemMessage(user, heal_str + " points of damage have been healed.");
		}
		if (heal_amount > 0x00) {
			int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
			success = 0x01;
		}
	}
	schedule_cleanup(this);
	return(success);
}
