inherits globals;

trigger creation {
	setType(this, 0x1122);
	return(0x00);
}

trigger enterrange(0x00) {
	list f_args;
	string door_id;
	loc pos_one = 0x1418, 0x02D4, 0x00;
	loc pos_two = 0x141D, 0x02CF, 0x00;
	loc pos_three = 0x141B, 0x02CD, 0x00;
	loc pos_four = 0x141B, 0x02C9, 0x00;
	loc pos_five = 0x141F, 0x02C9, 0x00;
	loc pos_six = 0x141F, 0x02CB, 0x00;
	loc pos_seven = 0x1421, 0x02CD, 0x00;
	loc pos_eight = 0x1423, 0x02CD, 0x00;
	loc self_loc = getLocation(this);
	loc msg_loc = 0x1418, 0x02C8, 0x00;
	doLocAnimation(getLocation(this), 0x1122, 0x02, 0x04, 0x00, 0x00);
	if (self_loc == pos_one) {
		door_id = "d_one";
	}
	if (self_loc == pos_two) {
		door_id = "d_two";
	}
	if (self_loc == pos_three) {
		door_id = "d_three";
	}
	if (self_loc == pos_four) {
		door_id = "d_four";
	}
	if (self_loc == pos_five) {
		door_id = "d_five";
	}
	if (self_loc == pos_six) {
		door_id = "d_six";
	}
	if (self_loc == pos_seven) {
		door_id = "d_seven";
	}
	if (self_loc == pos_eight) {
		door_id = "d_eight";
	}
	messageToRange(msg_loc, 0x01, door_id, f_args);
	return(0x01);
}
