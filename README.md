### Notice:
##### This project was made as a "proof of concept" demonstration of how to detect apps installed on an iOS device, from early 2011. Since then, it has been used extensively in many apps, to the point where Apple made the decision to ban the excessive use of `-canOpenURL:`, the method which iHasApp relies upon to determine app installation. As a result, using a list of URL schemes for app detection is no longer a viable method.

###### Statement from Apple:
> We found that your app uses public APIs in a manner not prescribed by Apple, which is not in compliance with the iOS Developer Program License Agreement, as required by the App Store Review Guidelines.

> In particular, section 3.3.1 of the iOS Developer Program License Agreement specifies:

> "Applications may only use Documented APIs in the manner prescribed by Apple and must not use or call any private APIs"

> Specifically, we found this app misuses "canOpenURL:" to extrapolate which apps are installed on a device.

iHasApp Framework
=========================

The `iHasApp` iOS Framework allows you to detect installed apps on a user's device. Detection results can be in the form of an array of detected appIds, or an array of appDictionaries from the [iTunes Search API](http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html).

![Screenshot](https://github.com/danielamitay/iHasApp/raw/master/screenshot.png)

Frequently Asked Questions
-----------

- [How does it detect apps?](FAQ.md#how-does-it-detect-apps)
- [How was schemeApps.json compiled?](FAQ.md#how-was-schemeappsjson-compiled)
- [Why is it not detecting all of my apps?](FAQ.md#why-is-it-not-detecting-all-of-my-apps)
- [Will using iHasApp get my app rejected?](FAQ.md#will-using-ihasapp-get-my-app-rejected)

Background
-----------

- [How To Detect Installed iOS Apps](http://danielamitay.com/blog/2011/2/16/how-to-detect-installed-ios-apps) - (Feb 2011)
- [Detailed iPhone App IPA Statistics](http://danielamitay.com/blog/2011/5/9/detailed-iphone-app-ipa-statistics) - (May 2011)

Basic Setup
-----------

1. Add the `iHasApp` subfolder to your project and ensure that it is linked to the project target.
2. Add `#import "iHasApp.h"` to the classes in which you wish to access iHasApp.
3. Initialize and begin detection methods.

Example code:

```objective-c
iHasApp *detectionObject = [[iHasApp alloc] init];
[detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
    NSLog(@"Incremental appDictionaries.count: %i", (int)appDictionaries.count);
} withSuccess:^(NSArray *appDictionaries) {
    NSLog(@"Successful appDictionaries.count: %i", (int)appDictionaries.count);
} withFailure:^(NSError *error) {
    NSLog(@"Failure: %@", error.localizedDescription);
}];
```

Requirements
-----------

- iOS base SDK 5.0+

*Note*: schemeApps.json only adds ~180kB to your final, compiled IPA

App Store Safe (UPDATE: no longer accurate; see above)
--------------

The `iHasApp` framework utilizes only public, documented, and non-deprecated APIs. It is completely App Store safe. There are already a number of approved apps on the App Store that have integrated iHasApp.

Like all things, it is always a prudent idea to either ask your users' permission or to include a clause in your EULA.

Example Application
--------------

This framework comes with an example application that demonstrates detection initialization and information display.

The iHasAppExample project uses Olivier Poitrey's [SDWebImage](https://github.com/rs/SDWebImage) project to asynchronously display the app icons.

Info & Support
--------------

- Website: [iHasApp](http://www.ihasapp.com)
- Author: [Daniel Amitay](https://github.com/danielamitay)
- Email: hello@danielamitay.com
