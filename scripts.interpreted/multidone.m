trigger creation {
	list f_args;
	obj slave;
	obj deed;
	slave = getMultiSlaveId(this);
	if (slave != NULL()) {
		if (hasObjVar(slave, "mydeed")) {
			deed = getobjvar_obj(slave, "mydeed");
			appendToList(f_args, slave);
			message(deed, "multidone", f_args);
		}
	}
	detachScript(this, "multidone");
	return(0x01);
}
