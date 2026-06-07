inherits spelskil;

member obj dragon;

member obj victim;

member loc user_loc;

member loc there;

member int special_attack_active;

member int melee_mode;

member int special_attack_ready;

member int action_delay_min;

member int action_delay_max;

member int pending_damage;

member obj melee_trig_target;

forward void calc_breath_origin(obj me, int facing);

function void schedule_tick(obj me) {
	int time = random(action_delay_min, action_delay_max);
	callback(me, time, 0x65);
	return();
}

trigger creation {
	special_attack_active = 0x00;
	melee_mode = 0x00;
	special_attack_ready = 0x01;
	action_delay_min = 0x07;
	action_delay_max = 0x0E;
	schedule_tick(this);
	return(0x01);
}

function int begin_breath_attack(obj me, obj target) {
	animateMobile(me, 0x0C, 0x05, 0x01, 0x00, 0x00);
	sfx(user_loc, 0x016A, 0x00);
	special_attack_active = 0x01;
	shortcallback(me, 0x04, 0x2F);
	return(0x01);
}

function int try_special_attack(obj me, obj target) {
	if ((special_attack_active == 0x00) && (special_attack_ready == 0x01)) {
		victim = target;
		there = getLocation(victim);
		user_loc = getLocation(me);
		if ((!isDead(victim)) && (canSeeLoc(me, there) == 0x01)) {
			disableBehaviors(me);
			faceHere(me, getDirectionInternal(user_loc, there));
			begin_breath_attack(me, target);
			special_attack_ready = 0x00;
			int time = random(action_delay_min, action_delay_max);
			callback(me, time, 0x64);
			return(0x01);
		}
	}
	return(0x00);
}

trigger callback(0x2F) {
	int damage = (getCurHP(this) / 0x0A);
	int facing = getFacing(this);
	calc_breath_origin(this, facing);
	if (melee_mode == 0x00) {
		int roll = random(0x01, 0x64);
		if (roll > 0x21) {
			doMissile_Loc2Mob(user_loc, victim, 0x36D4, 0x05, 0x00, 0x01);
		} else {
			loc there = getLocation(victim);
			int target_z = getZ(there) + 0x06;
			setZ(there, target_z);
			doMissile_Loc2Loc(user_loc, there, 0x36D4, 0x05, 0x00, 0x01);
		}
		pending_damage = damage;
		callback(this, 0x01, 0x19);
	} else {
		enableBehaviors(this);
		doDamageType(this, victim, damage, 0x04);
		scriptTrig(melee_trig_target, 0x07, this);
		special_attack_active = 0x00;
		melee_mode = 0x00;
	}
	sfx(user_loc, 0x015E, 0x00);
	return(0x00);
}

trigger callback(0x19) {
	enableBehaviors(this);
	doDamageType(this, victim, pending_damage, 0x04);
	scriptTrig(victim, 0x07, this);
	special_attack_active = 0x00;
	return(0x00);
}

function void calc_breath_origin(obj me, int facing) {
	user_loc = getLocation(me);
	switch(facing) {
	case 0x00
		setY(user_loc, getY(user_loc) - 0x03)setZ(user_loc, getZ(user_loc) + 0x0C)break;
	case 0x01
		setX(user_loc, getX(user_loc) + 0x02);
		setY(user_loc, getY(user_loc) - 0x01);
		setZ(user_loc, getZ(user_loc) + 0x14)break;
	case 0x02
		setX(user_loc, getX(user_loc) + 0x03);
		setZ(user_loc, getZ(user_loc) + 0x17)break;
	case 0x03
		break;
	case 0x04
		setX(user_loc, getX(user_loc) - 0x01);
		setY(user_loc, getY(user_loc) + 0x02);
		setZ(user_loc, getZ(user_loc) + 0x08)break;
	case 0x05
		setX(user_loc, getX(user_loc) - 0x02);
		setY(user_loc, getY(user_loc) + 0x01);
		setZ(user_loc, getZ(user_loc) + 0x07)break;
	case 0x06
		setX(user_loc, getX(user_loc) - 0x02);
		setZ(user_loc, getZ(user_loc) + 0x0A)break;
	case 0x07
		setZ(user_loc, getZ(user_loc) + 0x14)break;
	default
		break;
	}
	return();
}

trigger enterrange(0x08) {
	if (containedBy(this) == NULL()) {
		if (areBehaviorsEnabled(this)) {
			if (isHuman(target)) {
				if (!isDead(target)) {
					attack(this, target);
				}
			}
		}
	}
	return(0x01);
}

trigger callback(0x64) {
	special_attack_ready = 0x01;
	return(0x01);
}

trigger callback(0x65) {
	schedule_tick(this);
	if (containedBy(this) == NULL()) {
		if (getNumTargets(this) > 0x00) {
			obj target = getFirstVisableTargetInRange(this, 0x09);
			if (target != NULL()) {
				try_special_attack(this, target);
			}
		}
	}
	return(0x01);
}
