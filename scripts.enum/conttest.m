function int fill_container_1(obj container, int count) {
	int num = 0x00;
	obj item;
	for (; num < count; num++) {
		item = createGlobalObjectIn(count, container);
	}
	return(0x01);
}

trigger speech("*") {
	int result = fill_container_1(this, 0x13FA);
	return(0x01);
}
