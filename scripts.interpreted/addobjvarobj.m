member obj item_to_add;

trigger use {
	item_to_add = NULL();
	systemMessage(user, "What would you like to add?");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (item_to_add == NULL()) {
		item_to_add = usedon;
		systemMessage(user, "What would you like to add " + getName(usedon) + " to?");
		targetObj(user, this);
	} else {
		string var_name;
		if (hasObjVar(this, "objVarListSetName")) {
			var_name = getObjVar(this, "objVarListSetName");
			int result = addToObjVarListSet(usedon, var_name, item_to_add);
		}
		if (hasObjVar(this, "objVarObjName")) {
			var_name = getObjVar(this, "objVarObjName");
			setObjVar(usedon, var_name, item_to_add);
		}
	}
	return(0x00);
}
