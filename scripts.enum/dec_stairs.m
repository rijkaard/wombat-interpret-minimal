inherits globals;

trigger enterrange(0x01) {
	loc dest;
	loc this_loc = getLocation(this);
	loc step_1 = 0x1461, 0x024B, (0x00 - 0x14);
	loc step_2 = 0x14B9, 0x0213, 0x0A;
	loc step_3 = 0x14E3, 0x0242, (0x00 - 0x14);
	loc step_4 = 0x1411, 0x028A, 0x0F;
	loc step_5 = 0x1462, 0x02FA, (0x00 - 0x23);
	loc step_6 = 0x14BA, 0x0289, 0x0F;
	loc exit_1 = 0x1461, 0x0246, 0x00;
	loc exit_2 = 0x14B9, 0x0216, 0x00;
	loc exit_3 = 0x14DE, 0x0242, 0x00;
	loc exit_4 = 0x1415, 0x028A, 0x00;
	loc exit_5 = 0x1462, 0x02F6, (0x00 - 0x14);
	loc exit_6 = 0x14BA, 0x028E, 0x00;
	if (this_loc == step_1) {
		dest = exit_2;
	}
	if (this_loc == step_2) {
		dest = exit_1;
	}
	if (this_loc == step_3) {
		dest = exit_4;
	}
	if (this_loc == step_4) {
		dest = exit_3;
	}
	if (this_loc == step_5) {
		dest = exit_6;
	}
	if (this_loc == step_6) {
		dest = exit_5;
	}
	if (!teleport(target, dest)) {
		return(0x01);
	}
	return(0x00);
}
