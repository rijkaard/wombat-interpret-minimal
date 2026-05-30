inherits spelskil;

member loc where;

trigger creation {
	where = getLocation(this);
	callback(this, 0x01, 0x94);
	return(0x01);
}

function void remove_invis(obj m_target) {
	setInvisible(m_target, 0x00);
	detachScript(m_target, "reminvis");
	return();
}

trigger callback(0x94) {
	if (getLocation(this) != where) {
		remove_invis(this);
	} else {
		callback(this, 0x01, 0x94);
	}
	return(0x00);
}

trigger callback(0x1F) {
	remove_invis(this);
	return(0x00);
}

trigger message("uninvis") {
	remove_invis(this);
	return(0x01);
}
