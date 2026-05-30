inherits scrollbase;

trigger objectloaded {
	validate_and_configure_scroll(this);
	return(0x01);
}

trigger creation {
	attachScript(this, "magctrap");
	setObjVar(this, "isScroll", 0x00);
	return(0x00);
}

trigger callback(0x48) {
	destroy_if_not_in_spellbook(this);
	return(0x00);
}
