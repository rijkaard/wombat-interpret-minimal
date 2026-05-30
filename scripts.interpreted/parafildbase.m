inherits spelskil;

function int cast_paralyze_field(obj user, loc place) {
	int spell_success = 0x00;
	loc user_loc = getLocation(user);
	int success = 0x00;
	int walldur = get_wall_duration(user, get_spell_circle(this));
	faceHere(user, getDirectionInternal(user_loc, place));
	int dx = getX(place) - getX(user_loc);
	int dy = getY(place) - getY(user_loc);
	loc loc1 = place;
	loc loc2 = place;
	loc loc3 = place;
	loc loc4 = place;
	int wall_tile;
	int abs_dx = dx;
	if (abs_dx < 0x00) {
		abs_dx = 0x00 - abs_dx;
	}
	int abs_dy = dy;
	if (abs_dy < 0x00) {
		abs_dy = 0x00 - abs_dy;
	}
	if (abs_dx < abs_dy) {
		setX(loc1, getX(place) + 0x01);
		setX(loc2, getX(place) - 0x01);
		setX(loc3, getX(place) + 0x02);
		setX(loc4, getX(place) - 0x02);
		wall_tile = 0x3967;
	} else {
		setY(loc1, getY(place) + 0x01);
		setY(loc2, getY(place) - 0x01);
		setY(loc3, getY(place) + 0x02);
		setY(loc4, getY(place) - 0x02);
		wall_tile = 0x3979;
	}
	doLocAnimation(place, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc1, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc2, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc3, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc4, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	int field_strength = 0x02;
	if (create_field_wall(user, 0x37C3, place, wall_tile, field_strength, walldur, 0x01, 0x01) || create_field_wall(user, 0x37C3, loc1, wall_tile, field_strength, walldur, 0x01, 0x02) || create_field_wall(user, 0x37C3, loc2, wall_tile, field_strength, walldur, 0x01, 0x03) || create_field_wall(user, 0x37C3, loc3, wall_tile, field_strength, walldur, 0x01, 0x04) || create_field_wall(user, 0x37C3, loc4, wall_tile, field_strength, walldur, 0x01, 0x05)) {
		sfx(place, 0x020B, 0x00);
		spell_success = 0x01;
	}
	if (!getCompileFlag(0x01)) {
		set_criminal(user, walldur);
	}
	schedule_cleanup(this);
	return(spell_success);
}
