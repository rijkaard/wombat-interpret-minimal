inherits sk_table;

function obj get_or_create_backpack(obj animal) {
	obj pack = getBackpack(animal);
	if (pack == NULL()) {
		pack = createGlobalObjectIn(0x0E75, animal);
		if (!isValid(pack)) {
			return(NULL());
		}
		if (!equipObj(pack, animal, 0x15)) {
			deleteObject(pack);
			return(NULL());
		}
	}
	return(pack);
}

function int is_authorized_owner(obj mobile, obj pet) {
	list boss_list;
	if (!hasObjListVar(pet, "myBoss")) {
		return(0x00);
	}
	getObjListVar(boss_list, pet, "myBoss");
	if (!isInList(boss_list, mobile)) {
		return(0x00);
	}
	if (!hasObjVar(pet, "myLoyalty")) {
		return(0x00);
	}
	int myLoyalty = getObjVar(pet, "myLoyalty");
	if (myLoyalty < 0x01) {
		return(0x00);
	}
	return(0x01);
}

trigger use {
	int result;
	obj pack = get_or_create_backpack(this);
	if (pack == NULL()) {
		return(0x00);
	}
	if (isDead(user)) {
		return(0x00);
	}
	if (isEditing(user) || is_authorized_owner(user, this)) {
		result = openContainer(user, pack);
	} else {
		if (testSkill(user, 0x1C)) {
			result = openContainer(user, pack);
		} else {
			ebarkTo(user, user, "You fail to peek into the animal's pack.");
		}
	}
	return(0x00);
}

function int can_access_pack(obj user_obj) {
	if (isDead(user_obj)) {
		return(0x00);
	}
	if (isEditing(user_obj) || is_authorized_owner(user_obj, this)) {
		return(0x01);
	}
	return(0x00);
}

trigger objaccess(0x05) {
	return(!can_access_pack(user))}

trigger objaccess(0x07) {
	return(!can_access_pack(user))}

trigger objaccess(0x08) {
	if (usedon == this) {
		return(0x01);
	}
	if (isContainer(usedon) && can_access_pack(user)) {
		int result = openContainer(user, usedon);
	}
	return(0x00);
}

trigger give {
	obj backpack = get_or_create_backpack(this);
	if (backpack == NULL()) {
		return(0x00);
	}
	if (!canHold(backpack, givenobj)) {
		if (!isEditing(giver)) {
			return(0x00);
		}
	}
	if (isEditing(giver) || is_authorized_owner(giver, this)) {
		int result = putObjContainer(givenobj, backpack);
		return(0x01);
	}
	return(0x00);
}
