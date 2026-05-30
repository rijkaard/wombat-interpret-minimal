inherits spelskil;

function int cast_wall_of_stone(obj user, loc place) {
	int success = 0x00;
	int damage;
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, place));
	int walldur = 0x0A;
	int dx = getX(place) - getX(user_loc);
	int dy = getY(place) - getY(user_loc);
	loc loc_left = place;
	loc loc_right = place;
	int abs_dx = dx;
	if (abs_dx < 0x00) {
		abs_dx = 0x00 - abs_dx;
	}
	int abs_dy = dy;
	if (abs_dy < 0x00) {
		abs_dy = 0x00 - abs_dy;
	}
	if (abs_dx < abs_dy) {
		setX(loc_left, getX(loc_left) + 0x01);
		setX(loc_right, getX(loc_right) - 0x01);
	} else {
		setY(loc_left, getY(loc_left) + 0x01);
		setY(loc_right, getY(loc_right) - 0x01);
	}
	int wall_type = 0x82;
	int wall_delay = 0x04;
	doLocAnimation(place, 0x376A, 0x09, 0x20, 0x00, 0x00);
	doLocAnimation(loc_left, 0x376A, 0x09, 0x20, 0x00, 0x00);
	doLocAnimation(loc_right, 0x376A, 0x09, 0x20, 0x00, 0x00);
	if (create_field_wall(user, 0x82, place, wall_type, wall_delay, walldur, 0x01, 0x01) || create_field_wall(user, 0x82, loc_left, wall_type, wall_delay, walldur, 0x01, 0x02) || create_field_wall(user, 0x82, loc_right, wall_type, wall_delay, walldur, 0x01, 0x03)) {
		sfx(place, 0x01F6, 0x01);
		success = 0x01;
	}
	if (!getCompileFlag(0x01)) {
		set_criminal(user, walldur);
	}
	schedule_cleanup(this);
	return(success);
}
