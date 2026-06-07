inherits itemmanip;

trigger lookedat {
	barkTo(this, looker, "pile of boards");
	if (testSkill(looker, SKILL_CARPENTRY)) {
		bark_resource_count(looker, "wood");
	}
	return(0x00);
}
