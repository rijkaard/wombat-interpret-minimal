inherits sndfx;

trigger creation {
	if (!hasObjVar(this, "nonHuman")) {
		return(0x00);
	}
	int nonhuman_type = getObjVar(this, "nonHuman");

member int sfx_id;
	switch(nonhuman_type) {
	case 0x00
		setDefaultTextHue(this, 0x22);
		sfx_id = 0x01B0;
		break;
	case 0x01
		setDefaultTextHue(this, 0x59);
		sfx_id = 0x01D2;
		break;
	case 0x02
		setDefaultTextHue(this, 0x3A);
		sfx_id = 0x01A2;
		break;
	case 0x03
		setDefaultTextHue(this, 0x95);
		sfx_id = 0x01B6;
		break;
	default
	}
	return(0x01);
}

function void bark_random_speech(obj this, int max_words) {
	string speech;
	int num_phrases = random(0x02, max_words);
	int syllable_count;
	string syllable;
	string word;
	int punct_roll;
	int capitalize;
	for (int i = 0x00; i < num_phrases; i++) {
		word = " ";
		capitalize = 0x00;
		if (i != 0x00) {
			punct_roll = random(0x01, 0x0F);
			if (punct_roll < 0x0B) {
				word = " ";
			} else {
				capitalize = 0x01;
				if (punct_roll > 0x0D) {
					word = "! ";
				} else {
					word = ". ";
				}
			}
		}
		if (random(0x00, 0x0A) < 0x03) {
			syllable_count = random(0x01, 0x05);
		} else {
			syllable_count = random(0x01, 0x03);
		}
		int speech_type = 0x00;
		if (hasObjVar(this, "nonHuman")) {
			speech_type = getObjVar(this, "nonHuman");
		}
		for (int si = 0x00; si < syllable_count; si++) {
			if (speech_type == 0x00) {
				syllable = getOrcishSyllable(random(0x00, 0x7FFF));
			} else {
				if (speech_type == 0x01) {
					syllable = getWispishSyllable(random(0x00, 0x7FFF));
				} else {
					if (speech_type == 0x02) {
						syllable = getLizardishSyllable(random(0x00, 0x7FFF));
					} else {
						syllable = getRattishSyllable(random(0x00, 0x7FFF));
					}
				}
			}
			if ((si == 0x00) && (capitalize == 0x01)) {
				toUpper(syllable, 0x00, 0x01);
			}
			concat(word, syllable);
		}
		concat(speech, word);
	}
	if (random(0x01, 0x05) == 0x01) {
		concat(speech, "!");
	} else {
		concat(speech, ".");
	}
	toUpper(speech, 0x00, 0x02);
	bark(this, speech);
	sfx(getLocation(this), sfx_id, 0x00);
	return();
}

trigger speech("*") {
	if (!isPlayer(speaker)) {
		return(0x01);
	}
	if (isDead(speaker)) {
		return(0x01);
	}
	if (!canSeeObj(this, speaker)) {
		return(0x01);
	}
	list targets;
	getTargets(targets, this);
	if (numInList(targets) > 0x00) {
		return(0x01);
	}
	if (!isFacingPerson(this, speaker)) {
		return(0x01);
	}
	list args;
	string word;
	list response_words;
	split(args, arg);
	int max_words = numInList(args) + 0x03;
	list trigger_words = "meat", "gold", "kill", "killing", "slay", "sword", "axe", "spell", "magic", "spells", "swords", "axes", "mace", "maces", "monster", "monsters", "food", "run", "escape", "away", "help", "dead", "die", "dying", "lose", "losing", "life", "lives", "death", "ghost", "ghosts", "british", "blackthorn", "guild", "guilds", "dragon", "dragons", "game", "games", "ultima", "silly", "stupid", "dumb", "idiot", "idiots", "cheesy", "cheezy", "crazy", "dork", "jerk", "fool", "foolish", "ugly", "insult", "scum";
	response_words = "meat", "kill", "pound", "crush", "yum yum", "crunch", "destroy", "murder", "eat", "munch", "massacre", "food", "monster", "evil", "run", "die", "lose", "dumb", "idiot", "fool", "crazy", "jabber incomprehensibly", "dinner", "lunch", "breakfast", "fight", "battle", "doomed", "rip apart", "tear apart", "smash", "edible?", "shred", "disembowel", "ugly", "smelly", "stupid", "hideous", "smell", "tasty", "invader", "attack", "raid", "plunder", "pillage", "treasure", "loser", "lose", "scum";
	list matched_words;
	int found = 0x00;
	for (int i = 0x00; i < numInList(trigger_words); i++) {
		word = trigger_words[i];
		if (isInList(args, word)) {
			found = 0x01;
			appendToList(response_words, word);
			appendToList(matched_words, word);
		}
	}
	if (found) {
		bark_random_speech(this, ((max_words / 0x02) + 0x01));
		string phrase;
		if (random(0x00, 0x01) == 0x01) {
			word = response_words[random(0x00, (numInList(response_words) - 0x01))];
		} else {
			word = matched_words[random(0x00, (numInList(matched_words) - 0x01))];
		}
		string word2 = response_words[random(0x00, (numInList(response_words) - 0x01))];
		int bark_fmt = random(0x00, 0x05);
		switch(bark_fmt) {
		case 0x00
			phrase = " Me " + word + "? ";
			break;
		case 0x01
			toUpper(word, 0x00, 0x01);
			phrase = word + " thee! ";
			break;
		case 0x02
			toUpper(word, 0x00, 0x01);
			phrase = word + "?";
			break;
		case 0x03
			toUpper(word, 0x00, 0x01);
			toUpper(word2, 0x00, 0x01);
			phrase = word + "! " + word2 + ". ";
			break;
		case 0x04
			toUpper(word, 0x00, 0x01);
			phrase = word + ". ";
			break;
		case 0x05
			toUpper(word, 0x00, 0x01);
			toUpper(word2, 0x00, 0x01);
			phrase = word + "? " + word2 + ". ";
			break;
		default
			phrase = "";
			break;
		}
		bark(this, phrase);
		bark_random_speech(this, ((max_words / 0x02) + 0x01));
		return(0x00);
	}
	bark_random_speech(this, max_words);
	return(0x00);
}

trigger 0x64 enterrange(0x05) {
	if (!isPlayer(target)) {
		return(0x01);
	}
	bark_random_speech(this, 0x07);
	return(0x01);
}

function void bark_nonhuman_speech(list phrases) {
	string x = phrases[random(0x00, numInList(phrases) - 0x01)];
	bark_random_speech(this, 0x03);
	bark(this, x);
	return();
}

trigger 0x64 death {
	list death_phrases = "Revenge!", "NOOooo!", "I... I...", "Me no die!", "Me die!", "Must... not die...", "Oooh, me hurt...", "Me dying?";
	bark_nonhuman_speech(death_phrases);
	return(0x01);
}

trigger 0x64 killedtarget {
	list phrases = "Ha! Thou dead!", "Thou not attack me! ", "Die!", "Die! Die!", "There!", "Thou, die!", "Fight me not!", "Ha! Be ghost now!";
	bark_nonhuman_speech(phrases);
	return(0x01);
}

trigger 0x64 washit {
	list phrases;
	if (damamt < 0x01) {
		phrases = "Ha! Bad fighter!", "You miss!", "Bad aim!", "Enemy fight bad!", "Me fight better!", "Thou art doomed...";
		bark_nonhuman_speech(phrases);
		return(0x01);
	}
	if (damamt < 0x05) {
		phrases = "Ouch!", "Me not hurt bad!", "Thou fight bad.", "Thy blows soft!", "You bad with weapon!";
	} else {
		phrases = "Ouch! Me hurt!", "No, kill me not!", "Me hurt!", "Away with thee!", "Oof! That hurt!", "Aaah! That hurt...", "Good blow!";
	}
	bark_nonhuman_speech(phrases);
	return(0x01);
}
