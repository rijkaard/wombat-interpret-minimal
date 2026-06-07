inherits shrine;

trigger creation {
	is_chaos_shrine = 0x01;
	return(0x01);
}

trigger objectloaded {
	is_chaos_shrine = 0x01;
	return(0x01);
}
