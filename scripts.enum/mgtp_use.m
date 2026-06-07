inherits spelskil;

member int power;

trigger creation {
	if (hasObjVar(this, "magictrappower")) {
		power = getObjVar(this, "magictrappower");
		removeObjVar(this, "magictrappower");
	}
	return(0x01);
}

trigger use {
	loc there = getLocation(this);
	loc loc_east = there;
	loc loc_north = there;
	loc loc_west = there;
	loc loc_south = there;
	setX(loc_east, getX(there) + 0x01);
	setY(loc_north, getY(there) - 0x01);
	setX(loc_west, getX(there) - 0x01);
	setY(loc_south, getY(there) + 0x01);
	doLocAnimation(loc_east, 0x36BD, 0x0A, 0x0F, 0x00, 0x00);
	doLocAnimation(loc_north, 0x36BD, 0x0A, 0x0F, 0x00, 0x00);
	doLocAnimation(loc_west, 0x36BD, 0x0A, 0x0F, 0x00, 0x00);
	doLocAnimation(loc_south, 0x36BD, 0x0A, 0x0F, 0x00, 0x00);
	doLocAnimation(getLocation(this), 0x36BD, 0x0A, 0x0F, 0x00, 0x00);
	sfx(getLocation(this), 0x0207, 0x00);
	int damage = apply_spell_damage_by_circle(NULL(), 0x02, NULL(), user, 0x04, 0x00);
	detachScript(this, "mgtp_use");
	return(0x00);
}
