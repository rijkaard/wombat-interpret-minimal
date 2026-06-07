inherits housedeed;

function void setup_extras(obj house, loc place) {
	obj item;
	if (house != NULL()) {
		setZ(place, getZ(place) + 0x07);
		setX(place, getX(place) - 0x01);
		setY(place, getY(place) - 0x02);
		item = createGlobalObjectAt(0x1019, place);
		mark_for_multi_delete(item);
		setX(place, getX(place) + 0x02);
		item = createGlobalObjectAt(0x1061, place);
		mark_for_multi_delete(item);
		setX(place, getX(place) + 0x01);
		item = createGlobalObjectAt(0x1062, place);
		mark_for_multi_delete(item);
	}
	return();
}
