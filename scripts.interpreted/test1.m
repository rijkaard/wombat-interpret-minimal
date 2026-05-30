inherits trap_single;

trigger enterrange(0x05) {
	bark(this, "I have been triggered.")int result = apply_trap_effect(0x05, target, 0x1463, 0x0247, 0x00);
	string result_str = result;
	bark(this, "I did this much damage");
	bark(this, result_str);
	bark(this, "to:");
	bark(this, getName(target));
	return(0x00);
}
