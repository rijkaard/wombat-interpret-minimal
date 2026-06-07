inherits globals;

trigger use {
	int trammel_phase = getTrammelPhase();
	int felucca_phase = getFeluccaPhase();
	string trammel_phase_str = getMoonPhaseStr(trammel_phase);
	string felucca_phase_str = getMoonPhaseStr(felucca_phase);
	barkTo(user, user, trammel_phase_str + " " + felucca_phase_str);
	return(0x00);
}
