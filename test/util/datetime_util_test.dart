import 'package:oauth_http/util/datetime_util.dart';
import 'package:test/test.dart';

void main() {
	group(
		'inPast',
				() {
			test(
				'returns true if dateTime is before the current time',
						() {
					var dateTime = _datePlusMinutes(-1);
					var isInPast = inPast(dateTime);
					expect(
						isInPast,
						true,
					);
				},
			);

			test(
				'returns false if dateTime is after the current time',
						() {
					var dateTime = _datePlusMinutes(1);
					var isInPast = inPast(dateTime);
					expect(
						isInPast,
						false,
					);
				},
			);
		},
	);
}

DateTime _datePlusMinutes(int minutesToAdd) {
	var now = DateTime.now();
	var durationToAdd = Duration(minutes: minutesToAdd);
	return now.add(durationToAdd);
}
