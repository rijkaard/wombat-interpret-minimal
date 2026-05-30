inherits globals;

member int is_active;

member int wave_count;

member int total_spawned;

member int wave_limit;

function void open_gate(obj gate, int it) {
	setType(gate, 0x01);
	doLocAnimation(getLocation(gate), 0x1FCB, 0x09, 0x20, 0x00, 0x00);
	callback(gate, 0x01, 0x63);
	callback(gate, 0x04, it);
	return();
}

function void close_black_gate__MAYBE(obj gate) {
	doLocAnimation(getLocation(gate), 0x1FCB, 0x09, 0x20, 0x01, 0x00);
	setType(gate, 0x01);
	is_active = 0x00;
	return();
}

trigger creation {
	is_active = 0x00;
	wave_count = 0x00;
	total_spawned = 0x00;
	wave_limit = 0x03;
	callback(this, 0x01, 0x60);
	return(0x01);
}

trigger enterrange(0x09) {
	if (isPlayer(target)) {
		systemMessage(target, "A sense of great foreboding overtakes you.");
	}
	return(0x01);
}

trigger enterrange(0x00) {
	if (is_active) {
		if (isMobile(target)) {
			int obj_type = getObjType(target);
			if (obj_type != 0x09) {
				int dmg = getCurHP(target) + 0x01;
				loseHP(target, dmg);
			}
		}
	}
	return(0x00);
}

trigger callback(0x61) {
	loc there = getLocation(this);
	int dx = random(0x00, 0x05) - 0x02;
	int dy = random(0x00, 0x05) - 0x02;
	setX(there, getX(there) + dx);
	setY(there, getY(there) + dy);
	int find = findGoodSpotNear(there, 0x04, 0x10, 0x01);
	obj daemon = NULL();
	if (find) {
		daemon = createGlobalNPCAt(0x07C5, there, 0x00);
	}
	if (daemon != NULL()) {
		total_spawned++;
		wave_count++;
	}
	if (wave_count >= wave_limit) {
		close_black_gate__MAYBE(this);
		int time = random(0x0A, 0x3C);
		callback(this, time, 0x60);
		wave_count = 0x00;
	} else {
		int delay = random(0x01, 0x03);
		callback(this, delay, 0x61);
	}
	return(0x01);
}

trigger callback(0x60) {
	open_gate(this, 0x61);
	return(0x01);
}

trigger callback(0x63) {
	setType(this, 0x1FD3);
	is_active = 0x01;
	return(0x01);
}
