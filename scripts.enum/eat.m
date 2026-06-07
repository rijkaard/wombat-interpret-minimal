inherits itemmanip;

function void eat_food(obj user, int result_type) {
	if (isAtHome(this)) {
		systemMessage(user, "You can't eat that, it belongs to someone else.");
		return();
	}
	loc location = getLocation(this);
	int satiety_gain = getObjVar(this, "satiety");
	int satiety = getSatiety(user);
	if (satiety > 0x18) {
		systemMessage(user, "You are simply too full to eat any more!");
		return();
	}
	addSatiety(user, satiety_gain);
	addFatigue(user, satiety_gain);
	if (satiety < 0x05) {
		systemMessage(user, "You eat the food, but are still extremely hungry.");
	}
	if ((satiety >= 0x05) && (satiety < 0x0A)) {
		systemMessage(user, "You eat the food, and begin to feel more satiated.");
	}
	if ((satiety >= 0x0A) && (satiety < 0x14)) {
		systemMessage(user, "After eating the food, you feel much less hungry.");
	}
	if ((satiety >= 0x14) && (satiety < 0x18)) {
		systemMessage(user, "You feel quite full after consuming the food.");
	}
	if (satiety >= 0x18) {
		systemMessage(user, "You manage to eat the food, but you are stuffed!");
	}
	int sound = random(0x01, 0x03);
	if (sound == 0x01) {
		sfx(location, 0x3A, 0x00);
	}
	if (sound == 0x02) {
		sfx(location, 0x3B, 0x00);
	}
	if (sound == 0x03) {
		sfx(location, 0x3C, 0x00);
	}
	if (result_type != 0x00) {
		obj result = createGlobalObjectOn(this, result_type);
		destroyOne(this);
	} else {
		destroyOne(this);
	}
	return();
}
