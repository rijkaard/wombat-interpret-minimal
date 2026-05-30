inherits sndfx;

member loc loc_first;

member loc loc_second;

member int sequence_step;

member obj marker;

member obj subject;

member obj speaker_first;

member obj speaker_second;

member obj beacon_first;

member obj beacon_second;

member int sequence_active;

forward void start_sequence();

trigger message("activate") {
	list mobs;
	int i = 0x00;
	marker = this;
	getMobsAt(mobs, getLocation(this));
	subject = mobs[i];
	start_sequence();
	return(0x00);
}

trigger callback(0x2F) {
	if (isValid(beacon_first)) {
		deleteObject(beacon_first);
	}
	switch(sequence_step) {
	case 0x01
		beacon_first = createGlobalObjectAt(0x1EEC, loc_first);
		shortcallback(marker, 0x02, 0x2F);
		sequence_step = 0x02;
		break;
	case 0x02
		speaker_first = createGlobalObjectAt(0x1EF3, loc_first);
		barkToHued(speaker_first, subject, 0x22, "Start as the sun and move with time. Consider A FEW before the elements are placed, for a lack of order can bring Relvinian's bane.");
		sequence_step = 0x03;
		callback(marker, 0x09, 0x2F);
		break;
	case 0x03
		deleteObject(speaker_first);
		beacon_second = createGlobalObjectAt(0x1EEC, loc_second);
		sequence_step = 0x04;
		shortcallback(marker, 0x02, 0x2F);
		break;
	case 0x04
		deleteObject(beacon_second);
		speaker_second = createGlobalObjectAt(0x1EF3, loc_second);
		barkToHued(speaker_second, subject, 0x22, "Once thy decision has been made, proceed to the altar and between the flames pronounce the Master's name.");
		sequence_step = 0x05;
		callback(marker, 0x09, 0x2F);
		break;
	case 0x05
		deleteObject(speaker_second);
		sequence_active = 0x00;
		break;
	default
		break;
	}
	return(0x00);
}

function void start_sequence() {
	loc_first = 0x0469, 0x08B7, 0x1E;
	loc_second = 0x0469, 0x08B5, 0x1E;
	sequence_step = 0x01;
	if (sequence_active == 0x00) {
		sequence_active = 0x01;
		shortcallback(marker, 0x01, 0x2F);
	}
	return();
}
