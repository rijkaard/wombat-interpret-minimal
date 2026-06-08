inherits globals;

function int needs_steal(obj user) {
	barkTo(user, user, "This doesn't belong to me, I'll have to steal it.");
	return(0x00);
}

trigger objaccess(0x04) {
	return(needs_steal(user));
}

trigger objaccess(0x05) {
	return(needs_steal(user));
}
