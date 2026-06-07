inherits spelskil;

trigger creation {
	systemMessage(this, "You can not move!");
	return(0x01);
}

function void remove_paralysis(obj m_target) {
	setMobFlag(m_target, 0x02, 0x00);
	systemMessage(m_target, "You can move!");
	detachScript(m_target, "rempara");
	handleHealthGain(this);
	return();
}

trigger callback(0x0D) {
	remove_paralysis(this);
	return(0x00);
}

trigger washit {
	remove_paralysis(this);
	return(0x00);
}

trigger ishealthy {
	return(0x00);
}
