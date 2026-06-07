inherits sndfx;

trigger enterrange(0x03) {
	if (!canSeeObj(this, target)) {
		return(0x01);
	}
	if (isDead(target)) {
		loc target_loc = getLocation(target);
		loc self_loc = getLocation(this);
		int z_diff = getZ(target_loc) - getZ(self_loc);
		if (z_diff < 0x00) {
			z_diff = z_diff * (0x00 - 0x01);
		}
		if (z_diff > 0x04) {
			return(0x01);
		}
		if (isOnAnyMulti(target)) {
			return(0x01);
		}
		if (!isFacingPerson(this, target)) {
			int dir = getDirection(self_loc, target_loc);
			faceHere(this, dir);
		}
		if (!getCompileFlag(0x01)) {
			if (getNotorietyLevel(this) > (0x00 - 0x01)) {
				if (getNotorietyLevel(target) < (0x00 - 0x02)) {
					bark(this, "Thou'rt not a decent and good person. I shall not resurrect thee.");
					return(0x01);
				}
				if (getNotorietyLevel(target) < 0x00) {
					bark(this, "Thou hast strayed from the path of virtue, but thou still deservest a second chance.");
				}
			}
		} else {
			if (getKarmaLevel(this) > (0x00 - 0x01)) {
				if (isMurderer(target)) {
					bark(this, "Thou'rt not a decent and good person. I shall not resurrect thee.");
					return(0x01);
				}
				if (getKarmaLevel(target) < 0x00) {
					bark(this, "Thou hast strayed from the path of virtue, but thou still deservest a second chance.");
				}
			}
		}
		animateMobile(this, 0x10, 0x07, 0x01, 0x00, 0x00);
		doMobAnimation(this, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(getLocation(this), 0x01F2, 0x00);
		offer_resurrect(this, target, 0x01, "It is possible for you to be resurrected here by this healer. Do you wish to try?");
		return(0x00);
	}
	return(0x01);
}
