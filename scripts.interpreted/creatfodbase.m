inherits spelskil;

function int create_food_at(obj user, loc place) {
	int success = 0x00;
	loc user_loc = getLocation(user);
	faceHere(user, getDirectionInternal(user_loc, place));
	list food_types = 0x09D1, 0x09D3, 0x097D, 0x09EB, 0x097B, 0x09F2, 0x09B7, 0x09C0, 0x09D0, 0x09D2;
	int die_roll = dice(0x01, 0x0A);
	obj food = createGlobalObjectAt(0x09D3, place);
	if (isValid(food)) {
		sfx(place, 0x01E2, 0x00);
		success = 0x01;
	}
	schedule_cleanup(this);
	return(success);
}
