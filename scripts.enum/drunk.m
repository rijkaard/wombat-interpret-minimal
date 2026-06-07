inherits globals;

trigger time("min:**") {
	if (hasObjVar(this, "drunk")) {
		int drunk_level = getObjVar(this, "drunk");
		if (drunk_level > 0x00) {
			drunk_level = drunk_level - 0x01;
			if (random(0x01, 0x0A) == 0x01) {
				setObjVar(this, "drunk", drunk_level);
			}
			loseFatigue(this, 0x01);
			loseMana(this, 0x01);
			if (random(0x01, 0x04) == 0x01) {
				if (getItemAtSlot(this, EQUIP_MOUNT) == NULL()) {
					int dir = random(0x01, 0x08);
					faceHere(this, dir);
					if (!isDead(this)) {
						animateMobile(this, 0x20, 0x05, 0x01, 0x00, 0x01);
					}
				}
				list players;
				getPlayersInRange(players, getLocation(this), 0x0A);
				for (int i = 0x00; i < numInList(players); i++) {
					obj player = players[i];
					barkTo(this, player, "*hic*");
				}
			}
			return(0x00);
		} else {
			barkTo(this, this, "You feel sober.");
			removeObjVar(this, "drunk");
		}
	}
	detachScript(this, "drunk");
	return(0x00);
}
