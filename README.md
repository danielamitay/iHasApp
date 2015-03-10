### Notice:
#####This project was made as a "proof of concept" demonstration of how to detect apps installed on an iOS device, from nearly four years ago. A truly effective app detection system relies upon an accurate and dynamic dataset, which this open source repository is ill-suited for.

#####If app detection is an important part of your service, you should make sure to curate your own dataset (see the FAQ for more information), or consider using a more advanced service such as [iHasApp.com](https://www.ihasapp.com)

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

App Store Safe
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
