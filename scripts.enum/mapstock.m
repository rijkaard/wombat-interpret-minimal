inherits globals;

trigger creation {
	int x1 = 0x00;
	int y1 = 0x00;
	int x2 = 0x00;
	int y2 = 0x00;
	int width = 0x00;
	int height = 0x00;
	if (hasObjVar(this, "mapx1")) {
		x1 = getObjVar(this, "mapx1");
		removeObjVar(this, "mapx1");
	}
	if (hasObjVar(this, "mapy1")) {
		y1 = getObjVar(this, "mapy1");
		removeObjVar(this, "mapy1");
	}
	if (hasObjVar(this, "mapx2")) {
		x2 = getObjVar(this, "mapx2");
		removeObjVar(this, "mapx2");
	}
	if (hasObjVar(this, "mapy2")) {
		y2 = getObjVar(this, "mapy2");
		removeObjVar(this, "mapy2");
	}
	if (hasObjVar(this, "mapwidth")) {
		width = getObjVar(this, "mapwidth");
		removeObjVar(this, "mapwidth");
	}
	if (hasObjVar(this, "mapheight")) {
		height = getObjVar(this, "mapheight");
		removeObjVar(this, "mapheight");
	}
	if (x1 < 0x00) {
		x1 = 0x00;
	}
	if (x2 > 0x13FF) {
		x2 = 0x144F;
	}
	if (y1 < 0x00) {
		y1 = 0x00;
	}
	if (y2 > 0x0FFF) {
		y2 = 0x0FFF;
	}
	setMapProperties(this, 0x00, x1, y1, x2, y2, width, height);
	detachScript(this, "mapstock");
	return(0x01);
}
