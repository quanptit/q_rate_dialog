import 'package:q_common_utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:q_theme/q_theme.dart';

import '../app_rate_utils.dart';

void showDialogRating(BuildContext context,
    {required String linkContract, String? appStoreId}) async {
  // if (await AppRateUtils.needShowRateSuggess()) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        DialogRating(linkContract: linkContract, appStoreId: appStoreId),
  );
  //   return true;
  // }
  // return false;
}

class DialogRating extends StatefulWidget {
  final String linkContract;
  final String? appStoreId;

  const DialogRating({super.key, required this.linkContract, this.appStoreId});

  @override
  State<DialogRating> createState() => _DialogRatingState();
}

enum _RateState { good, notGood, none }

class _DialogRatingState extends State<DialogRating> {
  double ratingValue = 0;
  _RateState _rateState = _RateState.none;

  void btnSubmitClick() {
    if (ratingValue == 0) {
      L.d("ratingValue 0");
      UiUtils.showSnackBar(LanguagesUtils.getString(
          "not_given_star", "You have not given stars!"));
      return;
    }
    if (ratingValue > 4.5) {
      setState(() {
        _rateState = _RateState.good;
      });
    } else {
      AppRateUtils.setUserHasRateAppNotGood();
      setState(() {
        _rateState = _RateState.notGood;
      });
    }
  }

  void btnNotNowClick() {
    // AppRateUtils.setUserChooseNotNow(); // ko cần vì đã xử lý ở onDismiss
    RouteUtils.backPress(context: context);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_rateState == _RateState.good) {
      child = _buildRateStateGood(context);
    } else if (_rateState == _RateState.notGood) {
      child = _buildRateStateNotGood(context);
    } else {
      child = _buildRateStateNone(context);
    }

    bool isSmall = CommonUtils.isSmall(context);

    return GeneralDialog(
      onDismiss: () => AppRateUtils.setUserChooseNotNow(),
      dismisAble: true,
      child: Center(
        child: Card(
          margin: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 32, vertical: isSmall ? 16 : 32),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12 : 16, vertical: 20),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildRateStateGood(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LanguagesUtils.getString("thank_you", "Thank you!"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        E.sizeBoxHeight_16,
        Text(
            LanguagesUtils.getString("rate_msg2",
                "Please help us out - It'd be really helpful if you rate us on store."),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center),
        E.sizeBoxHeight_32,
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: btnNotNowClick,
              child: Text(
                LanguagesUtils.getString("Notnow", "Not now").toUpperCase(),
                style: TextStyle(fontSize: 16, color: T.getColors(context).secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                RouteUtils.backPress(context: context);
                AppRateUtils.openStoreForReview(
                    appStoreId: widget.appStoreId);
                AppRateUtils.setUserHasGoStoreRateApp();
              },
              child: Text(
                LanguagesUtils.getString("yes_sure", "Yes, sure!")
                    .toUpperCase(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRateStateNotGood(BuildContext context) {
    String linkContract = widget.linkContract;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              LanguagesUtils.getString(
                  "How_make_better", "How can we make it better?"),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          E.sizeBoxHeight_16,
          InkWellButton(
            onTap: () =>
                CommonUtils.openUrlWithExternalApplication(linkContract),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Text(
                      LanguagesUtils.getString(
                          "please_contact_us", "Please contact us"),
                      style: const TextStyle(fontSize: 13)),
                ),
                Text(linkContract,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlue,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ),
          E.sizeBoxHeight_32,
          ElevatedButton.icon(
            onPressed: () => RouteUtils.backPress(context: context),
            label:
                Text(LanguagesUtils.getString("Close", "Close").toUpperCase()),
            icon: const Icon(Icons.close_rounded),
          )
        ],
      ),
    );
  }

  Widget _buildRateStateNone(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset("packages/q_rate_dialog/imgs/ic_rate_dialog.png",
            width: 64, height: 64),
        E.sizeBoxHeight_16,
        Text(
            LanguagesUtils.getString(
                "rate_msg1", "How was your experience with us?"),
            style: T.textTheme(context).headlineSmall,
            textAlign: TextAlign.center),
        E.sizeBoxHeight_16,
        Center(
          child: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 43,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                ratingValue = rating;
              });
            },
          ),
        ),
        Text("${ratingValue.toInt()}/5",
            style: T.textTheme(context).headlineSmall?.copyWith(
                color: T.getColors(context).primary,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        E.sizeBoxHeight_32,
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: btnNotNowClick,
              child: Text(
                LanguagesUtils.getString("Notnow", "Not now").toUpperCase(),
                style: TextStyle(fontSize: 18, color: T.getColors(context).secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: btnSubmitClick,
              child: Text(
                LanguagesUtils.getString("Submit", "Submit").toUpperCase(),
                style: TextStyle(
                    fontSize: 18, color: T.getColors(context).primary),
              ),
            ),
          ],
        )
      ],
    );
  }
}
