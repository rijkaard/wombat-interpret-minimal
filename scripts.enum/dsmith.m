inherits housedeed;

function void setup_extras(obj house, loc place) {
	obj created;
	loc pos;
	if (house != NULL()) {
		pos = place;
		changeLoc(pos, 0x03, 0x02, 0x07);
		created = createGlobalObjectAt(0x197A, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x01, 0x00, 0x00);
		created = createGlobalObjectAt(0x197E, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x01, 0x00, 0x00);
		created = createGlobalObjectAt(0x1982, pos);
		mark_for_multi_delete(created);
		changeLoc(pos, 0x00, 0x02, 0x00);
		created = createGlobalObjectAt(0x0FAF, pos);
		mark_for_multi_delete(created);
	}
	return();
}
