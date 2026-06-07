inherits globals;

trigger creation {
	int roll;
	obj item;
	int body_type = getObjType(this);
	if (body_type == 0x29) {
		item = requestCreateObjectIn(0x13B4, this);
		if (item == NULL()) {
			setType(this, 0x11);
		}
		return(0x01);
	}
	if (body_type == 0x07) {
		item = requestCreateObjectIn(0x1F0B, this);
		if (item == NULL()) {
			setType(this, 0x11);
			return(0x01);
		}
		item = requestCreateObjectIn(0x1443, this);
		if (item == NULL()) {
			setType(this, 0x11);
			return(0x01);
		}
		item = requestCreateObjectIn(0x13EC, this);
		if (item == NULL()) {
			setType(this, 0x11);
			return(0x01);
		}
	}
	if (body_type == 0x2C) {
		roll = random(0x01, 0x04);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1407, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x0F5C, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x143B, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x1439, this);
		}
		if (item == NULL()) {
			setType(this, 0x2A);
		}
		return(0x01);
	}
	if (body_type == 0x2D) {
		roll = random(0x01, 0x08);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1441, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x143F, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x13FF, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x0EFA, this);
		}
		if (roll == 0x05) {
			item = requestCreateObjectIn(0x0F61, this);
		}
		if (roll == 0x06) {
			item = requestCreateObjectIn(0x13B8, this);
		}
		if (roll == 0x07) {
			item = requestCreateObjectIn(0x13B9, this);
		}
		if (roll == 0x08) {
			item = requestCreateObjectIn(0x13B6, this);
		}
		if (item == NULL()) {
			setType(this, 0x2A);
		}
		return(0x01);
	}
	if (body_type == 0x23) {
		item = requestCreateObjectIn(0x0F62, this);
		if (item == NULL()) {
			setType(this, 0x21);
		}
		return(0x01);
	}
	if (body_type == 0x24) {
		roll = random(0x01, 0x04);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1407, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x0F5C, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x143B, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x1439, this);
		}
		if (item == NULL()) {
			setType(this, 0x21);
		}
		return(0x01);
	}
	if (body_type == 0x02) {
		item = requestCreateObjectIn(0x0F47, this);
		if (item == NULL()) {
			setType(this, 0x12);
		}
		return(0x01);
	}
	if (body_type == 0x0A) {
		roll = random(0x01, 0x08);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1441, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x143F, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x13FF, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x0EFA, this);
		}
		if (roll == 0x05) {
			item = requestCreateObjectIn(0x0F61, this);
		}
		if (roll == 0x06) {
			item = requestCreateObjectIn(0x13B8, this);
		}
		if (roll == 0x07) {
			item = requestCreateObjectIn(0x13B9, this);
		}
		if (roll == 0x08) {
			item = requestCreateObjectIn(0x13B6, this);
		}
		if (item == NULL()) {
			setType(this, 0x09);
		}
		return(0x01);
	}
	if (body_type == 0x38) {
		item = requestCreateObjectIn(0x0F47, this);
		if (item == NULL()) {
			setType(this, 0x32);
		}
		return(0x01);
	}
	if (body_type == 0x39) {
		item = requestCreateObjectIn(0x1B7A, this);
		if (item == NULL()) {
			setType(this, 0x32);
			return(0x01);
		}
		roll = random(0x01, 0x08);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1441, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x143F, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x13FF, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x0EFA, this);
		}
		if (roll == 0x05) {
			item = requestCreateObjectIn(0x0F61, this);
		}
		if (roll == 0x06) {
			item = requestCreateObjectIn(0x13B8, this);
		}
		if (roll == 0x07) {
			item = requestCreateObjectIn(0x13B9, this);
		}
		if (roll == 0x08) {
			item = requestCreateObjectIn(0x13B6, this);
		}
		if (item == NULL()) {
			setType(this, 0x32);
		}
		return(0x01);
	}
	if (body_type == 0x35) {
		item = requestCreateObjectIn(0x0F47, this);
		if (item == NULL()) {
			setType(this, 0x36);
		}
		return(0x01);
	}
	if (body_type == 0x37) {
		roll = random(0x01, 0x04);
		if (roll == 0x01) {
			item = requestCreateObjectIn(0x1407, this);
		}
		if (roll == 0x02) {
			item = requestCreateObjectIn(0x0F5C, this);
		}
		if (roll == 0x03) {
			item = requestCreateObjectIn(0x143B, this);
		}
		if (roll == 0x04) {
			item = requestCreateObjectIn(0x1439, this);
		}
		if (item == NULL()) {
			setType(this, 0x36);
		}
		return(0x01);
	}
	return(0x01);
}
