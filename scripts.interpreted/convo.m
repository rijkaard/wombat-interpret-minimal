inherits sk_table;

trigger convofunc("TalkerName") {
	setConvoRet(getName(talker));
	return(0x00);
}

function void do_attack(obj attacker, obj victim) {
	attack(attacker, victim);
	return();
}
