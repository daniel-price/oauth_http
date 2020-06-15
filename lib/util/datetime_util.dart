bool inPast(DateTime dateTime) {
	var now = DateTime.now();
	return now.isAfter(dateTime);
}