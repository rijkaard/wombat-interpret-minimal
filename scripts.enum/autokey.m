inherits add_door_to_key;

trigger creation {
	list unlock_list;
	if (!hasObjVar(this, "whatIUnlock")) {
		setObjVar(this, "whatIUnlock", unlock_list);
	}
	return(0x01);
}

trigger speech("add_door") {
	if (isEditing(speaker)) {
		barkTo(this, speaker, "Which door do you want to add to my keylist?");
		targetObj(speaker, this);
	}
	return(0x00);
}

trigger speech("finished") {
	if (isEditing(speaker)) {
		bark(this, "okay");
		detachScript(this, "autokey");
	}
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (isEditing(user)) {
		attach_lockable_to_key(usedon, this);
		bark(this, "Added door to my keylist.");
	}
	return(0x00);
}
