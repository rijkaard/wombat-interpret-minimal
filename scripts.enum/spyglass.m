inherits globals;

trigger use {
	int trammel_phase = getTrammelPhase();
	int felucca_phase = getFeluccaPhase();
	string trammel_phase_str = getMoonPhaseStr(trammel_phase);
	string felucca_phase_str = getMoonPhaseStr(felucca_phase);
	superBark(user, trammel_phase_str + " " + felucca_phase_str, 0xFFFFFFFF, 0x08, 0x00);
	return(0x00);
}
