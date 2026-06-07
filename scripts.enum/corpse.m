inherits globals;

function obj get_controller() {
	if (!hasObjVar(this, "controller")) {
		return(NULL());
	}
	obj owner = getObjVar(this, "controller");
	return(owner);
}

trigger use {
	int added = addToObjVarListSet(this, "users", getName(user));
	return(0x01);
}

trigger death {
	obj mobile = corpse;
	int body_type = getCorpseBodyType(this);
	if ((body_type == 0x0190) || (body_type == 0x0191)) {
		if (attacker != NULL()) {
			setObjVar(this, "murderer", getName(attacker));
		}
		setObjVar(this, "nameVar", getName(mobile));
	}
	if (isPlayer(mobile)) {
		setObjVar(this, "controller", mobile);
		if (hasObjVar(mobile, "crimeVictimList")) {
			removeObjVar(mobile, "crimeVictimList");
			setCriminal(mobile, 0x01E0);
			setObjVar(this, "criminal", 0x01);
		}
	}
	copyObjVar(this, mobile, "murderCount");
	copyObjVar(this, mobile, "criminal");
	copyObjVar(this, mobile, "crimeVictimList");
	copyObjVar(this, mobile, "lawfullyDamaged");
	copyObjVar(this, mobile, "aggressionVictimList");
	copyObjVar(this, mobile, "opposingGuilds");
	copyObjVar(this, mobile, "guildstoneId");
	copyObjVar(this, mobile, "guildType");
	return(0x01);
}

function void apply_unhealthy_action(obj user) {
	int body_type = getCorpseBodyType(this);
	if ((body_type == 0x0190) || (body_type == 0x0191)) {
		receiveUnhealthyActionFrom(this, user);
	}
	return();
}

trigger objaccess(0x04) {
	if (this == usedon) {
		return(0x01);
	}
	apply_unhealthy_action(user);
	return(0x01);
}

trigger objaccess(0x08) {
	if (this == usedon) {
		return(0x01);
	}
	apply_unhealthy_action(user);
	return(0x01);
}
