inherits allstatbase;

function int apply_mass_curse_aoe(obj user, loc place) {
	int hit_any = 0x00;
	list mobs;
	getMobsInRange(mobs, place, 0x02);
	int unused;
	for (int x = 0x00; x < numInList(mobs); x++) {
		obj mob = mobs[x];
		if (is_targetable_mobile(mob)) {
			if (!has_reflection(mob)) {
				if (apply_all_stat_effect(user, mob, 0x00, 0x00)) {
					hit_any = 0x01;
				}
			}
		}
	}
	sfx(place, 0x01FB, 0x00);
	report_obj_aggression(user, NULL(), 0x02, 0x00);
	schedule_cleanup(this);
	return(hit_any);
}
