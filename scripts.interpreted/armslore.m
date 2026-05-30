inherits sk_table;

trigger message("canUseSkill") {
	return(0x00);
}

trigger callback(0x4D) {
	detachScript(this, "armslore");
	return(0x00);
}

trigger message("useSkill") {
	callback(this, 0x0A, 0x4D);
	targetObj(this, this);
	systemMessage(this, "What item do you wish to get information about?");
	return(0x00);
}

trigger oortargetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	loc user_loc = getLocation(user);
	loc there = getLocation(usedon);
	if (getDistanceInTiles(user_loc, there) > 0x03) {
		systemMessage(user, "You are too far away to tell much about it.");
		return(0x00);
	}
	if (!isFreelyViewable(usedon, user)) {
		systemMessage(user, "You can't see it well enough to tell much about it.");
		return(0x00);
	}
	if (!isWeapon(usedon)) {
		systemMessage(user, "This is neither weapon nor armor.");
		return(0x00);
	}
	if (!skillTest(user, 0x04)) {
		systemMessage(user, "You are not certain...");
		return(0x00);
	}
	int two_handed = 0x00;
	int avg_dmg = getAverageDamage(usedon);
	int armor_class = getCurArmorClass(usedon);
	int slashing = isSlashing(usedon);
	int piercing = isPiercing(usedon);
	int bashing = isBashing(usedon);
	int range = getWeaponRange(usedon);
	int ranged = isRanged(usedon);
	int poison = hasScript(usedon, "poisweap");
	if (getWeaponHandedness(usedon) == 0x04) {
		two_handed = 0x01;
	} else {
		two_handed = 0x00;
	}
	string weapon = getWeaponName(usedon);
	string damage = "";
	string hit_clause = "";
	string range_clause = "";
	string armor_desc = "";
	if (avg_dmg) {
		if (avg_dmg < 0x03) {
			damage = "might scratch your opponent slightly";
		}
		if (avg_dmg > 0x02) {
			damage = "would do minimal damage";
		}
		if (avg_dmg > 0x05) {
			damage = "would do some damage";
		}
		if (avg_dmg > 0x0A) {
			damage = "would probably hurt your opponent a fair amount";
		}
		if (avg_dmg > 0x0F) {
			damage = "would inflict quite a lot of damage and pain";
		}
		if (avg_dmg > 0x14) {
			damage = "would be a superior weapon";
		}
		if (avg_dmg > 0x19) {
			damage = "would be extraordinarily deadly";
		}
		hit_clause = " when you hit someone with it";
		if (piercing) {
			hit_clause = " when you stabbed ";
			if (ranged) {
				hit_clause = " when you shot someone ";
			}
			if (slashing) {
				concat(hit_clause, "or slashed ");
			}
			if (bashing) {
				concat(hit_clause, "or bashed ");
			}
			concat(hit_clause, "with it");
		}
		if (slashing) {
			hit_clause = " when you slashed ";
			if (piercing) {
				concat(hit_clause, "or stabbed ");
			}
			if (bashing) {
				concat(hit_clause, "or bashed ");
			}
			concat(hit_clause, "with it");
		}
		if ((bashing) && (range > 0x02)) {
			hit_clause = "";
		}
		if ((bashing) && (range < 0x03)) {
			hit_clause = " when you bashed ";
			if (slashing) {
				concat(hit_clause, "or slashed ");
			}
			if (piercing) {
				concat(hit_clause, "or stabbed ");
			}
			concat(hit_clause, "with it");
		}
		if ((two_handed == 0x01) && (range < 0x03)) {
			concat(hit_clause, " twohanded");
		}
		range_clause = " at short range";
		if (ranged) {
			range_clause = "";
		}
		if (range == 0x02) {
			range_clause = ", and it has a good reach";
		}
		if ((range > 0x02) && (!ranged)) {
			range_clause = " at long range";
		}
	} else {
		if (armor_class < 0x01) {
			armor_desc = "offers no defense against attackers";
		}
		if (armor_class > 0x00) {
			armor_desc = "provides almost no protection";
		}
		if (armor_class > 0x05) {
			armor_desc = "provides very little protection";
		}
		if (armor_class > 0x0A) {
			armor_desc = "offers some protection against blows";
		}
		if (armor_class > 0x0F) {
			armor_desc = "serves as sturdy protection";
		}
		if (armor_class > 0x14) {
			armor_desc = "is a superior defense against attack";
		}
		if (armor_class > 0x19) {
			armor_desc = "offers excellent protection";
		}
		if (armor_class > 0x1E) {
			armor_desc = "is superbly crafted to provide maximum protection";
		}
	}
	string msg = "This " + weapon + " " + armor_desc + damage + hit_clause + range_clause + ".";
	if ((armor_class == 0x00) && (avg_dmg == 0x00)) {
		msg = "This so-called ";
		concat(msg, weapon);
		concat(msg, " is useless.");
	}
	if (getWeaponMinStr(usedon) > getStrength(user)) {
		concat(msg, " It is too heavy for you, though. ");
	}
	int max_hp = getWeaponMaxHP(usedon);
	int cur_hp = getWeaponCurHP(usedon);
	concat(msg, "  It looks ");
	int condition = 0x0A * cur_hp / max_hp;
	switch(condition) {
	default
	case 0x01
		concat(msg, "like it is about to fall apart.");
		break;
	case 0x02
		concat(msg, "rather flimsy and not at all trustworthy.");
		break;
	case 0x03
		concat(msg, "somewhat badly damaged.");
		break;
	case 0x04
		concat(msg, "rather battered.");
		break;
	case 0x05
		concat(msg, "like it has been well-used.");
		break;
	case 0x06
		concat(msg, "to have suffered some wear and tear.");
		break;
	case 0x07
		concat(msg, "to be in fairly good condition.");
		break;
	case 0x08
		concat(msg, "barely used, with just a few nicks and scratches.");
		break;
	case 0x09
		concat(msg, "almost new.");
		break;
	case 0x0A
		concat(msg, "brand-new.");
		break;
	}
	if (poison) {
		concat(msg, " It appears to have poison smeared on it.");
	}
	systemMessage(user, msg);
	return(0x00);
}
