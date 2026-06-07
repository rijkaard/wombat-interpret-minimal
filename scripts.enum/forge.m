inherits itemmanip;

trigger callback(0x32) {
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x197D
	case 0x1981
	case 0x1985
	case 0x1989
	case 0x198D
	case 0x1991
	case 0x1995
	case 0x1999
	case 0x199D
	case 0x19A1
	case 0x19A5
	case 0x19A9
		setType(this, obj_type - 0x03);
		break;
	}
	return(0x01);
}

trigger use {
	loc forge_loc = getLocation(this);
	loc scan_loc = forge_loc;
	obj part2;
	obj part3;
	int coord;
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x197A
		setType(this, 0x197D);
		coord = getX(scan_loc);
		coord++;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x197E);
		setType(part2, 0x1981);
		coord++;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x1982);
		setType(part3, 0x1985);
		break;
	case 0x197E
		setType(this, 0x1981);
		coord = getX(scan_loc);
		coord--;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x197A);
		setType(part2, 0x197D);
		coord = coord + 0x02;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x1982);
		setType(part3, 0x1985);
		break;
	case 0x1982
		setType(this, 0x1985);
		coord = getX(scan_loc);
		coord--;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x197E);
		setType(part2, 0x1981);
		coord--;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x197A);
		setType(part3, 0x197D);
		break;
	case 0x1986
		setType(this, 0x1989);
		coord = getY(scan_loc);
		coord++;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x198A);
		setType(part2, 0x198D);
		coord++;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x198E);
		setType(part3, 0x1991);
		break;
	case 0x198A
		setType(this, 0x198D);
		coord = getY(scan_loc);
		coord--;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x1986);
		setType(part2, 0x1989);
		coord = coord + 0x02;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x198E);
		setType(part3, 0x1991);
		break;
	case 0x198E
		setType(this, 0x1991);
		coord = getY(scan_loc);
		coord--;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x198A);
		setType(part2, 0x198D);
		coord--;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x1986);
		setType(part3, 0x1989);
		break;
	case 0x1992
		setType(this, 0x1995);
		coord = getY(scan_loc);
		coord--;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x1996);
		setType(part2, 0x1999);
		coord--;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x199A);
		setType(part3, 0x199D);
		break;
	case 0x1996
		setType(this, 0x1999);
		coord = getY(scan_loc);
		coord--;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x199A);
		setType(part2, 0x199D);
		coord = coord + 0x02;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x1992);
		setType(part3, 0x1995);
		break;
	case 0x199A
		setType(this, 0x199D);
		coord = getY(scan_loc);
		coord++;
		setY(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x1996);
		setType(part2, 0x1999);
		coord++;
		setY(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x1992);
		setType(part3, 0x1995);
		break;
	case 0x199E
		setType(this, 0x19A1);
		coord = getX(scan_loc);
		coord--;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x19A2);
		setType(part2, 0x19A5);
		coord--;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x19A6);
		setType(part3, 0x19A9);
		break;
	case 0x19A2
		setType(this, 0x19A5);
		coord = getX(scan_loc);
		coord--;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x19A6);
		setType(part2, 0x19A9);
		coord = coord + 0x02;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x199E);
		setType(part3, 0x19A1);
		break;
	case 0x19A6
		setType(this, 0x19A9);
		coord = getX(scan_loc);
		coord++;
		setX(scan_loc, coord);
		part2 = getFirstObjectOfType(scan_loc, 0x19A2);
		setType(part2, 0x19A5);
		coord++;
		setX(scan_loc, coord);
		part3 = getFirstObjectOfType(scan_loc, 0x199E);
		setType(part3, 0x19A1);
		break;
	}
	sfx(forge_loc, 0x2B, 0x00);
	shortCallback(this, 0x03, 0x32);
	shortCallback(part2, 0x03, 0x32);
	shortCallback(part3, 0x03, 0x32);
	return(0x00);
}
