inherits globals;

trigger use {
	int x_origin = 0x052B;
	int y_origin = 0x0658;
	int map_width = 0x1400;
	int map_height = 0x1000;
	int west = 0x00;
	int north = 0x00;
	string lon_dir = " E ";
	string lat_dir = " S ";
	loc user_loc = getLocation(user);
	int rel_x = getX(user_loc);
	int rel_y = getY(user_loc);
	rel_x = rel_x - x_origin;
	rel_y = rel_y - y_origin;
	int lon_deg = (0x0168 * rel_x) / map_width;
	int lat_deg = (0x0168 * rel_y) / map_height;
	if (lon_deg > 0x1400) {
		barkTo(user, user, "You can't use a sextant here.");
		return(0x00);
	}
	if (lat_deg > 0x1000) {
		barkTo(user, user, "You can't use a sextant here.");
		return(0x00);
	}
	int lon_min = ((0x5460 * rel_x) / map_width) % 0x3C;
	int lat_min = ((0x5460 * rel_y) / map_height) % 0x3C;
	if (lon_deg < 0x00) {
		west = 0x01;
		lon_dir = " W ";
		lon_deg = lon_deg * (0x00 - 0x01);
		lon_min = lon_min * (0x00 - 0x01);
	}
	if (lon_deg > 0xB4) {
		west = 0x01;
		lon_dir = " W ";
		lon_deg = 0x0168 - lon_deg;
		if (lon_min > 0x00) {
			lon_deg--;
		}
	}
	if (lat_deg < 0x00) {
		north = 0x01;
		lat_dir = " N ";
		lat_deg = lat_deg * (0x00 - 0x01);
		lat_min = lat_min * (0x00 - 0x01);
	}
	if (lat_deg > 0xB4) {
		north = 0x01;
		lat_dir = " N ";
		lat_deg = 0x0168 - lat_deg;
		if (lat_min > 0x00) {
			lat_deg--;
		}
	}
	string lon_deg_str = lon_deg;
	string lat_deg_str = lat_deg;
	string lon_min_str = lon_min;
	string lat_min_str = lat_min;
	barkTo(user, user, lat_deg_str + "o " + lat_min_str + "'" + lat_dir + lon_deg_str + "o " + lon_min_str + "'" + lon_dir);
	return(0x00);
}
