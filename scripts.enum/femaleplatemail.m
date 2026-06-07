inherits platemail;

trigger equip {
	shortcallback(this, 0x01, 0x88);
	return(0x01);
}

trigger objectloaded {
	shortcallback(this, 0x01, 0x88);
	return(0x01);
}

trigger callback(0x88) {
	obj wearer = containedBy(this);
	int ok;
	if (wearer != NULL()) {
		if (isMobile(wearer)) {
			int slot = getEquipSlot(this);
			if (this == getItemAtSlot(wearer, slot)) {
				if (getObjType(wearer) == 0x0190) {
					barkTo(wearer, wearer, "Only females can wear this.");
					if (canHold(wearer, this)) {
						ok = toMobile(this, wearer);
					} else {
						ok = teleport(this, getLocation(wearer));
					}
				}
			}
		}
	}
	return(0x01);
}
