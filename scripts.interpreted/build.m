inherits tilesets;

forward int is_excluded(loc );

forward int is_in_bounds(loc );

forward void apply_mountain_transition(loc );

forward void place_flora(loc );

forward void set_elevation_random(loc );

forward void fill_tile(loc );

forward void shade_mountain_tile(loc );

forward void apply_water_embankment(loc );

forward void run_terrain_scan(int );

forward void restore_tile_state(int , loc );

forward void raise_elevation(loc );

forward void lower_elevation(loc );

forward void show_tools_menu(obj );

forward void prompt_elevation_filter();

forward void prompt_terrain_filter();

forward void prompt_scan_area();

forward void prompt_transition_type();

forward void run_shade_mountains();

forward void select_embankment_type();

forward void select_statics_type();

forward void prompt_set_elevation();

forward void select_fill_type();

forward void run_undo_terrain();

forward void prompt_raise_terrain();

forward void prompt_lower_terrain();

trigger creation {

member obj gm;

member int elev_min;

member int elev_max;

member loc scan_start;

member loc scan_end;

member list tile_filter;

member int flora_type;

member list random_tiles;

member list transition_table;

member int elev_target;

member int elev_fudge;

member list undo_history;

member list mountain_tiles;

member list water_tiles;
	elev_min = 0x00 - 0x7F;
	elev_max = 0x7F;
	scan_start = 0x00, 0x00, 0x00;
	scan_end = 0x00, 0x00, 0x00;
	tile_filter = "None";
	transition_table = "None";
	return(0x01);
}

function int is_excluded(loc place) {
	int z = getZ(place);
	if (z < elev_min) {
		return(0x01);
	}
	if (z > elev_max) {
		return(0x01);
	}
	if (numInList(tile_filter) < 0x02) {
		return(0x00);
	}
	int t = getTile(place);
	if (!isInList(tile_filter, t)) {
		return(0x01);
	}
	return(0x00);
}

function int is_in_bounds(loc place) {
	int x = getX(place);
	int y = getY(place);
	int z = getZ(place);
	if (x < 0x00) {
		return(0x00);
	}
	if (x > 0x0BB8) {
		return(0x00);
	}
	if (y < 0x00) {
		return(0x00);
	}
	if (y > 0x0BB8) {
		return(0x00);
	}
	if (z > 0x7F) {
		return(0x00);
	}
	if (z < (0x00 - 0x7F)) {
		return(0x00);
	}
	return(0x01);
}

function int is_source_tile(int t) {
	return(isInList(mountain_tiles, t));
}

function int is_target_tile(int t) {
	return(isInList(water_tiles, t));
}

function void apply_mountain_transition(loc place) {
	int upper_left_tile;
	int upper_tile;
	int upper_right_tile;
	int left;
	int right;
	int lower_left_tile;
	int lower;
	int lower_right_tile;
	int current_tile = getTile(place);
	int x = getX(place);
	int y = getY(place);
	loc sample_loc = place;
	int c = 0x00;
	int transition_index = getTile(place);
	setX(sample_loc, x - 0x01);
	left = getTile(sample_loc);
	setY(sample_loc, y - 0x01);
	upper_left_tile = getTile(sample_loc);
	setX(sample_loc, x);
	upper_tile = getTile(sample_loc);
	setX(sample_loc, x + 0x01);
	upper_right_tile = getTile(sample_loc);
	setY(sample_loc, y);
	right = getTile(sample_loc);
	setY(sample_loc, y + 0x01);
	lower_right_tile = getTile(sample_loc);
	setX(sample_loc, x);
	lower = getTile(sample_loc);
	setX(sample_loc, x - 0x01);
	lower_left_tile = getTile(sample_loc);
	if (is_source_tile(current_tile)) {
		return();
	}
	if ((is_source_tile(upper_left_tile)) && (!is_source_tile(left)) && (!is_source_tile(upper_tile))) {
		transition_index = 0x07;
		c = 0x01;
	}
	if ((is_source_tile(upper_right_tile)) && (!is_source_tile(right)) && (!is_source_tile(upper_tile))) {
		transition_index = 0x08;
		c = 0x01;
	}
	if ((is_source_tile(lower_right_tile)) && (!is_source_tile(right)) && (!is_source_tile(lower))) {
		transition_index = 0x09;
		c = 0x01;
	}
	if ((is_source_tile(lower_left_tile)) && (!is_source_tile(left)) && (!is_source_tile(lower))) {
		transition_index = 0x0A;
		c = 0x01;
	}
	if ((is_source_tile(left)) && (!is_source_tile(right))) {
		transition_index = 0x03;
		c = 0x01;
	}
	if ((is_source_tile(right)) && (!is_source_tile(left))) {
		transition_index = 0x06;
		c = 0x01;
	}
	if ((is_source_tile(upper_tile)) && (!is_source_tile(lower))) {
		transition_index = 0x04;
		c = 0x01;
	}
	if ((is_source_tile(lower)) && (!is_source_tile(upper_tile))) {
		transition_index = 0x05;
		c = 0x01;
	}
	if ((is_source_tile(left)) && (is_source_tile(upper_tile))) {
		transition_index = 0x0D;
		c = 0x01;
	}
	if ((is_source_tile(left)) && (is_source_tile(lower))) {
		transition_index = 0x0C;
		c = 0x01;
	}
	if ((is_source_tile(right)) && (is_source_tile(upper_tile))) {
		transition_index = 0x0E;
		c = 0x01;
	}
	if ((is_source_tile(right)) && (is_source_tile(lower))) {
		transition_index = 0x0B;
		c = 0x01;
	}
	if (c) {
		setTile(place, transition_table[transition_index]);
	}
	return();
}

function void place_flora(loc place) {
	list s;
	string e;
	string coord_str;
	coord_str = "" + getX(place) + " " + getY(place) + " " + getZ(place);
	int x;
	if (random(0x00, 0x05) > 0x03) {
		switch(flora_type) {
		case 0x00
			s = "newtree", "underbrush", "newlog", "newrock";
			e = s[random(0x00, numInList(s) - 0x01)];
			escript(gm, e, coord_str);
			break;
		case 0x01
			if (random(0x00, 0x03)) {
				break;
			}
			s = 0x0D25, 0x0D26, 0x0D27, 0x0D28, 0x0D2A, 0x0D2C, 0x0D2E, 0x0D25, 0x0D26, 0x0D27, 0x0D28, 0x0D2A, 0x0D2C, 0x0D2E, 0x0D25, 0x0D26, 0x0D27, 0x0D28, 0x0D2A, 0x0D2C, 0x1363, 0x1364, 0x1365, 0x1366, 0x1367, 0x1368, 0x1369, 0x136A, 0x136B, 0x136C, 0x136D, 0x0D2E, 0x0D32, 0x0D32, 0x0D32, 0x0C95, 0x0C96, 0x0D31, 0x0D30, 0x0D35, 0x0D37;
			x = s[random(0x00, numInList(s) - 0x01)];
			createStatic(place, x);
			if (random(0x00, 0x01)) {
				if (x == 0x0D28) {
					createStatic(place, 0x0D29);
				}
				if (x == 0x0D2A) {
					createStatic(place, 0x0D2B);
				}
				if (x == 0x0D2C) {
					createStatic(place, 0x0D2D);
				}
				if (x == 0x0D2E) {
					createStatic(place, 0x0D2F);
				}
				if (x == 0x0D35) {
					createStatic(place, 0x0D36);
				}
			}
			break;
		case 0x02
			s = "newjtree", "newjbrush", "newjbrush", "newjbrush", "newjlog", "newrock", "newjshroom";
			e = s[random(0x00, numInList(s) - 0x01)];
			escript(gm, e, coord_str);
			break;
		case 0x03
			if (random(0x00, 0x0A)) {
				break;
			}
			s = 0x0CAF, 0x0CB0, 0x0CB5, 0x0CB6, 0x0C85, 0x0D29, 0x0D2B, 0x0D2D, 0x0D2F, 0x0D15, 0x0D16, 0x0D17, 0x0D18, 0x0D19, 0x0D15, 0x0D16, 0x0D17, 0x0D18, 0x0D19, 0x0D14, 0x0D13, 0x0D12, 0x1773, 0x1774, 0x177B, 0x177C, 0x1777, 0x1778, 0x1363, 0x1364, 0x1365, 0x1366, 0x1367, 0x1368, 0x1369, 0x136A, 0x136B, 0x136C, 0x136D;
			x = s[random(0x00, numInList(s) - 0x01)];
			createStatic(place, x);
			break;
		case 0x04
			escript(gm, "newtree", coord_str);
			break;
		case 0x05
			s = 0x0D08, 0x0D06, 0x0DC2, 0x0D07, 0x0DC3, 0x0DC1, 0x0D0A, 0x0DBC, 0x0D09, 0x0DBD, 0x0D0B, 0x0DBE, 0x0D04, 0x0CB7, 0x0CB8, 0x0CB9, 0x0CBA, 0x0CBB, 0x0CBC, 0x0CBD, 0x0CB7, 0x0CB8, 0x0CB9, 0x0CBA, 0x0CBB, 0x0CBC, 0x0CBD, 0x0CB7, 0x0CB8, 0x0CB9, 0x0CBA, 0x0CBB, 0x0CBC, 0x0CBD, 0x0CC4, 0x0C94, 0x0C93, 0x0C98, 0x0C97, 0x0CA7;
			x = s[random(0x00, numInList(s) - 0x01)];
			createStatic(place, x);
			break;
		case 0x06
			s = 0x0D08, 0x0D06, 0x0DC2, 0x0D07, 0x0DC3, 0x0DC1, 0x0D0A, 0x0DBC, 0x0D09, 0x0DBD, 0x0D0B, 0x0DBE, 0x0D04, 0x0D05, 0x324E, 0x3250, 0x324D, 0x324C, 0x0CF8, 0x0CFB, 0x0CFE, 0x0D01;
			x = s[random(0x00, numInList(s) - 0x01)];
			createStatic(place, x);
			loc orig_loc;
			if (x == 0x324E) {
				orig_loc = place;
				setY(place, (getY(place) - 0x01));
				createStatic(place, 0x324F);
			}
			if (x == 0x3250) {
				orig_loc = place;
				setX(place, (getX(place) - 0x01));
				createStatic(place, 0x324F);
			}
			break;
		case 0x07
			s = 0x1B7E, 0x1B7E, 0x1B7E, 0x1B7E, 0x1B7E, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8, 0x0CD6, 0x0CD8;
			if (random(0x00, 0x07)) {
				x = s[random(0x00, numInList(s) - 0x01)];
				createStatic(place, x);
				if (x == 0x0CD6) {
					createStatic(place, 0x0CD7);
				}
				if (x == 0x0CD8) {
					createStatic(place, 0x0CD9);
				}
			} else {
				escript(gm, "newrock", coord_str);
			}
			break;
		case 0x08
			escript(gm, "underbrush", coord_str);
			break;
		case 0x09
			escript(gm, "newrock", coord_str);
			break;
		case 0x0A
			escript(gm, "newshroom", coord_str);
			break;
		default
			break;
		}
	}
	return();
}

function void set_elevation_random(loc place) {
	setElevation(place, elev_target + (random((0x00 - elev_fudge), elev_fudge)));
	return();
}

function void raise_elevation(loc place) {
	int z = getZ(place);
	z = z + elev_target;
	setElevation(place, z);
	return();
}

function void lower_elevation(loc place) {
	int z = getZ(place);
	z = z - elev_target;
	setElevation(place, z);
	return();
}

function void fill_tile(loc place) {
	setTile(place, random_tiles[random(0x01, numInList(random_tiles) - 0x01)]);
	return();
}

function int is_flat_quad(loc place) {
	int elev;
	int elev_s;
	int elev_e;
	int elev_se;
	elev = getElevation(place);
	loc loc_s = getX(place), getY(place) + 0x01, 0x00;
	elev_s = getElevation(loc_s);
	loc loc_e = getX(place) + 0x01, getY(place), 0x00;
	elev_e = getElevation(loc_e);
	loc loc_se = getX(place) + 0x01, getY(place) + 0x01, 0x00;
	elev_se = getElevation(loc_se);
	if (elev != elev_se) {
		return(0x00);
	}
	if (elev != elev_e) {
		return(0x00);
	}
	if (elev != elev_s) {
		return(0x00);
	}
	return(0x01);
}

function void shade_mountain_tile(loc place) {
	int center_elev;
	int south_elev;
	int east_elev;
	int southeast_elev;
	list t;
	t = 0x022C, 0x022D, 0x022E, 0x022F;
	center_elev = getElevation(place);
	loc south_loc = getX(place), getY(place) + 0x01, 0x00;
	south_elev = getElevation(south_loc);
	loc east_loc = getX(place) + 0x01, getY(place), 0x00;
	east_elev = getElevation(east_loc);
	loc southeast_loc = getX(place) + 0x01, getY(place) + 0x01, 0x00;
	southeast_elev = getElevation(southeast_loc);
	if (is_flat_quad(place)) {
		t = 0x0230;
		setTile(place, t[random(0x00, numInList(t) - 0x01)]);
		return();
	}
	if ((center_elev > south_elev) && (southeast_elev == south_elev) && (center_elev > east_elev)) {
		t = 0x0229;
		setTile(place, t[random(0x00, numInList(t) - 0x01)]);
		return();
	}
	if ((south_elev > center_elev) && (south_elev > southeast_elev) && (east_elev > center_elev) && (east_elev > southeast_elev)) {
		t = 0x0227;
		setTile(place, t[random(0x00, numInList(t) - 0x01)]);
		return();
	}
	if (south_elev > east_elev) {
		t = 0x022B, 0x021F, 0x0220, 0x0221, 0x0222, 0x0223, 0x0224, 0x0225, 0x0226;
		setTile(place, t[random(0x00, numInList(t) - 0x01)]);
		return();
	}
	if (getTile(place) != 0x022B) {
		if (getTile(east_loc) == 0x022B) {
			t = 0x0220;
			setTile(place, t[random(0x00, numInList(t) - 0x01)]);
			return();
		}
	}
	setTile(place, t[random(0x00, numInList(t) - 0x01)]);
	return();
}

function void apply_water_embankment(loc place) {
	int upper_left_tile;
	int upper_tile;
	int upper_right_tile;
	int left;
	int right;
	int lower_left_tile;
	int lower;
	int lower_right_tile;
	int current_tile = getTile(place);
	int x = getX(place);
	int y = getY(place);
	loc sample_loc = place;
	int c = 0x00;
	loc elev_source_loc = place;
	int transition_index = getTile(place);
	setX(sample_loc, x - 0x01);
	left = getTile(sample_loc);
	setY(sample_loc, y - 0x01);
	upper_left_tile = getTile(sample_loc);
	setX(sample_loc, x);
	upper_tile = getTile(sample_loc);
	setX(sample_loc, x + 0x01);
	upper_right_tile = getTile(sample_loc);
	setY(sample_loc, y);
	right = getTile(sample_loc);
	setY(sample_loc, y + 0x01);
	lower_right_tile = getTile(sample_loc);
	setX(sample_loc, x);
	lower = getTile(sample_loc);
	setX(sample_loc, x - 0x01);
	lower_left_tile = getTile(sample_loc);
	if (is_target_tile(current_tile)) {
		return();
	}
	if ((is_target_tile(upper_left_tile)) && (!is_target_tile(left)) && (!is_target_tile(upper_tile))) {
		transition_index = 0x0D;
		c = 0x01;
		elev_source_loc = getX(place) - 0x01, getY(place) - 0x01, getZ(place);
	}
	if ((is_target_tile(upper_right_tile)) && (!is_target_tile(right)) && (!is_target_tile(upper_tile))) {
		transition_index = 0x0E;
		c = 0x01;
		elev_source_loc = getX(place) - 0x01, getY(place) + 0x01, getZ(place);
	}
	if ((is_target_tile(lower_right_tile)) && (!is_target_tile(right)) && (!is_target_tile(lower))) {
		transition_index = 0x0F;
		c = 0x01;
	}
	if ((is_target_tile(lower_left_tile)) && (!is_target_tile(left)) && (!is_target_tile(lower))) {
		transition_index = 0x10;
		c = 0x01;
	}
	if ((is_target_tile(left)) && (!is_target_tile(right))) {
		transition_index = random(0x01, 0x03);
		c = 0x01;
		elev_source_loc = getX(place) - 0x01, getY(place), getZ(place);
	}
	if ((is_target_tile(right)) && (!is_target_tile(left))) {
		transition_index = random(0x07, 0x09);
		c = 0x01;
	}
	if ((is_target_tile(upper_tile)) && (!is_target_tile(lower))) {
		transition_index = random(0x04, 0x06);
		c = 0x01;
		elev_source_loc = getX(place), getY(place) - 0x01, getZ(place);
	}
	if ((is_target_tile(lower)) && (!is_target_tile(upper_tile))) {
		transition_index = random(0x0A, 0x0C);
		c = 0x01;
	}
	if ((is_target_tile(left)) && (is_target_tile(upper_tile))) {
		transition_index = 0x0D + 0x06;
		c = 0x01;
	}
	if ((is_target_tile(left)) && (is_target_tile(lower))) {
		transition_index = 0x0C + 0x06;
		c = 0x01;
		elev_source_loc = getX(place) - 0x01, getY(place) + 0x01, getZ(place);
	}
	if ((is_target_tile(right)) && (is_target_tile(upper_tile))) {
		transition_index = 0x0E + 0x06;
		c = 0x01;
		elev_source_loc = getX(place) - 0x01, getY(place) - 0x01, getZ(place);
	}
	if ((is_target_tile(right)) && (is_target_tile(lower))) {
		transition_index = 0x0B + 0x06;
		c = 0x01;
	}
	if (c) {
		setTile(place, transition_table[transition_index]);
	}
	setElevation(place, getElevation(elev_source_loc));
	return();
}

function void restore_tile_state(int c, loc place) {
	return();
	int elev = undo_history[c];
	int t = undo_history[c + 0x01];
	setElevation(place, elev);
	setTile(place, t);
	return();
}

function void run_terrain_scan(int mode) {
	int start_x = getX(scan_start);
	int start_y = getY(scan_start);
	int end_x = getX(scan_end);
	int end_y = getY(scan_end);
	loc place;
	int y;
	int x;
	int elev;
	int c = 0x00;
	systemMessage(gm, "Starting terrain scan from " + scan_start + " to " + scan_end + ".");
	updatesOff();
	for (y = start_y; y < (end_y + 0x01); y++) {
		for (x = start_x; x < (end_x + 0x01); x++) {
			place = x, y, 0x00;
			elev = getElevation(place);
			place = x, y, elev;
			if (!is_excluded(place)) {
				switch(mode) {
				case 0x01
					fill_tile(place);
					break;
				case 0x02
					set_elevation_random(place);
					break;
				case 0x03
					apply_mountain_transition(place);
					break;
				case 0x04
					place_flora(place);
					break;
				case 0x05
					shade_mountain_tile(place);
					break;
				case 0x06
					apply_water_embankment(place);
					break;
				case 0x07
					break;
				case 0x08
					raise_elevation(place);
					break;
				case 0x09
					lower_elevation(place);
					break;
				default
					break;
				}
			}
		}
	}
	if (mode == 0x06) {
		copyList(tile_filter, water_tiles);
	}
	systemMessage(gm, "Terrain scan complete.");
	updatesOn();
	return();
}

trigger use {
	if (!isEditing(user)) {
		return(0x01);
	}
	show_tools_menu(user);
	return(0x00);
}

function void show_tools_menu(obj user) {
	list opts;
	gm = user;
	string x = tile_filter[0x00];
	appendToList(opts, 0x00);
	appendToList(opts, "Set the elevation filter. Terrain scans currently affect only elevations between " + elev_min + " and " + elev_max + ".");
	appendToList(opts, 0x01);
	appendToList(opts, "Set the terrain tile filter. Currently set to " + x + ".");
	appendToList(opts, 0x02);
	appendToList(opts, "Change area of operation. Currently set to " + scan_start + " to " + scan_end + ".");
	appendToList(opts, 0x03);
	appendToList(opts, "Transition terrain.");
	appendToList(opts, 0x04);
	appendToList(opts, "Shade mountains (Defaults to mountain tiles unless overridden by the terrain tile filter).");
	appendToList(opts, 0x05);
	appendToList(opts, "Auto-embankments.");
	appendToList(opts, 0x06);
	appendToList(opts, "Place static items.");
	appendToList(opts, 0x07);
	appendToList(opts, "Change elevations.");
	appendToList(opts, 0x08);
	appendToList(opts, "Terrain fill.");
	appendToList(opts, 0x09);
	appendToList(opts, "Raise terrain.");
	appendToList(opts, 0x0A);
	appendToList(opts, "Lower terrain.");
	if (numInList(undo_history) > 0x00) {
		appendToList(opts, 0x0B);
		appendToList(opts, "Undo last operation.");
	}
	selectType(gm, this, 0x00, "Building tools menu.", opts);
	return();
}

trigger typeselected(0x00) {
	if (listindex == 0x00) {
		return(0x00);
	}
	switch(objtype) {
	case 0x00
		prompt_elevation_filter();
		break;
	case 0x01
		prompt_terrain_filter();
		break;
	case 0x02
		prompt_scan_area();
		break;
	case 0x03
		prompt_transition_type();
		break;
	case 0x04
		run_shade_mountains();
		break;
	case 0x05
		select_embankment_type();
		break;
	case 0x06
		select_statics_type();
		break;
	case 0x07
		prompt_set_elevation();
		break;
	case 0x08
		select_fill_type();
		break;
	case 0x09
		prompt_raise_terrain();
		break;
	case 0x0A
		prompt_lower_terrain();
		break;
	case 0x0B
		run_undo_terrain();
		break;
	default
		break;
	}
	return(0x00);
}

function void prompt_raise_terrain() {
	systemMessage(gm, "Enter the amount by which to move terrain up.");
	textEntry(this, gm, 0x04, 0x00, "");
	return();
}

trigger textentry(0x04) {
	if (button == 0x00) {
		show_tools_menu(gm);
		return(0x00);
	}
	elev_target = text;
	run_terrain_scan(0x08);
	return(0x01);
}

function void prompt_lower_terrain() {
	systemMessage(gm, "Enter the amount by which to move terrain lower.");
	textEntry(this, gm, 0x05, 0x00, "");
	return();
}

trigger textentry(0x05) {
	if (button == 0x00) {
		show_tools_menu(gm);
		return(0x00);
	}
	elev_target = text;
	run_terrain_scan(0x09);
	return(0x01);
}

function void prompt_elevation_filter() {
	systemMessage(gm, "Enter the low end of the elevation filter:");
	textEntry(this, gm, 0x00, 0x00, "");
	return();
}

trigger textentry(0x00) {
	if (button == 0x00) {
		show_tools_menu(gm);
		return(0x00);
	}
	elev_min = text;
	systemMessage(gm, "Enter the high end of the elevation filter:");
	textEntry(this, gm, 0x01, 0x00, "");
	return(0x00);
}

trigger textentry(0x01) {
	if (button == 0x00) {
		show_tools_menu(gm);
		return(0x00);
	}
	elev_max = text;
	show_tools_menu(gm);
	return(0x00);
}

function void prompt_terrain_filter() {
	list opts;
	string n;
	for (int i = 0x00; i < numInList(terrains); i++) {
		appendToList(opts, i);
		n = oprlist(terrains[i], 0x00);
		appendToList(opts, n);
	}
	appendToList(opts, numInList(opts));
	appendToList(opts, "None.");
	selectType(gm, this, 0x01, "Terrain types.", opts);
	return();
}

trigger typeselected(0x01) {
	if (listindex == 0x00) {
		systemMessage(gm, "Setting of terrain type cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	if (objtype > (numInList(terrains) - 0x01)) {
		tile_filter = "None";
	} else {
		copyList(tile_filter, terrains[objtype]);
	}
	show_tools_menu(gm);
	return(0x00);
}

function void prompt_scan_area() {
	systemMessage(gm, "Enter the area of operation for the terrain scan, in (x, y) (x, y) format:");
	textEntry(this, gm, 0x02, 0x00, "");
	return();
}

trigger textentry(0x02) {
	if (button == 0x00) {
		systemMessage(gm, "Setting of operations area cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	list t;
	split(t, text);
	if (numInList(t) != 0x04) {
		systemMessage(gm, "Format for operations area incorrect.");
		prompt_scan_area();
		return(0x00);
	}
	string start_x_str = t[0x00];
	string start_y_str = t[0x01];
	string end_x_str = t[0x02];
	string end_y_str = t[0x03];
	int start_x;
	int end_x;
	int start_y;
	int end_y;
	start_x = start_x_str;
	end_x = end_x_str;
	start_y = start_y_str;
	end_y = end_y_str;
	scan_start = start_x, start_y, 0x00;
	scan_end = end_x, end_y, 0x00;
	show_tools_menu(gm);
	return(0x00);
}

function void prompt_transition_type() {
	list opts;
	string n;
	for (int i = 0x00; i < numInList(transitions); i++) {
		appendToList(opts, i);
		n = oprlist(transitions[i], 0x00);
		appendToList(opts, n);
	}
	appendToList(opts, numInList(opts));
	appendToList(opts, "None.");
	selectType(gm, this, 0x02, "Transition types.", opts);
	return();
}

trigger typeselected(0x02) {
	if (listindex == 0x00) {
		systemMessage(gm, "Setting of transition type cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	if (objtype > (numInList(transitions) - 0x01)) {
		transition_table = "None";
	} else {
		copyList(transition_table, transitions[objtype]);
		copyList(mountain_tiles, transition_table[0x01]);
		copyList(water_tiles, transition_table[0x02]);
	}
	run_terrain_scan(0x03);
	return(0x00);
}

function void run_shade_mountains() {
	run_terrain_scan(0x05);
	return();
}

function void select_embankment_type() {
	list opts;
	string n;
	for (int i = 0x00; i < numInList(embankments); i++) {
		appendToList(opts, i);
		n = oprlist(embankments[i], 0x00);
		appendToList(opts, n);
	}
	appendToList(opts, numInList(opts));
	appendToList(opts, "None.");
	selectType(gm, this, 0x05, "Embankment types.", opts);
	return();
}

trigger typeselected(0x05) {
	if (listindex == 0x00) {
		systemMessage(gm, "Setting of embankment type cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	if (objtype > (numInList(embankments) - 0x01)) {
		transition_table = "None";
	} else {
		copyList(transition_table, embankments[objtype]);
		copyList(water_tiles, tile_filter);
		tile_filter = "None";
	}
	run_terrain_scan(0x06);
	return(0x00);
}

function void select_statics_type() {
	list opts;
	appendToList(opts, 0x00);
	appendToList(opts, "Full forest");
	appendToList(opts, 0x01);
	appendToList(opts, "Desert flora and rocks");
	appendToList(opts, 0x02);
	appendToList(opts, "Jungle");
	appendToList(opts, 0x03);
	appendToList(opts, "Grassland flora");
	appendToList(opts, 0x04);
	appendToList(opts, "Trees only");
	appendToList(opts, 0x05);
	appendToList(opts, "Swamp flora (run on muck only)");
	appendToList(opts, 0x06);
	appendToList(opts, "Swamp trees (run on swamp water only)");
	appendToList(opts, 0x07);
	appendToList(opts, "Arctic forest");
	appendToList(opts, 0x08);
	appendToList(opts, "Underbrush");
	appendToList(opts, 0x09);
	appendToList(opts, "Rocks");
	appendToList(opts, 0x0A);
	appendToList(opts, "Mushrooms");
	selectType(gm, this, 0x04, "Terrain types.", opts);
	return();
}

trigger typeselected(0x04) {
	if (listindex == 0x00) {
		systemMessage(gm, "Terrain fill cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	flora_type = objtype;
	run_terrain_scan(0x04);
	return(0x00);
}

function void run_undo_terrain() {
	run_terrain_scan(0x07);
	return();
}

function void prompt_set_elevation() {
	systemMessage(gm, "Enter the target elevation, then a +/- fudge factor for randomization, in the format (a, b):");
	textEntry(this, gm, 0x03, 0x00, "");
	return();
}

trigger textentry(0x03) {
	if (button == 0x00) {
		systemMessage(gm, "Elevation changes cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	list t;
	split(t, text);
	if (numInList(t) != 0x02) {
		systemMessage(gm, "Format for elevations change incorrect.");
		prompt_set_elevation();
		return(0x00);
	}
	string elev_str = t[0x00];
	string fudge_str = t[0x01];
	elev_target = elev_str;
	elev_fudge = fudge_str;
	run_terrain_scan(0x02);
	show_tools_menu(gm);
	return(0x00);
}

function void select_fill_type() {
	list opts;
	string n;
	for (int i = 0x00; i < numInList(terrains); i++) {
		appendToList(opts, i);
		n = oprlist(terrains[i], 0x00);
		appendToList(opts, n);
	}
	appendToList(opts, numInList(opts));
	appendToList(opts, "None.");
	selectType(gm, this, 0x03, "Terrain types.", opts);
	return();
}

trigger typeselected(0x03) {
	if (listindex == 0x00) {
		systemMessage(gm, "Terrain fill cancelled.");
		show_tools_menu(gm);
		return(0x00);
	}
	if (objtype > (numInList(terrains) - 0x01)) {
		systemMessage(gm, "Terrain fill cancelled.");
		show_tools_menu(gm);
		return(0x00);
	} else {
		copyList(random_tiles, terrains[objtype]);
		run_terrain_scan(0x01);
	}
	show_tools_menu(gm);
	return(0x00);
}
