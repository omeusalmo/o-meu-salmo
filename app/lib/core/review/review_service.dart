import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ReviewService {
  ReviewService._();
  static final instance = ReviewService._();

  static const _triggerSession = 3;

  Future<void> incrementSession() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(AppConstants.prefReviewSessionCount) ?? 0) + 1;
    await prefs.setInt(AppConstants.prefReviewSessionCount, count);
  }

  Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool(AppConstants.prefReviewRequested) ?? false;
    if (alreadyRequested) return;

    final sessionCount = prefs.getInt(AppConstants.prefReviewSessionCount) ?? 0;
    if (sessionCount < _triggerSession) return;

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return;

    await inAppReview.requestReview();
    await prefs.setBool(AppConstants.prefReviewRequested, true);
  }
}
