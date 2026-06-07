inherits sndfx;

trigger washit {
	if (damamt < 0x03) {
		return(0x01);
	}
	obj weapon = getWeapon(attacker);
	if (weapon == NULL()) {
		return(0x01);
	}
	if (isRanged(weapon)) {
		return(0x01);
	}
	int hp = getCurHP(weapon);
	hp = hp - 0x01;
	setCurHP(weapon, hp);
	ebarkTo(attacker, attacker, "*Acid blood scars your weapon!*");
	return(0x01);
}
