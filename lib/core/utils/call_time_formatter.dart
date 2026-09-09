import 'package:intl/intl.dart';

class CallTimeFormatter {
  CallTimeFormatter._();

  static String relativeDayAndTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dayDifference = today.difference(targetDay).inDays;

    final time = DateFormat('h:mm a').format(dateTime);

    if (dayDifference == 0) return 'Today, $time';
    if (dayDifference == 1) return 'Yesterday, $time';
    return '${DateFormat('MMM d').format(dateTime)}, $time';
  }

  static String duration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
