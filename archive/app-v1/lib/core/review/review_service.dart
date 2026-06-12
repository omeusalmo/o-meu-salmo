import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  ReviewService._();
  static final instance = ReviewService._();

  static const _keySessionCount = 'review_session_count';
  static const _keyRequested = 'review_requested';
  static const _triggerSession = 3;

  Future<void> incrementSession() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keySessionCount) ?? 0) + 1;
    await prefs.setInt(_keySessionCount, count);
  }

  Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool(_keyRequested) ?? false;
    if (alreadyRequested) return;

    final sessionCount = prefs.getInt(_keySessionCount) ?? 0;
    if (sessionCount < _triggerSession) return;

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return;

    await inAppReview.requestReview();
    await prefs.setBool(_keyRequested, true);
  }
}
