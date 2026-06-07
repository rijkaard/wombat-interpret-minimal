trigger creation {
	int hue = getHue(this);
	hue = hue - 0x8000;
	string blah = hue;
	bark(this, blah);
	detachScript(this, "barkhue");
	return(0x01);
}
