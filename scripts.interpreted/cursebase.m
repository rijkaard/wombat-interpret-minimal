inherits allstatbase;

function int apply_curse_effect(obj user, obj usedon, int reverse) {
	int result = apply_all_stat_effect(user, usedon, 0x00, reverse);
	return(result);
}
