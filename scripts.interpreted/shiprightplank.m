inherits shipplank;

trigger creation {
	int result = set_plank_state_var(this, 0x00, "shiprightplank");
	return(0x01);
}

trigger enterrange(0x00) {
	return(handle_plank_enter(0x00, this, target));
}

trigger ooruse {
	if (isDead(user)) {
		handle_ghost_plank_use(0x00, this, user);
		return(0x00);
	}
	int result = handle_plank_use(0x00, this, user);
	if (!set_plank_state_var(this, 0x00, "shiprightplank")) {
		play_music_to_crew(getMultiSlaveId(this));
	}
	return(0x00);
}

trigger use {
	if (isDead(user)) {
		handle_ghost_plank_use(0x00, this, user);
		return(0x00);
	}
	int result = handle_plank_use(0x00, this, user);
	if (!set_plank_state_var(this, 0x00, "shiprightplank")) {
		play_music_to_crew(getMultiSlaveId(this));
	}
	return(0x01);
}

trigger multirecycle {
	update_plank_on_recycle(0x00, this, oldtype);
	return(0x01);
}
