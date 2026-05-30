inherits spelskil;

function int apply_resurrection(obj user, obj usedon) {
	int success = 0x00;
	if (can_resurrect_target(user, usedon)) {
		loc caster_loc = getLocation(user);
		loc there = getLocation(usedon);
		faceHere(user, getDirectionInternal(caster_loc, there));
		doMobAnimation(usedon, 0x376A, 0x09, 0x20, 0x00, 0x00);
		sfx(there, 0x0214, 0x00);
		int notoriety_result = apply_spell_notoriety(user, usedon, 0x00, this);
		success = 0x01;
		offer_resurrect(user, usedon, 0x00, "It is possible for you to be resurrected now. Do you wish to try?");
	}
	schedule_cleanup(this);
	return(success);
}
