inherits spelskil;

function int cast_dispel(obj user, obj usedon) {
	int spell_success = 0x00;
	if ((is_targetable_mobile(usedon)) && (hasScript(usedon, "destcrea"))) {
		loc user_loc = getLocation(user);
		loc there = getLocation(usedon);
		int summon_difficulty;
		int skill_level = getSkillLevelReal(user, 0x19);
		faceHere(user, getDirectionInternal(user_loc, there));
		summon_difficulty = 0x00;
		summon_difficulty = getObjVar(usedon, "summonDifficulty");
		int difficulty = summon_difficulty;
		int success = testAndLearnSkill(user, 0x19, difficulty, 0x28);
		if (success > 0x00) {
			doLocAnimation(there, 0x3728, 0x08, 0x14, 0x00, 0x00);
			sfx(there, 0x0201, 0x00);
			deleteObject(usedon);
			spell_success = 0x01;
		} else {
			doMobAnimation(usedon, 0x3779, 0x0A, 0x14, 0x00, 0x00);
			systemMessage(user, "The " + getName(usedon) + " resisted the attempt to dispel it!");
		}
	}
	schedule_cleanup(this);
	return(spell_success);
}
