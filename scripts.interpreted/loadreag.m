inherits spelskil;

function void fill_reagents(obj usedon) {
	int dummy;
	for (int i = 0x00; i < 0x0B; i++) {
		obj black_pearl = requestCreateObjectIn(0x0F7A, usedon);
		if (black_pearl == NULL()) {
			return();
		}
		obj bloodmoss = requestCreateObjectIn(0x0F7B, usedon);
		if (bloodmoss == NULL()) {
			return();
		}
		obj garlic = requestCreateObjectIn(0x0F84, usedon);
		if (garlic == NULL()) {
			return();
		}
		obj ginseng = requestCreateObjectIn(0x0F85, usedon);
		if (ginseng == NULL()) {
			return();
		}
		obj mandrake = requestCreateObjectIn(0x0F86, usedon);
		if (mandrake == NULL()) {
			return();
		}
		obj nightshade = requestCreateObjectIn(0x0F88, usedon);
		if (nightshade == NULL()) {
			return();
		}
		obj spider_silk = requestCreateObjectIn(0x0F8C, usedon);
		if (spider_silk == NULL()) {
			return();
		}
		obj sulph_ash = requestCreateObjectIn(0x0F8D, usedon);
		if (sulph_ash == NULL()) {
			return();
		}
	}
	return();
}

trigger creation {
	fill_reagents(this);
	return(0x00);
}
