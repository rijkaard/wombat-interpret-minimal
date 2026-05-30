trigger use {
	int obj_type = getObjType(this);
	loc pos = getLocation(this);
	switch(obj_type) {
	case 0x0C4F
	case 0x0C50
	case 0x0C51
	case 0x0C52
	case 0x0C53
	case 0x0C54
		obj cloth = createNoResObjectAt(0x0DF9, pos);
		transferResources(cloth, this, 0x0A, "cloth");
		deleteObject(this);
		break;
	case 0x0C55
	case 0x0C56
	case 0x0C57
	case 0x0C58
	case 0x0C59
	case 0x0C5A
	case 0x0C5B
		obj flour = createNoResObjectAt(0x1EBD, pos);
		transferResources(flour, this, 0x0A, "flour");
		int new_type = random(0x00, 0x01) + 0x0DAE;
		setType(this, new_type);
		string old_script = obj_type;
		detachscript(this, old_script);
		break;
	case 0x0C61
	case 0x0C62
	case 0x0C63
		new_type = random(0x00, 0x01) + 0x0D39;
		setType(this, new_type);
		string new_script1 = new_type;
		attachscript(this, new_script1);
		string old_script = obj_type;
		detachscript(this, old_script);
		break;
	case 0x0C76
		new_type = random(0x00, 0x01) + 0x0C77;
		setType(this, new_type);
		string new_script2 = new_type;
		attachscript(this, new_script2);
		old_script = obj_type;
		detachscript(this, old_script);
		break;
	case 0x0C6F
		new_type = random(0x00, 0x01) + 0x0C6D;
		setType(this, new_type);
		string new_script = new_type;
		attachscript(this, new_script);
		old_script = obj_type;
		detachscript(this, old_script);
		break;
	case 0x1A99
	case 0x1A9A
	case 0x1A9B
		int flax_type = random(0x00, 0x01) + 0x1A9C;
		obj flax = createNoResObjectAt(flax_type, pos);
		transferResources(flax, this, 0x0A, "flax");
		deleteObject(this);
		break;
	}
	return(0x00);
}
