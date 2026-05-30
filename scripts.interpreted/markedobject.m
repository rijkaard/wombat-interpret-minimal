inherits globals;

forward int get_city_index(string );

forward loc get_city_loc(int );

forward string get_city_name(int );

trigger creation {
	string desc;
	string city_name;
	loc this_loc = getLocation(this);
	loc coord;
	loc city_loc;
	int city_id;
	int has_loc_desc;
	has_loc_desc = getLocalizedDesc(desc, coord, this_loc, this_loc);
	string desc_str = has_loc_desc;
	city_id = get_city_index(desc);
	if (city_id == 0x029A) {
		return(0x00);
	}
	city_loc = get_city_loc(city_id);
	city_name = get_city_name(city_id);
	setObjVar(this, "markLoc", city_loc);
	setObjVar(this, "lookAtText", "Marked item for " + city_name);
	return(0x00);
}

function int get_city_index(string area_name) {
	list cities = "city_britain", "city_bucden", "city_jhelom", "city_magincia", "city_minoc", "city_moonglow", "city_ocllo", "city_serphold", "city_skara", "city_trinsic", "city_vesper", "city_yew";
	string name;
	int count = numInList(cities);
	for (int i = 0x00; i < count; i++) {
		name = cities[i];
		if (area_name == name) {
			string index_str = i;
			return(i);
		}
	}
	return(0x029A);
}

function loc get_city_loc(int city_index) {
	loc result_loc = 0x0615, 0x0652, 0x0A;
	switch(city_index) {
	case 0x00
		result_loc = 0x0615, 0x0652, 0x0A;
		break;
	case 0x01
		result_loc = 0x0A9A, 0x0875, 0x00;
		break;
	case 0x02
		result_loc = 0x0586, 0x0EF7, 0x00;
		break;
	case 0x03
		result_loc = 0x0E9C, 0x08BB, 0x14;
		break;
	case 0x04
		result_loc = 0x099D, 0x01B9, 0x0F;
		break;
	case 0x05
		result_loc = 0x116B, 0x0478, 0x00;
		break;
	case 0x06
		result_loc = 0x0E44, 0x09EE, 0x00;
		break;
	case 0x07
		result_loc = 0x0BA4, 0x0D71, 0x0F;
		break;
	case 0x08
		result_loc = 0x027B, 0x085E, 0x00;
		break;
	case 0x09
		result_loc = 0x0764, 0x0B21, 0x14;
		break;
	case 0x0A
		result_loc = 0x0B27, 0x037C, 0x00;
		break;
	case 0x0B
		result_loc = 0x0232, 0x03DC, 0x00;
		break;
	}
	return(result_loc);
}

function string get_city_name(int city_index) {
	string name = "Britain";
	switch(city_index) {
	case 0x00
		name = "Britain";
		break;
	case 0x01
		name = "Buccaneer's Den";
		break;
	case 0x02
		name = "Jhelom";
		break;
	case 0x03
		name = "Magincia";
		break;
	case 0x04
		name = "Minoc";
		break;
	case 0x05
		name = "Moonglow";
		break;
	case 0x06
		name = "Ocllo";
		break;
	case 0x07
		name = "Serpent's Hold";
		break;
	case 0x08
		name = "Skara Brae";
		break;
	case 0x09
		name = "Trinsic";
		break;
	case 0x0A
		name = "Vesper";
		break;
	case 0x0B
		name = "Yew";
		break;
	}
	return(name);
}
