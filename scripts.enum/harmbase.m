inherits spelskil;

function int apply_harm(obj user, obj usedon, int reverse) {
	int hit = 0x00;
	if (is_targetable_mobile(usedon)) {
		hit = 0x01;
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x374A, 0x0A, 0x0F, 0x00, 0x00);
		sfx(there, 0x01F1, 0x00);
		int damage = apply_spell_damage(this, user, usedon, 0x01, reverse);
		report_obj_aggression(user, usedon, 0x02, reverse);
	}
	schedule_cleanup(this);
	return(hit);
}
