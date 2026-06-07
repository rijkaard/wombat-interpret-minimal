trigger speech("*") {
	list parts;
	split(parts, arg);
	if (numInList(parts) != 0x06) {
		return(0x00);
	}
	string x1_s = parts[0x00];
	string y1_s = parts[0x01];
	string x2_s = parts[0x02];
	string y2_s = parts[0x03];
	string w_s = parts[0x04];
	string h_s = parts[0x05];
	int x1 = x1_s;
	int y1 = y1_s;
	int x2 = x2_s;
	int y2 = y2_s;
	int w = w_s;
	int height = h_s;
	setMapProperties(this, 0x00, x1, y1, x2, y2, w, height);
	return(0x00);
}
