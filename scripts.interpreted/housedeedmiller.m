inherits housedeed;

function void setup_extras(obj house, loc place) {
	obj item;
	if (house != NULL()) {
		setZ(place, getZ(place) + 0x07);
		setX(place, getX(place) - 0x02);
		setY(place, getY(place) - 0x02);
		item = createGlobalObjectAt(0x192C, place);
		mark_for_multi_delete(item);
		setY(place, getY(place) + 0x01);
		item = createGlobalObjectAt(0x192E, place);
		mark_for_multi_delete(item);
		setY(place, getY(place) + 0x01);
		item = createGlobalObjectAt(0x1930, place);
		mark_for_multi_delete(item);
		setY(place, getY(place) - 0x02);
		setX(place, getX(place) + 0x02);
		item = createGlobalObjectAt(0x0931, place);
		mark_for_multi_delete(item);
		setX(place, getX(place) + 0x01);
		item = createGlobalObjectAt(0x0930, place);
		mark_for_multi_delete(item);
	}
	return();
}
