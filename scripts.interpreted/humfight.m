function void bark_random(list phrases) {
	string x = phrases[random(0x00, numInList(phrases) - 0x01)];
	bark(this, x);
	return();
}

trigger 0x64 death {
	list death_phrases = "I shall be avenged!", "NOOooo!", "I... I...", "No, I don't want to die...", "Argh! I am slain!", "Must stay... on feet...", "Oooh, that doth hurt...", "Am I dying?";
	if (isShopkeeper(this)) {
		death_phrases = "Whatever shall my family do without me?", "I hope the guards catch thee, scum!", "Ooh... that doth hurt.", "Must I die?", "Curse thee!", "I shall be avenged...", "I shall haunt thee for this deed!", "I spit on thee...";
	}
	bark_random(death_phrases);
	return(0x01);
}

trigger 0x64 killedtarget {
	list phrases = "Ha! I knew that I could do it!", "Thou shouldst not have messed with me!", "Die, pathetic fool!", "Thou deservest to die!", "There, that taketh care of thee.", "So perish those who challenge me!", "Thou shouldst not have fought me.", "May thy soul rest in peace.", "May thy shade wander the wilderness forever!", "Have done with thee!";
	bark_random(phrases);
	return(0x01);
}

trigger 0x64 washit {
	list phrases;
	if (damamt < 0x01) {
		phrases = "Ha! Thou art inept!", "Thou didst miss, fool!", "Thy aim is bad...", "Surely thou canst do better than that blow!", "Thou dost hit only air!", "Thou art no match for me!";
		bark_random(phrases);
		return(0x01);
	}
	if (damamt < 0x05) {
		phrases = "Ouch! Thou didst scratch me!", "Barely a flesh wound. Canst thou not do better?", "Pfft, thou fightest badly.", "Surely thou canst hit harder than that!", "A bare touch... Thou dost not wield thy weapon well!";
	} else {
		phrases = "Ouch! A touch indeed!", "'Twill take more than that to kill me!", "Ow, thou didst get past my defenses!", "Away with thee, scum!", "Oof! That didst hurt!", "Aaah! I do bleed badly...", "A good blow on thy part... but not enough!";
	}
	bark_random(phrases);
	return(0x01);
}
