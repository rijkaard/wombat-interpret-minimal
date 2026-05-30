inherits spelskil;

function void restore_mana(obj user, obj usedon) {
	restoreMana(usedon);
	setCurMana(usedon, 0x5A);
	return();
}

trigger use {
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	restore_mana(user, usedon);
	return(0x00);
}
