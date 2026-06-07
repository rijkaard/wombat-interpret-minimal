trigger use {
	if (!hasObjVar(this, "hasBeenSet")) {
		int book_num = random(0x01, 0x1B);
		setROBookNum(this, book_num);
		string title = getROBookTitle(book_num);
		setObjVar(this, "lookAtText", title);
		setObjVar(this, "hasBeenSet", 0x01);
	}
	return(0x01);
}
