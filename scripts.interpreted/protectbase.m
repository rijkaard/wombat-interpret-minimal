inherits spelskil;

function int apply_protection_effect(obj user, obj usedon) {
	int success = 0x00;
	if (is_targetable_mobile(usedon)) {
		int duration;
		int defenseBonus;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		if (!hasScript(usedon, "remprtct")) {
			doMobAnimation(usedon, 0x375A, 0x09, 0x14, 0x00, 0x00);
			sfx(there, 0x01ED, 0x00);
			if (hasObjVar(this, "magicItemModifier")) {
				int item_modifier = getObjVar(this, "magicItemModifier");
				duration = 0x06 * item_modifier;
				defenseBonus = 0x07;
			} else {
				defenseBonus = (getSkillLevel(user, 0x19) / 0x0A);
				duration = 0x06 * getSkillLevel(user, 0x19) / 0x05;
			}
			setNaturalAC(usedon, getNaturalAC(usedon) + defenseBonus);
			setObjVar(usedon, "defenseBonus", defenseBonus);
			attachScript(usedon, "remprtct");
			int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
			callback(usedon, duration, 0x13);
			success = 0x01;
		}
	}
	schedule_cleanup(this);
	return(success);
}
