inherits multidecay;

trigger destroyed {
	evict_vendors_on_decay(this);
	return(0x01);
}

trigger message("vendordelete") {
	obj vendor = args[0x00];
	remove_vendor_from_house(this, vendor);
	return(0x01);
}
