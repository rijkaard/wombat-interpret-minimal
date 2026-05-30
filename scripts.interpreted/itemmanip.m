inherits sndfx;

function void change_type(obj m_target, int newType) {
	int old_type = getObjType(m_target);
	string old_script = old_type;
	string new_script = newType;
	if (old_type != newType) {
		setType(m_target, newType);
		attachScript(m_target, new_script);
		detachScript(m_target, old_script);
	}
	return();
}

function void bark_resource_count(obj looker, string resource) {
	int count;
	if (getResource(count, this, resource, 0x03, 0x02)) {
		if (count > 0x00) {
			string count_str = count;
			barkTo(this, looker, "contains " + count_str + " " + resource);
		}
	} else {
	}
	return();
}

function void fill_container_4(list out, obj src, obj dst, string resource) {
	int src_amt;
	int dst_amt;
	int dst_cap;
	int remaining;
	int dst_total;
	int ok;
	ok = getResource(src_amt, src, resource, 0x03, 0x02);
	ok = getResource(dst_amt, dst, resource, 0x03, 0x02);
	ok = getResource(dst_cap, dst, resource, 0x03, 0x00);
	if (dst_amt + src_amt > dst_cap) {
		transferResources(dst, src, dst_cap - dst_amt, resource);
		dst_total = dst_cap;
		remaining = src_amt - (dst_cap - dst_amt);
	} else {
		transferResources(dst, src, src_amt, resource);
		dst_total = dst_amt + src_amt;
		remaining = 0x00;
	}
	appendToList(out, remaining);
	appendToList(out, dst_total);
	return();
}

function void update_facing_type(int north, int east, int south, int west) {
	loc cur_loc = getLocation(this);
	loc ref_loc;
	if (hasObjVar(this, "LOCATION")) {
		ref_loc = getObjVar(this, "LOCATION");
	} else {
		ref_loc = cur_loc;
	}
	int ref_x = getX(ref_loc);
	int ref_y = getY(ref_loc);
	int cur_x = getX(cur_loc);
	int cur_y = getY(cur_loc);
	int dx = ref_x - cur_x;
	int dy = ref_y - cur_y;
	int abs_dx;
	int abs_dy;
	int neg_one = 0x00 - 0x01;
	if (dx < 0x00) {
		abs_dx = dx * neg_one;
	} else {
		abs_dx = dx;
	}
	if (dy < 0x00) {
		abs_dy = dy * neg_one;
	} else {
		abs_dy = dy;
	}
	if (abs_dx == abs_dy) {
		if ((abs_dx == 0x00) && (abs_dy == 0x00)) {
			return();
		}
		int rand_tie = random(0x00, 0x01);
		if (rand_tie) {
			if (dx > 0x00) {
				change_type(this, west);
			} else {
				change_type(this, east);
			}
		} else {
			if (dy > 0x00) {
				change_type(this, north);
			} else {
				change_type(this, south);
			}
		}
	} else {
		if (abs_dx > abs_dy) {
			if (dx > 0x00) {
				change_type(this, west);
			} else {
				change_type(this, east);
			}
		} else {
			if (dy > 0x00) {
				change_type(this, north);
			} else {
				change_type(this, south);
			}
		}
	}
	loc location = getLocation(this);
	setObjVar(this, "LOCATION", location);
	return();
}

function int is_tree_type(int type) {
	switch(type) {
	case 0x0C95
	case 0x0C96
	case 0x0C9E
	case 0x0CCA
	case 0x0CCB
	case 0x0CCC
	case 0x0CCD
	case 0x0CCE
	case 0x0CCF
	case 0x0CD0
	case 0x0CD1
	case 0x0CD2
	case 0x0CD3
	case 0x0CD4
	case 0x0CD5
	case 0x0CD6
	case 0x0CD7
	case 0x0CD8
	case 0x0CD9
	case 0x0CDA
	case 0x0CDB
	case 0x0CDC
	case 0x0CDD
	case 0x0CDE
	case 0x0CDF
	case 0x0CE0
	case 0x0CE1
	case 0x0CE2
	case 0x0CE3
	case 0x0CE4
	case 0x0CE5
	case 0x0CE6
	case 0x0CE8
	case 0x0CF8
	case 0x0CF9
	case 0x0CFA
	case 0x0CFB
	case 0x0CFC
	case 0x0CFD
	case 0x0CFE
	case 0x0CFF
	case 0x0D00
	case 0x0D01
	case 0x0D02
	case 0x0D03
	case 0x0D41
	case 0x0D42
	case 0x0D43
	case 0x0D44
	case 0x0D45
	case 0x0D46
	case 0x0D47
	case 0x0D48
	case 0x0D49
	case 0x0D4A
	case 0x0D4B
	case 0x0D4C
	case 0x0D4D
	case 0x0D4E
	case 0x0D4F
	case 0x0D50
	case 0x0D51
	case 0x0D52
	case 0x0D53
	case 0x0D6E
	case 0x0D6F
	case 0x0D70
	case 0x0D71
	case 0x0D72
	case 0x0D73
	case 0x0D74
	case 0x0D75
	case 0x0D76
	case 0x0D77
	case 0x0D78
	case 0x0D79
	case 0x0D7A
	case 0x0D7B
	case 0x0D7C
	case 0x0D7D
	case 0x0D7E
	case 0x0D7F
	case 0x0D84
	case 0x0D85
	case 0x0D86
	case 0x0D87
	case 0x0D88
	case 0x0D89
	case 0x0D8A
	case 0x0D8B
	case 0x0D8C
	case 0x0D8D
	case 0x0D8E
	case 0x0D8F
	case 0x0D90
	case 0x0D94
	case 0x0D95
	case 0x0D96
	case 0x0D97
	case 0x0D98
	case 0x0D99
	case 0x0D9A
	case 0x0D9A
	case 0x0D9C
	case 0x0D9D
	case 0x0D9E
	case 0x0D9F
	case 0x0DA0
	case 0x0DA1
	case 0x0DA2
	case 0x0DA3
	case 0x0DA4
	case 0x0DA5
	case 0x0DA6
	case 0x0DA7
	case 0x0DA8
	case 0x0DA9
	case 0x0DAA
	case 0x0DAB
	case 0x12B6
	case 0x12B7
	case 0x12B8
	case 0x12B9
	case 0x12BA
	case 0x12BB
	case 0x12BC
	case 0x12BD
	case 0x12BE
	case 0x1323
	case 0x12C0
	case 0x12C1
	case 0x12C2
	case 0x12C3
	case 0x12C4
	case 0x12C5
	case 0x12C6
	case 0x12C7
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int is_minable_object(int obj_type) {
	switch(obj_type) {
	case 0x025C
	case 0x025D
	case 0x025E
	case 0x025F
	case 0x0260
	case 0x0261
	case 0x0262
	case 0x0263
	case 0x0264
	case 0x0265
	case 0x0266
	case 0x0267
	case 0x0268
	case 0x0269
	case 0x026A
	case 0x026B
	case 0x026C
	case 0x026D
	case 0x026E
	case 0x026F
	case 0x0270
	case 0x0271
	case 0x0272
	case 0x0273
	case 0x0274
	case 0x0275
	case 0x0276
	case 0x027D
	case 0x027E
	case 0x027F
	case 0x0280
	case 0x053B
	case 0x053C
	case 0x053D
	case 0x053E
	case 0x053F
	case 0x0540
	case 0x0541
	case 0x0542
	case 0x0543
	case 0x0544
	case 0x0545
	case 0x0546
	case 0x0547
	case 0x0548
	case 0x0549
	case 0x054A
	case 0x054B
	case 0x054C
	case 0x054D
	case 0x054E
	case 0x054F
	case 0x0551
	case 0x0552
	case 0x0553
	case 0x056A
	case 0x16E4
	case 0x16E5
	case 0x16E6
	case 0x16E7
	case 0x16E8
	case 0x16E9
	case 0x16EA
	case 0x16EB
	case 0x16EC
	case 0x16ED
	case 0x16EE
	case 0x16EF
	case 0x16F0
	case 0x16F1
	case 0x16F2
	case 0x16F3
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int is_minable_tile(int tile_type) {
	if ((tile_type >= 0xDC) && (tile_type <= 0xE7)) {
		return(0x01);
	}
	if ((tile_type >= 0xEC) && (tile_type <= 0xF7)) {
		return(0x01);
	}
	if ((tile_type >= 0xFC) && (tile_type <= 0x0107)) {
		return(0x01);
	}
	if ((tile_type >= 0x010C) && (tile_type <= 0x0117)) {
		return(0x01);
	}
	if ((tile_type >= 0x011E) && (tile_type <= 0x0129)) {
		return(0x01);
	}
	if ((tile_type >= 0x0141) && (tile_type <= 0x0144)) {
		return(0x01);
	}
	if ((tile_type >= 0x01D3) && (tile_type <= 0x01DA)) {
		return(0x01);
	}
	if ((tile_type >= 0x021F) && (tile_type <= 0x0243)) {
		return(0x01);
	}
	if ((tile_type >= 0x06CD) && (tile_type <= 0x06DD)) {
		return(0x01);
	}
	if ((tile_type >= 0x06EB) && (tile_type <= 0x06FE)) {
		return(0x01);
	}
	if ((tile_type >= 0x0709) && (tile_type <= 0x0720)) {
		return(0x01);
	}
	if ((tile_type >= 0x0727) && (tile_type <= 0x073E)) {
		return(0x01);
	}
	if ((tile_type >= 0x0745) && (tile_type <= 0x075C)) {
		return(0x01);
	}
	if ((tile_type >= 0x07BD) && (tile_type <= 0x07D4)) {
		return(0x01);
	}
	if ((tile_type >= 0x0245) && (tile_type <= 0x026D)) {
		return(0x01);
	}
	return(0x00);
}

function int drain_tool_life(obj user, obj tool) {
	if (hasObjVar(tool, "lifeRemaining")) {
		int lifeRemaining = getObjVar(tool, "lifeRemaining");
		if (lifeRemaining > 0x01) {
			setObjVar(tool, "lifeRemaining", (lifeRemaining - 0x01));
		} else {
			string name = getNameByType(getObjType(this));
			systemMessage(user, "You destroyed the " + name + ".");
			return(0x01);
		}
	} else {
		setObjVar(tool, "lifeRemaining", 0x32);
	}
	return(0x00);
}
