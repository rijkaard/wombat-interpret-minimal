inherits spelskil;

function int create_fire_field(obj user, loc place) {
	int spell_success = 0x00;
	loc user_loc = getLocation(user);
	int success = 0x00;
	int walldur = get_wall_duration(user, get_spell_circle(this));
	faceHere(user, getDirectionInternal(user_loc, place));
	int dx = getX(place) - getX(user_loc);
	int dy = getY(place) - getY(user_loc);
	loc loc_plus1 = place;
	loc loc_minus1 = place;
	loc loc_plus2 = place;
	loc loc_minus2 = place;
	int field_type;
	int abs_dx = dx;
	if (abs_dx < 0x00) {
		abs_dx = 0x00 - abs_dx;
	}
	int abs_dy = dy;
	if (abs_dy < 0x00) {
		abs_dy = 0x00 - abs_dy;
	}
	if (abs_dx < abs_dy) {
		setX(loc_plus1, getX(place) + 0x01);
		setX(loc_minus1, getX(place) - 0x01);
		setX(loc_plus2, getX(place) + 0x02);
		setX(loc_minus2, getX(place) - 0x02);
		field_type = 0x398C;
	} else {
		setY(loc_plus1, getY(place) + 0x01);
		setY(loc_minus1, getY(place) - 0x01);
		setY(loc_plus2, getY(place) + 0x02);
		setY(loc_minus2, getY(place) - 0x02);
		field_type = 0x3996;
	}
	doLocAnimation(place, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc_plus1, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc_minus1, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc_plus2, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(loc_minus2, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	int damage = 0x00;
	if (create_field_wall(user, 0x37C3, place, field_type, damage, walldur, 0x01, 0x01) || create_field_wall(user, 0x37C3, loc_plus1, field_type, damage, walldur, 0x01, 0x02) || create_field_wall(user, 0x37C3, loc_minus1, field_type, damage, walldur, 0x01, 0x03) || create_field_wall(user, 0x37C3, loc_plus2, field_type, damage, walldur, 0x01, 0x04) || create_field_wall(user, 0x37C3, loc_minus2, field_type, damage, walldur, 0x01, 0x05)) {
		spell_success = 0x01;
		sfx(place, 0x020C, 0x00);
	}
	if (!getCompileFlag(0x01)) {
		set_criminal(user, walldur);
	}
	schedule_cleanup(this);
	return(spell_success);
}
