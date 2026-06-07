inherits trap_single;

trigger leaverange(0x00) {
	int result = apply_trap_effect(0x01, target, 0x00, 0x00, 0x00);
	return(0x00);
}
