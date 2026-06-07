inherits statbase;

function int apply_clumsy_effect(obj user, obj usedon, int reflected) {
	int result = apply_stat_spell(user, usedon, STAT_DEX, 0x00, reflected);
	return(result);
}
