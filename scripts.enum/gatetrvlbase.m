inherits spelskil;

function int validate_gate_target(obj user, obj usedon) {
	if (usedon == NULL()) {
		return(0x00);
	}
	if ((containedBy(usedon) == NULL()) && (canSeeObj(user, usedon) != 0x01)) {
		bark(user, "I cannot see that object.");
		return(0x00);
	}
	if (isMobile(usedon)) {
		bark(user, "I cannot gate travel from that object.");
		return(0x00);
	}
	return(0x01);
}

function loc get_cast_dest(loc src) {
	return(src);
}

function int cast_gate_travel(obj user, obj usedon) {
	int success = 0x00;
	int tmp;
	loc pos = getLocation(user);
	obj caster = user;
	loc dest = get_cast_dest(pos);
	faceHere(user, getDirectionInternal(pos, dest));
	obj runestone = usedon;
	pos = dest;
	loc destination = getObjVar(runestone, "markLoc");
	if (can_teleport_in(destination) && can_teleport_out(destination) && can_teleport_in(dest) && can_teleport_out(dest) && (!gate_exists_at(dest))) {
		obj source_gate = createGlobalObjectAt(0x0F6C, dest);
		pos = getLocation(source_gate);
		if (isValid(source_gate)) {
			int xPoint = getX(destination);
			int yPoint = getY(destination);
			int zPoint = getZ(destination);
			setObjVar(source_gate, "xPoint", xPoint);
			setObjVar(source_gate, "yPoint", yPoint);
			setObjVar(source_gate, "zPoint", zPoint);
			attachScript(source_gate, "opengate");
			attachScript(source_gate, "destroy");
			callback(source_gate, 0x1E, 0x1E);
			obj dest_gate = createGlobalObjectAt(0x0F6C, pos);
			if (isValid(dest_gate)) {
				xPoint = getX(pos);
				yPoint = getY(pos);
				zPoint = getZ(pos);
				setObjVar(dest_gate, "xPoint", xPoint);
				setObjVar(dest_gate, "yPoint", yPoint);
				setObjVar(dest_gate, "zPoint", zPoint);
				setObjVar(dest_gate, "sourceGate", source_gate);
				attachScript(dest_gate, "opengate");
				attachScript(dest_gate, "destroy");
				callback(dest_gate, 0x1E, 0x1E);
				shortcallback(dest_gate, 0x00, 0x79);
				success = 0x01;
				sfx(pos, 0x020E, 0x00);
				int teleport_result = teleport(dest_gate, destination);
			}
		} else {
			barkTo(caster, caster, "I will need more room to cast this next time!");
		}
	} else {
		systemMessage(caster, "You can not teleport from here to the destination.");
	}
	schedule_cleanup(this);
	return(success);
}
