inherits globals;

function void set_immunity(obj m_target, int delay, int immunity_type) {
	switch(immunity_type) {
	case 0x00
		setObjVar(m_target, "poisonImmunity", 0x01);
		if (delay != 0x00) {
			callback(m_target, delay, 0x96)}
		;
		break;
	case 0x01
		setObjVar(m_target, "coldImmunity", 0x01);
		if (delay != 0x00) {
			callback(m_target, delay, 0x97)}
		;
		break;
	case 0x02
		setObjVar(m_target, "fireImmunity", 0x01);
		if (delay != 0x00) {
			callback(m_target, delay, 0x98)}
		;
		break;
	default
		bark(m_target, "Invalid immunity type.");
		break;
	}
	return();
}

trigger callback(0x96) {
	removeObjVar(this, "poisonImmunity");
	return(0x01);
}

trigger callback(0x97) {
	removeObjVar(this, "coldImmunity");
	return(0x01);
}

trigger callback(0x98) {
	removeObjVar(this, "fireImmunity");
	return(0x01);
}
