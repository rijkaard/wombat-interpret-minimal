inherits allstatbase;

function int apply_bless_effect(obj user, obj usedon, int reflected) {
	int success = 0x00;
	if (apply_all_stat_effect(user, usedon, 0x01, reflected)) {
		int notoriety_result = apply_spell_notoriety(user, usedon, reflected, this);
		success = 0x01;
	}
	return(success);
}
