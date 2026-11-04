// The streak rule (LEARNING_BEHAVIOR §1.11): a day counts when the learner
// finishes at least one lesson part or quiz. Missing a whole day resets the
// streak to 0. Uses the phone's date, because the app works offline.

/// The phone's date as "yyyy-MM-dd" (the format saved in lastActiveDate).
String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The streak to show today: the saved streak if the last active day was
/// today or yesterday, otherwise 0.
int currentStreak({
  required int savedStreak,
  required String? lastActiveDate,
  required DateTime today,
}) {
  if (lastActiveDate == null || savedStreak <= 0) return 0;
  final todayKey = dayKey(today);
  // Noon avoids daylight-saving edges when stepping back one day.
  final noon = DateTime(today.year, today.month, today.day, 12);
  final yesterdayKey = dayKey(noon.subtract(const Duration(days: 1)));
  return lastActiveDate == todayKey || lastActiveDate == yesterdayKey
      ? savedStreak
      : 0;
}
