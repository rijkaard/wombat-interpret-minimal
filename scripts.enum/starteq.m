trigger creation {
	overloadWeight(this, 0x02);
	if (isWeapon(this)) {
		int weapon_type = 0x00;
		if (isSlashing(this)) {
			weapon_type = 0x01;
		}
		if (isBashing(this)) {
			weapon_type = 0x02;
		}
		if (isPiercing(this)) {
			weapon_type = 0x03;
		}
		if (isRanged(this)) {
			weapon_type = 0x04;
		}
		if (weapon_type > 0x00) {
			int template_id = 0x3C + weapon_type;
			int result = applyWeaponTemplate(this, template_id);
		}
		string look_text;
		look_text = getWeaponName(this) + " (practice weapon)";
		setObjVar(this, "lookAtText", look_text);
	}
	return(0x01);
}
