function int apply_trap_effect(int effect_type, obj victim, int p1, int p2, int p3) {
	int damage;
	obj m_target = victim;
	string msg = effect_type;
	bark(m_target, msg);
	if ((effect_type == 0x01) || (effect_type == 0x02) || (effect_type == 0x03)) {
		int num_dice = p1;
		int die_size = p2;
		int multiplier = p3;
		damage = multiplier * (dice(num_dice, die_size));
	}
	if (effect_type == 0x01) {
		loseHP(m_target, damage);
		return(damage);
	}
	if (effect_type == 0x02) {
		int new_mana = getCurMana(m_target) - damage;
		if (new_mana < 0x00) {
			setCurMana(m_target, 0x00);
		} else {
			loseMana(m_target, damage);
		}
		return(damage);
	}
	if (effect_type == 0x03) {
		bark(m_target, "My move should be affected");
		int new_fatigue = getCurFatigue(m_target) - damage;
		if (new_fatigue < 0x00) {
			setCurFatigue(m_target, 0x00);
		} else {
			loseFatigue(m_target, damage);
		}
		return(damage);
	}
	if (effect_type == 0x04) {
		return(0x00);
	}
	if (effect_type == 0x05) {
		int x = p1;
		int y = p2;
		int z = p3;
		loc dest = x, y, z;
		if (!teleport(m_target, dest)) {
			return(0x00);
		}
		return(0x01);
	}
	return(0x00);
}
