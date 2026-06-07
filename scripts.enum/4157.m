inherits cook;

trigger use {
	systemMessage(user, "What should I use this on?");
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int used_on_type = getObjType(usedon);
	obj new_obj;
	if (hasObjVar(this, "lookAtText")) {
		string name;
		name = getObjVar(this, "lookAtText");
		if (name == "sweet dough") {
			switch(used_on_type) {
			case 0x09EC
				new_obj = createGlobalObjectOn(this, 0x103F);
				destroyOne(this);
				return(0x00);
				break;
			case 0x103A
			case 0x0A1E
				new_obj = createGlobalObjectOn(this, 0x103F);
				setObjVar(new_obj, "lookAtText", "cake mix");
				destroyOne(this);
				return(0x00);
				break;
			default
				if (is_cooking_surface(used_on_type)) {
					removeObjVar(this, "lookAtText");
					cook_item_default(user, usedon, 0x09EB);
					return(0x00);
				}
				break;
			}
		}
	}
	string look_at_text;
	switch(used_on_type) {
	case 0x0994
	case 0x172D
		look_at_text = "unbaked fruit pie";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09D2
	case 0x172C
		look_at_text = "unbaked peach cobbler";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09D0
		look_at_text = "unbaked apple pie";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09C0
	case 0x09C1
		new_obj = createGlobalObjectOn(this, 0x1083);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09C9
	case 0x09D3
	case 0x09B7
	case 0x09B8
	case 0x1044
	case 0x097B
		look_at_text = "unbaked meat pie";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09B5
		look_at_text = "unbaked quiche";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	case 0x09EC
		removeObjVar(this, "lookAtText");
		setObjVar(this, "lookAtText", "sweet dough");
		destroyOne(usedon);
		break;
	case 0x0C6B
	case 0x0C6C
		look_at_text = "unbaked pumpkin pie";
		new_obj = createGlobalObjectOn(this, 0x1042);
		setObjVar(new_obj, "lookAtText", look_at_text);
		destroyOne(usedon);
		destroyOne(this);
		break;
	default
		break;
	}
	int result_type = 0x103A + random(0x01, 0x02);
	cook_item_default(user, usedon, result_type);
	return(0x00);
}
