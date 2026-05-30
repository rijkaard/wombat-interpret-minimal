inherits spelskil;

function void apply_defense_bonus(obj item, int val) {
	int ac = getMaxArmorClass(item);
	ac = ac + val;
	int result = setMaxArmorClass(this, ac);
	return();
}
