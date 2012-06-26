iHasApp Framework
=========================

The iHasApp iOS Framework allows you to detect installed apps on a user's device.

Basic Setup
-----------

1. Sign up for a free account on [iHasApp.com](https://www.ihasapp.com) to receive your api key.

2. Add iHasApp.framework to your project and ensure that it is linked to the project target.

3. Add `#import <iHasApp/iHasApp.h>` to the files in which you wish to access iHasApp.

4. Initialize and configure the iHasApp object.

App Store Safe
--------------

The iHasApp framework utilizes only public, documented, and non-deprecated APIs. It is completely App Store safe.
There are already a number of approved apps on the App Store that have integrated iHasApp.

Like all things, it is always a prudent idea to either ask your users' permission or to include a clause in your EULA.

Example Application
--------------

This framework comes with a demo application that demonstrates initialization, country configuration (automatically grabbing the device's current locale), delegate methods, and information display. You will need to insert your own API key in the '-viewDidLoad' section of 'MasterViewController.m'.

The iHasAppExample project uses Olivier Poitrey's [SDWebImage](https://github.com/rs/SDWebImage) project to asynchronously display the app icons.

Documentation
--------------

The 'iHasApp.h' header file is structurally commented. If you would like to see the Appledoc representation, visit the [iHasApp Documentation](https://www.ihasapp.com/documentation).

Troubleshooting
--------------

Feel free to contact me at daniel@ihasapp.com