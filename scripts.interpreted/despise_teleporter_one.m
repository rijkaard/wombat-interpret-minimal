trigger creation {
	setType(this, 0x375A);
	return(0x00);
}

trigger enterrange(0x01) {
	loc dest = 0x1647, 0x027F, 0x00;
	if (!teleport(target, dest)) {
		return(0x01);
	}
	return(0x00);
}
