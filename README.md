Notice (Nov 13, 2012):
-----------

iHasApp's codebase and dataset will be open sourced within the week. Check back!

iHasApp Framework
=========================

The iHasApp iOS Framework allows you to detect installed apps on a user's device.

Detection results can be in the form of an array of detected appIds, or an array of appDictionaries from the iTunes Search API.

Basic Setup
-----------

1. Add iHasApp.framework to your project and ensure that it is linked to the project target.

2. Add `#import <iHasApp/iHasApp.h>` to the classes in which you wish to access iHasApp.

3. Initialize and begin detection methods.

Example code:

```objective-c
iHasApp *detectionObject = [[iHasApp alloc] init];
[detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
    NSLog(@"Incremental appDictionaries.count: %i", appDictionaries.count);
} withSuccess:^(NSArray *appDictionaries) {
    NSLog(@"Successful appDictionaries.count: %i", appDictionaries.count);
} withFailure:^(NSError *error) {
    NSLog(@"Failure: %@", error.localizedDescription);
}];
```

Requirements
-----------

- iOS base SDK 5.0+
- Internet connectivity

App Store Safe
--------------

The iHasApp framework utilizes only public, documented, and non-deprecated APIs. It is completely App Store safe. There are already a number of approved apps on the App Store that have integrated iHasApp.

Like all things, it is always a prudent idea to either ask your users' permission or to include a clause in your EULA.

Example Application
--------------

This framework comes with an example application that demonstrates detection initialization and information display.

The iHasAppExample project uses Olivier Poitrey's [SDWebImage](https://github.com/rs/SDWebImage) project to asynchronously display the app icons.

Documentation
--------------

The `iHasApp.h` header file is structurally commented. If you would like to see the Appledoc representation, visit the [iHasApp Documentation](http://www.ihasapp.com/documentation).

Info & Support
--------------

Website: [iHasApp](http://www.ihasapp.com)
Author: [Daniel Amitay](https://github.com/danielamitay)
Email: daniel@ihasapp.com