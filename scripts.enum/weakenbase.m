inherits statbase;

function int apply_weaken_spell(obj user, obj usedon, int reverse) {
	int fizzled = apply_stat_spell(user, usedon, STAT_STR, 0x00, reverse);
	return(fizzled);
}
