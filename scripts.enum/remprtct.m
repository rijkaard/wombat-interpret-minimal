inherits spelskil;

trigger callback(0x13) {
	if (hasObjVar(this, "defenseBonus")) {
		int defense_bonus = getObjVar(this, "defenseBonus");
		int new_ac = getNaturalAC(this) - defense_bonus;
		setNaturalAC(this, new_ac);
		removeObjVar(this, "defenseBonus");
	}
	detachScript(this, "remprtct");
	return(0x00);
}
