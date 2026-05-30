inherits spelskil;

function int do_cure(obj user, obj usedon, int skill_override) {
	int poisoned_flag = 0x00;
	if (is_targetable_mobile(usedon)) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		int skill_power;
		int poison = getObjVar(usedon, "poison_strength");
		int poison_power = (poison * 0x06D6);
		if (skill_override != 0x00) {
			skill_power = (skill_override * 0x4B);
		} else {
			skill_power = (getSkillLevel(user, 0x19) * 0x4B);
		}
		faceHere(user, getDirectionInternal(user_loc, there));
		doMobAnimation(usedon, 0x373A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x01E0, 0x00);
		if ((hasScript(usedon, "poisoned")) || (hasObjVar(usedon, "poison_strength"))) {
			poisoned_flag = 0x01;
			if (((0x2710 + (skill_power - poison_power)) / 0x64) > random(0x01, 0x64)) {
				cure_poison(usedon);
				int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
				systemMessage(user, "You have cured " + getName(usedon) + " of all poisons!");
				systemMessage(usedon, " " + getName(user) + " has cured you of all poisons!");
			} else {
				systemMessage(user, "You have failed to cure " + getName(usedon) + "!");
			}
		}
	}
	schedule_cleanup(this);
	return(poisoned_flag);
}
