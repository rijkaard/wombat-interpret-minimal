inherits housedeed;

function void setup_extras(obj house, loc place) {
	obj created;
	loc pos;
	if (house != NULL()) {
		pos = place;
		changeLoc(pos, 0x05, 0x02, 0x07);
		created = createGlobalObjectAt(0x1061, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x01, 0x00, 0x00);
		created = createGlobalObjectAt(0x1062, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00 - 0x01, 0x01, 0x00);
		created = createGlobalObjectAt(0x104A, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00 - 0x01, 0x02, 0x00);
		created = createGlobalObjectAt(0x1015, pos);
		mark_for_multi_delete(created);
	}
	return();
}
