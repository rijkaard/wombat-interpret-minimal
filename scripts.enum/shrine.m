inherits spelskil;

member int is_chaos_shrine;

function int try_resurrect_target(obj target, int is_chaos) {
	loc shrine_loc = getLocation(this);
	int shrine_z = getZ(shrine_loc);
	loc target_loc = getLocation(target);
	int target_z = getZ(target_loc);
	int z_diff = shrine_z - target_z;
	string z_diff_str = z_diff;
	if ((z_diff > 0x0A) || (z_diff < (0x00 - 0x0A))) {
		return(0x00);
	}
	if (isDead(target)) {
		if (findGoodZ(target_loc, getZ(target_loc), getZ(target_loc), getHeight(target), 0x01) == (0x00 - 0x80)) {
			return(0x00);
		}
		if (!is_chaos) {
			if (!getCompileFlag(0x01)) {
				if (getNotorietyLevel(target) < (0x00 - 0x02)) {
					bark(this, "Thy deeds are those of a scoundrel; thou shalt not be resurrected here.");
					return(0x00);
				}
			} else {
				if (isMurderer(target)) {
					bark(this, "Thy deeds are those of a scoundrel; thou shalt not be resurrected here.");
					return(0x00);
				}
			}
		}
		string prompt;
		if (is_chaos) {
			prompt = "It is possible for you to be resurrected here at the Chaos Shrine. Do you wish to try?";
		} else {
			prompt = "It is possible for you to be resurrected at this Shrine to the Virtues. Do you wish to try?";
		}
		offer_resurrect(this, target, 0x01, prompt)return(0x01);
	}
	return(0x00);
}

trigger enterrange(0x01) {
	int resurrected = try_resurrect_target(target, is_chaos_shrine);
	return(!resurrected);
}

trigger use {
	if (hasScript(user, "poisoned")) {
		cure_poison(user);
		barkTo(this, user, "Thy poison has been cured.");
	}
	return(0x00);
	if (isDead(user)) {
		int resurrected = try_resurrect_target(user, is_chaos_shrine);
		return(0x00);
	}
	int worthy;
	if (!getCompileFlag(0x01)) {
		if (is_chaos_shrine) {
			if (getNotoriety(user) < 0x00) {
				worthy = 0x01;
				barkTo(this, user, "Thy efforts for the resistance are rewarded.");
			}
		} else {
			if (getNotoriety(user) >= 0x00) {
				worthy = 0x01;
				barkTo(this, user, "Strive to continue on the path of benevolence.");
			}
		}
	} else {
		if (is_chaos_shrine) {
			if (getKarmaLevel(user) < 0x00) {
				worthy = 0x01;
				barkTo(this, user, "Thy efforts for the resistance are rewarded.");
			}
		} else {
			if (getKarmaLevel(user) >= 0x00) {
				worthy = 0x01;
				barkTo(this, user, "Strive to continue on the path of benevolence.");
			}
		}
	}
	if (worthy) {
		doMobAnimation(user, 0x376A, 0x0A, 0x0F, 0x00, 0x00);
		restoreHP(user);
	} else {
		if (is_chaos_shrine) {
			int cur_hp = getCurHP(user);
			barkTo(this, user, "The weak deserve their fate.");
			doMobAnimation(user, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
			setCurHP(user, cur_hp / 0x02 + 0x01);
		} else {
			int max_hp = getMaxHP(user);
			int hp_level = getHPLevel(user);
			if (hp_level < 0x32) {
				setCurHP(user, max_hp / 0x02);
				doMobAnimation(user, 0x376A, 0x0A, 0x0F, 0x00, 0x00);
				barkTo(this, user, "Do more to help others.");
			} else {
				barkTo(this, user, "I can not help thee.");
			}
		}
	}
	return(0x01);
}
