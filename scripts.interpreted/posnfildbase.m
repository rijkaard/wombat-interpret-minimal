inherits spelskil;

function int apply_poison_field(obj user, loc place) {
	int field_created = 0x00;
	loc caster_loc = getLocation(user);
	int success = 0x00;
	int walldur = get_wall_duration(user, get_spell_circle(this));
	faceHere(user, getDirectionInternal(caster_loc, place));
	int dx = getX(place) - getX(caster_loc);
	int dy = getY(place) - getY(caster_loc);
	loc pos1 = place;
	loc pos2 = place;
	loc pos3 = place;
	loc pos4 = place;
	int field_tile_type;
	int abs_dx = dx;
	if (abs_dx < 0x00) {
		abs_dx = 0x00 - abs_dx;
	}
	int abs_dy = dy;
	if (abs_dy < 0x00) {
		abs_dy = 0x00 - abs_dy;
	}
	if (abs_dx < abs_dy) {
		setX(pos1, getX(place) + 0x01);
		setX(pos2, getX(place) - 0x01);
		setX(pos3, getX(place) + 0x02);
		setX(pos4, getX(place) - 0x02);
		field_tile_type = 0x3914;
	} else {
		setY(pos1, getY(place) + 0x01);
		setY(pos2, getY(place) - 0x01);
		setY(pos3, getY(place) + 0x02);
		setY(pos4, getY(place) - 0x02);
		field_tile_type = 0x3920;
	}
	doLocAnimation(place, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(pos1, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(pos2, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(pos3, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	doLocAnimation(pos4, 0x376A, 0x09, 0x0A, 0x00, 0x00);
	int is_harmful = 0x01;
	if (create_field_wall(user, 0x37C3, place, field_tile_type, is_harmful, walldur, 0x01, 0x01) || create_field_wall(user, 0x37C3, pos1, field_tile_type, is_harmful, walldur, 0x01, 0x02) || create_field_wall(user, 0x37C3, pos2, field_tile_type, is_harmful, walldur, 0x01, 0x03) || create_field_wall(user, 0x37C3, pos3, field_tile_type, is_harmful, walldur, 0x01, 0x04) || create_field_wall(user, 0x37C3, pos4, field_tile_type, is_harmful, walldur, 0x01, 0x05)) {
		sfx(place, 0x020B, 0x00);
		field_created = 0x01;
	}
	if (!getCompileFlag(0x01)) {
		set_criminal(user, walldur);
	}
	schedule_cleanup(this);
	return(field_created);
}
