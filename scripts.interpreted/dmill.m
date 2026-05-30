inherits housedeed;

function void setup_extras(obj house, loc place) {
	obj created;
	if (house != NULL()) {
		loc pos;
		pos = place;
		changeLoc(pos, 0x05, 0x00 - 0x06, 0x07);
		created = createGlobalObjectAt(0x0943, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00 - 0x01, 0x00, 0x00);
		created = createGlobalObjectAt(0x0944, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x01, 0x00, 0x15);
		created = createGlobalObjectAt(0x08D2, pos);
		mark_for_multi_delete(created);
		pos = place;
		changeLoc(pos, 0x03, 0x00, 0x08);
		created = createGlobalObjectAt(0x192C, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00, 0x01, 0x00);
		created = createGlobalObjectAt(0x192E, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00, 0x01, 0x00);
		created = createGlobalObjectAt(0x1937, pos);
		mark_for_multi_delete(created);
	}
	return();
}
