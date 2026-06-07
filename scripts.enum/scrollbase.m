inherits spelskil;

trigger lookedat {
	string label;
	int qty = getQuantity(this);
	int spell_idx = get_spell_index(this);
	string qty_str = qty;
	if (qty > 0x01) {
		label = qty_str + " " + get_spell_name(spell_idx) + " scrolls";
	} else {
		label = "a " + get_spell_name(spell_idx) + " scroll";
	}
	barkTo(this, looker, label);
	return(0x00);
}
