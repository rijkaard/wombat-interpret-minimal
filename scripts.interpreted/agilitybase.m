inherits statbase;

function int apply_agility_effect(obj user, obj usedon, int reflected) {
	int result = apply_stat_spell(user, usedon, 0x01, 0x01, reflected);
	int notoriety_result = apply_spell_notoriety(user, usedon, reflected, this);
	return(result);
}
