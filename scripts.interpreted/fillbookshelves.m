inherits furniture;

function int fill_bookshelf(obj bookshelf) {
	if (containedBy(bookshelf) != NULL()) {
		return(0x01);
	}
	if (!thinksItsAtHome(this)) {
		return(0x01);
	}
	int i;
	int fill_count;
	int rand_idx;
	int max_items = 0x02;
	list contents;
	list book_types = 0x0FEF, 0x0FF0;
	obj created;
	getContents(contents, bookshelf);
	if (numInList(book_types) < 0x01) {
		return(0x00);
	}
	if (numInList(contents) <= max_items) {
		fill_count = random(0x00, ((max_items - numInList(contents)) + 0x01) * 0x02);
		if (fill_count > 0x04) {
			fill_count = 0x04;
		}
		for (i = 0x00; i < fill_count; i++) {
			rand_idx = random(0x00, numInList(book_types) - 0x01);
			created = requestCreateObjectIn(book_types[rand_idx], bookshelf);
		}
	}
	return(0x00);
}

trigger decay {
	list contents;
	getContents(contents, this);
	if (numInList(contents) <= 0x02) {
		if (!hasObjVar(this, "filled")) {
			fill_bookshelf(this);
			setObjVar(this, "filled", 0x01);
		} else if (!hasCallback(this, 0x50)) {
			callback(this, random(0x0E10, 0x1518), 0x50);
		}
	}
	return(0x01);
}

trigger callback(0x50) {
	removeObjVar(this, "filled");
	return(0x00);
}
