inherits sk_table;

trigger creation {
	list equipped;
	int ret;
	getEquipment(equipped, this);
	int equip_count = numInList(equipped);
	obj backpack = getBackpack(this);
	for (int j = 0x00; j < equip_count; j++) {
		obj it = equipped[j];
		if (it != backpack) {
			ret = toMobile(it, this);
		}
	}
	list f_args;
	message(this, "cancelmagic", f_args);
	for (int stat = 0x00; stat < 0x03; stat++) {
		ret = setStatMod(this, stat, 0x00);
	}
	int i;
	for (i = 0x00; i < 0x2E; i++) {
		ret = setSkillMod(this, i, 0x00);
	}
	int total = 0x00;
	int pct;
	int neg_skill = 0x00;
	int cur;
	for (i = 0x00; i < 0x2E; i++) {
		cur = getSkillLevelNoStat(this, i);
		if (cur < 0x00) {
			neg_skill = 0x01;
		} else {
			total = total + abs(cur);
		}
	}
	if ((neg_skill) || (total > 0x03E8)) {
		pct = 0x03E8 * 0x64 / total;
		bark(this, "Skill total was:" + total + ", keeping " + pct + "");
		for (i = 0x00; i < 0x2E; i++) {
			int val = getSkillLevelNoStat(this, i);
			int scaled = 0x00;
			if (val >= 0x00) {
				scaled = val * pct / 0x64;
			}
			setSkillLevel(this, i, scaled);
		}
	}
	total = 0x00;
	int neg_stat = 0x00;
	for (i = 0x00; i < 0x03; i++) {
		cur = getRealStat(this, i);
		if (cur < 0x00) {
			neg_stat = 0x01;
		} else {
			total = total + abs(getRealStat(this, i));
		}
	}
	if ((neg_stat) || (total > 0x41)) {
		pct = 0x41 * 0x64 / total;
		bark(this, "Stat total was:" + total + ", keeping " + pct + "");
		int carry = 0x00;
		for (i = 0x00; i < 0x2E; i++) {
			cur = getRealStat(this, i);
			int scaled2 = 0x00;
			if (cur > 0x00) {
				scaled2 = cur * pct / 0x64;
			}
			int actual = setRealStat(this, i, scaled2 + carry);
			carry = scaled2 - actual;
		}
	}
	detachScript(this, "newbieme");
	return(0x00);
}
