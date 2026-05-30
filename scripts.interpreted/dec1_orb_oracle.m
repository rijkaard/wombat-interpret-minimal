inherits globals;

trigger use {
	list tmp;
	int hour = getHour();
	if (hour >= 0x14) {
		int strength = getStrength(user);
		int intel = getIntelligence(user);
		int dex = getDexterity(user);
		int notoriety;
		if (!getCompileFlag(0x01)) {
			notoriety = getNotoriety(user);
		} else {
			notoriety = getKarmaLevel(user);
		}
		string name = getName(user);
		int sex = getSex(user);
		int roll = random(0x00, 0x04);
		switch(roll) {
		case 0x00
			if (strength >= 0x32 && (intel >= 0x32) && (dex >= 0x32)) {
				bark(this, "Thou shant not fear, the dangers near, sword, mind and nimble feet shall clear.");
				return(0x00);
			}
			if (strength >= 0x32 && !(intel >= 0x32) && !(dex >= 0x32)) {
				bark(this, "A warrior in thee, I see, for the depths of this place should challenge thee.");
				return(0x00);
			}
			if (intel >= 0x32 && !(strength >= 0x32) && !(dex >= 0x32)) {
				bark(this, "Strong of mind, must bind, the tricks of the depths that ye shall find.");
				return(0x00);
			}
			if (dex >= 0x32 && !(strength >= 0x32) && !(intel >= 0x32)) {
				bark(this, "Nimble of feet, thou shall defeat, what traps of the depths ye mayhaps meet.");
				return(0x00);
			}
			bark(this, "The dangers one must decide, they do reside, and fear might be thy only guide.");
			return(0x00);
		case 0x01
			if (intel >= 0x50) {
				bark(this, "Crying shame, 'twas but a game, only thee might uncover the philosopher's name.");
			} else {
				bark(this, "'Tis but a shame, the secret remains, in the depths of this deep and dark domain.");
			}
			return(0x00);
		case 0x02
			if (strength < 0x32 && (intel < 0x32) && (dex < 0x32)) {
				bark(this, "Fear thee well,");
				bark(this, "Thou canst not tell,");
				bark(this, "What beast shall feast,");
				bark(this, "Once thou hast fell.");
				return(0x00);
			}
			list msg_parts;
			if (strength >= 0x32) {
				bark(this, "Strength in thy arm,");
				appendToList(msg_parts, "Thy foes ye meet, no doubt ye should harm.");
			}
			if (dex >= 0x32) {
				bark(this, "Swift in thy feet,");
				appendToList(msg_parts, "Thy traps ye find, ye shall defeat.");
			}
			if (intel >= 0x32) {
				bark(this, "Thy mind shant not flee,");
				appendToList(msg_parts, "The treasures within, should become part of thee.");
			}
			bark(this, msg_parts[random(0x00, numInList(msg_parts) - 0x01)]);
			return(0x00);
		case 0x03
			string moral_desc;
			string title;
			if (!getCompileFlag(0x01)) {
				if (notoriety < (0x00 - 0x015E)) {
					moral_desc = "foul";
				}
				if (notoriety > 0x015E) {
					moral_desc = "most honorable";
				}
				if (notoriety >= (0x00 - 0x015E) && (notoriety <= 0x015E)) {
					moral_desc = "good";
				}
			} else {
				if (notoriety < (0x00 - 0x02)) {
					moral_desc = "foul";
				}
				if (notoriety > 0x02) {
					moral_desc = "most honorable";
				}
				if (notoriety >= (0x00 - 0x01) && (notoriety <= 0x03)) {
					moral_desc = "good";
				}
			}
			if (sex == 0x00 || (sex == 0x02)) {
				title = "sir";
			} else {
				title = "lady";
			}
			string reply_text;
			reply_text = name + ", " + moral_desc + " " + title + ", thou hast thy bravery at least.";
			bark(this, reply_text);
			return(0x00);
		case 0x04
			string speech;
			if (!getCompileFlag(0x01)) {
				if (notoriety > 0x015E) {
					speech = "Your reputation, " + name + ", it doth preceed thee,";
					bark(this, speech);
					bark(this, "Your fate doth swirl, I canst not see.");
				}
				if (notoriety >= (0x00 - 0x015E) && (notoriety <= 0x015E)) {
					speech = "I know not of you, " + name + ", your fate is shrouded in mystery.";
					bark(this, speech);
				}
				if (notoriety < (0x00 - 0x015E)) {
					speech = "Foul beasts within, whom ye may find good company, most wicked " + name + ".";
					bark(this, speech);
				}
			} else {
				if (getFameLevel(user) > 0x02) {
					speech = "Your reputation, " + name + ", it doth precede thee,";
					bark(this, speech);
					bark(this, "Your fate doth swirl, I canst not see.");
				}
				if (getFameLevel(user) < 0x03) {
					speech = "I know not of you, " + name + ", your fate is shrouded in mystery.";
					bark(this, speech);
				}
				if (notoriety < 0x00) {
					speech = "Foul beasts within, whom ye may find good company, most wicked " + name + ".";
					bark(this, speech);
				}
			}
			return(0x00);
		}
	} else {
		list prophecies = "The shimmering clouds have revealed a dark destiny, one wrought with peril.", "The cloudy mist of the all-seeing eye have revealed a path filled with still waters.", "The clouds of time reveal the ghosts of the past, still priesting over their congregation.", "Ye shant not fail, have you the eye of an eagle, the strength of an ox and the nibleness of a wolverine.", "The clouds reveal a philosopher, a priest and three thousand leagues of skeletons marching row by row.", "The halls of fate, the halls of doom, in wells of thought, one might find room.", "Ghastly shadows on forlorn walls, echo the death of foes and falls.", "Beware ye who pass this way, for darkness works in mysterious ways.", "On bended knee they came and slew, ten thousand souls for the freedom of Yew.", "Brave hearts dive in and yet not return, their fates swallowed by the fires that burn.", "Once a treasure was laid at the bottom of the tomb, in darkness and light, its wealth did bloom.", "Cast not one eye to the flames' disguise, for marching in order are invisible eyes.";
		bark(this, prophecies[random(0x00, numInList(prophecies) - 0x01)]);
	}
	return(0x00);
}
