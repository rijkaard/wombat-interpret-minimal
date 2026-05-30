inherits sndfx;

function void do_attack_anim(obj cow) {
	sfx(getLocation(this), 0x79, 0x00);
	animateMobile(this, 0x08, 0x00, 0x03, 0x00, 0x00);
	return();
}

trigger use {
	int roll = random(0x00, 0x63);
	if (roll < 0x05) {
		do_attack_anim(this);
	} else {
		if (roll < 0x14) {
			sfx(getLocation(this), 0x78, 0x00);
		} else {
			if (roll < 0x28) {
				sfx(getLocation(this), 0x79, 0x00);
			}
		}
	}
	return(0x01);
}
