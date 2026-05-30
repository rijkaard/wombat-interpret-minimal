trigger speech("descr") {
	string desc;
	loc area_loc;
	loc speaker_loc = getLocation(speaker);
	int x = (getLocalizedDesc(desc, area_loc, speaker_loc, speaker_loc));
	bark(this, desc);
	return(0x00);
}
