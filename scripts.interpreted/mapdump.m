trigger speech("mapdump") {
	int i = 0x00;
	string msg;
	string tmp;
	loc nav_pt;
	while (0x01) {
		if (!getMapPoint(nav_pt, this, i)) {
			break;
		}
		msg = "Nav point ";
		tmp = (i + 0x01);
		concat(msg, tmp);
		concat(msg, ": ");
		tmp = getX(nav_pt);
		concat(msg, tmp);
		concat(msg, " ");
		tmp = getY(nav_pt);
		concat(msg, tmp);
		concat(msg, " ");
		bark(this, msg);
		i++;
	}
	return(0x00);
}
