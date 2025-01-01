import 'package:q_common_utils/index.dart';

import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';


import 'rating_dialog/dialog_rating.dart';

class AppRateUtils {
  ///[appStoreId] là id của apple cho ios
  static showInAppReviewOrStoreIfNotAvail({String? appStoreId}) async {
    L.d('showInAppReviewOrStoreIfNotAvail');
    InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      L.d('inAppReview isAvailable');
      try {
        await inAppReview.requestReview();
      } catch (err) {
        L.e('showInAppReviewOrStoreIfNotAvail Exception: $err');
        inAppReview.openStoreListing(appStoreId: appStoreId);
      }
    } else {
      L.d('inAppReview openStoreListing');
      inAppReview.openStoreListing(appStoreId: appStoreId);
    }
  }

  ///[appStoreId] là id của apple cho ios
  static openStoreForReview({String? appStoreId}) async {
    InAppReview inAppReview = InAppReview.instance;
    if (CommonUtils.isIOS() && appStoreId == null) return;
    inAppReview.openStoreListing(appStoreId: appStoreId);
  }

  /// Gọi khi Home Resume. sử dụng để xác định app được sử dụng nhiều hay ít để hiển thị Rate Dialog.
  /// Tự động show dialog rate app khi đạt yêu cầu.
  /// @isCreate: if true => không show dialog nếu có thỏa mãn lượt sử dụng. và ngược lại.
  static trakingGoHome(BuildContext context,
      {required bool isCreate, required String linkContract, String? appStoreId}) async {
    int noGoHome = await PreferencesUtils.getInt(TRACK_HOME) ?? 0;
    noGoHome++;
    await PreferencesUtils.saveInt(TRACK_HOME, noGoHome);
    L.d("count trakingGoHome: $noGoHome");

    if (!isCreate) {
      bool isNeedShowDialog = await needShowRateSuggess();
      if (isNeedShowDialog) {
        await PreferencesUtils.saveInt(TRACK_HOME, 0);
        showDialogRating(context, linkContract: linkContract, appStoreId: appStoreId);
      }
    }
  }

  /// Chỉ ra trạng thái cần show yêu cầu người dùng rate app
  ///- trakingGoHome 10 lần, từ khi cài app, chọn not now thì reset lại
  ///- khi rate not good, mà vẫn sử dụng app, thì 30 lần sau lại hỏi rate
  ///Khi đã chọn rate vào mở store ==> đánh dấu ko hỏi nữa.
  static Future<bool> needShowRateSuggess() async {
    bool flagStore = await PreferencesUtils.getBool(FLAG_GO_STORE);
    if (flagStore) return false;
    int noGoHome = await PreferencesUtils.getInt(TRACK_HOME) ?? 0;
    if (noGoHome < 12) return false;

    int timeLastOpenAds = (await PreferencesUtils.getInt("KSTOA")) ?? 0;
    int subTimeMiliSecond = DateTime.now().millisecondsSinceEpoch - timeLastOpenAds;
    if (subTimeMiliSecond < 60 * 1000) return false; // Khi trước đó mới show ads => bỏ qua

    return true;
  }

  static setUserHasRateAppNotGood() {
    PreferencesUtils.saveInt(TRACK_HOME, -20);
  }

  /// đánh dấu người dùng đã nhấn vào store rate app, ko hiển thị lại cái rate app nữa
  static setUserHasGoStoreRateApp() {
    L.d("setUserHasGoStoreRateApp");
    PreferencesUtils.saveBool(FLAG_GO_STORE, true);
  }

  static void setUserChooseNotNow() async {
    L.d("setUserChooseNotNow");
    int noGoHome = await PreferencesUtils.getInt(TRACK_HOME) ?? 0;
    if (noGoHome <= 0) return;
    PreferencesUtils.saveInt(TRACK_HOME, 0);
  }

  static const String TRACK_HOME = "TRACK_HOME";
  static const String FLAG_GO_STORE = "F_G_STO";
}
