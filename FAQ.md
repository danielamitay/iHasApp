# Frequently Asked Questions

#### How does it detect apps?

iHasApp has a large list of URL schemes, mapped to the iOS App that they identify. The framework essentially runs through all of these schemes, and determines which URL schemes are handled by the current device, and create a list of application ids as a result of successful queries. Read more [here](http://danielamitay.com/blog/2011/2/16/how-to-detect-installed-ios-apps).

#### How was schemeApps.json compiled?

The original schemeApps.json list was compiled by extracting the URL schemes and app ids from a large collection of app IPA files. Read more [here](http://danielamitay.com/blog/2011/5/9/detailed-iphone-app-ipa-statistics). For a good example of a script that can run through your computer's iTunes' Mobile Applications, take a look at Heiko Behrens' iHasApp-related repository [here](https://github.com/HBehrens/collectIPAMetaData).

#### Why is it not detecting all of my apps?

Unfortunately, not every iOS app implements a URL scheme (less than 50% - [link](http://danielamitay.com/blog/2011/5/9/detailed-iphone-app-ipa-statistics)). As a result, not every app can be detected. Furthermore, iHasApp must know about an app's URL scheme to even attempt to detect it, and because this link is only made by analyzing an app IPA file, there is the additional bottleneck of needing to purchase and download an app from the App Store.

#### Will using iHasApp get my app rejected?

No. iHasApp only uses public and documented methods. Furthermore, iHasApp has already been used in numerous production apps that have passes the App Store review multiple times. However, as with any set of user information, it is probably best to disclose your use of such information to the end user.
