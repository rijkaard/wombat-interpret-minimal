trigger use {
	string msg;
	int hour;
	string hour_str;
	int minute;
	string minute_str;
	int oclock_flag = 0x00;
	minute = getMinute();
	hour = getHour();
	if (0x00) {
		string hour_s = hour;
		string minute_s = minute;
		string debug_msg = "It is " + hour_s + ":" + minute_s + ".";
		ebark(this, debug_msg);
	}
	minute = minute / 0x05;
	switch(minute) {
	case 0x00
		minute_str = "";
		oclock_flag = 0x01;
		break;
	case 0x01
		minute_str = "a few minutes past";
		break;
	case 0x02
		minute_str = "ten past";
		break;
	case 0x03
		minute_str = "quarter past";
		break;
	case 0x04
		minute_str = "twenty minutes past";
		break;
	case 0x05
		minute_str = "a few minutes shy of half-past";
		break;
	case 0x06
		minute_str = "half-past";
		break;
	case 0x07
		minute_str = "just over half-past";
		break;
	case 0x08
		minute_str = "lacking twenty minutes until";
		hour = hour + 0x01;
		break;
	case 0x09
		minute_str = "quarter of";
		hour = hour + 0x01;
		break;
	case 0x0A
		minute_str = "ten of";
		hour = hour + 0x01;
		break;
	case 0x0B
		minute_str = "almost";
		hour = hour + 0x01;
		oclock_flag = 0x01;
		break;
	case 0x0C
		minute_str = "";
		oclock_flag = 0x01;
		break;
	default
		minute_str = "no known minutes!";
		break;
	}
	if (hour > 0x17) {
		hour = 0x00;
	}
	switch(hour) {
	default
		hour_str = "no known hour!";
		break;
	case 0x00
		hour_str = "midnight";
		oclock_flag = 0x00;
		break;
	case 0x0C
		hour_str = "noon";
		oclock_flag = 0x00;
		break;
	case 0x01
	case 0x0D
		hour_str = "one";
		break;
	case 0x02
	case 0x0E
		hour_str = "two";
		break;
	case 0x03
	case 0x0F
		hour_str = "three";
		break;
	case 0x04
	case 0x10
		hour_str = "four";
		break;
	case 0x05
	case 0x11
		hour_str = "five";
		break;
	case 0x06
	case 0x12
		hour_str = "six";
		break;
	case 0x07
	case 0x13
		hour_str = "seven";
		break;
	case 0x08
	case 0x14
		hour_str = "eight";
		break;
	case 0x09
	case 0x15
		hour_str = "nine";
		break;
	case 0x0A
	case 0x16
		hour_str = "ten";
		break;
	case 0x0B
	case 0x17
		hour_str = "eleven";
		break;
	}
	if (oclock_flag) {
		hour_str = hour_str + " o'clock";
	}
	if ((hour > 0x00) && (hour < 0x0B)) {
		hour_str = hour_str + " in the morning";
	}
	if ((hour > 0x0C) && (hour < 0x15)) {
		hour_str = hour_str + " in the afternoon";
	}
	if (hour > 0x14) {
		hour_str = hour_str + " at night";
	}
	msg = "It is " + minute_str + " " + hour_str + ".";
	ebarkTo(this, user, msg);
	return(0x01);
}
