inherits acidblood;

function void split_slime(obj attacker) {
	obj n = createGlobalNPCAtSpecificLoc(0x0232, getLocation(this));
	setHue(n, getHue(this));
	int half_hp = getCurHP(this);
	half_hp = half_hp / 0x02;
	setCurHP(n, half_hp);
	setCurHP(this, half_hp);
	attack(n, attacker);
	sfx(getLocation(this), random(0x01C8, 0x01CC), 0x00);
	bark(n, "*The slime splits when struck!*");
	return();
}

trigger 0x012C washit {
	if ((damamt > (getCurHP(this) / 0x04)) && (getCurHP(this) > 0x05)) {
		split_slime(attacker);
	}
	return(0x01);
}
