<img src=":/4614896c4996468887fceaab3afd764d" alt="e27be3ef7da264604f259171688b0118.png" width="263" height="245">

### Dialog Rate, review app

Chỉ cần gọi hàm trakingGoHome, tại vị trí muốn đếm và show Dialog này.
```

class _HomeWidget extends StatelessWidget {
  const _HomeWidget();

  @override
  Widget build(BuildContext context) {
    return RouteAwareWidget(
      didPush: () {
        AppRateUtils.trakingGoHome(context, isCreate: true, linkContract: KeysRef.LINK_CONSTRACT);
      },
      didPopNext: () => AppRateUtils.trakingGoHome(context, isCreate: false, linkContract: KeysRef.LINK_CONSTRACT),
      child: ConfirmQuitAppWrap(nativeAdUnit: Keys.MAX_NATIVE_EXIT, child: const LevelSelectScreen()),
    );
  }
}
 
```

### Cung cấp các function show store review app
`AppRateUtils.openStoreForReview();`