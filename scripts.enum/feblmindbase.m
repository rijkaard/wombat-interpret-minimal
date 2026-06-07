inherits statbase;

function int apply_feeblemind(obj user, obj usedon, int reverse) {
	int fizzled = apply_stat_spell(user, usedon, STAT_INT, 0x00, reverse);
	return(fizzled);
}
