inherits statbase;

function int apply_cunning_effect(obj user, obj usedon, int reverse) {
	int result = apply_stat_spell(user, usedon, STAT_INT, 0x01, reverse);
	int notoriety_result = apply_spell_notoriety(user, usedon, reverse, this);
	return(result);
}
