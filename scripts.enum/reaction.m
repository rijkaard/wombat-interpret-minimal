inherits spelskil;

trigger objectloaded {
	detachScript(this, "reaction");
	return(0x01);
}

trigger washit {
	if (isValid(attacker)) {
		if (!isGuard(attacker)) {
			loc there = getLocation(attacker);
			loc here = getLocation(this);
			if (getDistanceInTiles(here, there) <= 0x01) {
				int reflect_pct = 0x0A + getSkillLevel(this, SKILL_MAGERY) / 0x04;
				int reflect_dmg = damamt * reflect_pct / 0x64;
				int reduced_dmg = damamt - reflect_dmg;
				doMobAnimation(attacker, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
				sfx(getLocation(attacker), 0x01F1, 0x00);
				if (reflect_dmg > 0x00) {
					doDamage(NULL(), attacker, reflect_dmg);
				}
				intRet(reduced_dmg);
			}
		}
	}
	return(0x00);
}

trigger callback(0x2F) {
	sfx(getLocation(this), 0x5C, 0x00);
	if (hasScript(this, "remreact")) {
		detachScript(this, "remreact");
	}
	if (hasScript(this, "reaction")) {
		detachScript(this, "reaction");
	}
	return(0x00);
}
