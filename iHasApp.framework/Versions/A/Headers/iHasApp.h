//
//  iHasApp.h
//  iHasApp
//
//  Created by Daniel Amitay on 4/30/12.
//  Copyright (c) 2012 Objective-See, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    iHasAppErrorConnection = 0,
    iHasAppErrorInvalidKey = 1,
    iHasAppErrorReachedLimit = 2,
    iHasAppErrorUnknown = 3
} iHasAppError;


/** The iHasAppDelegate protocol describes the interface iHasApp delegates should adopt to respond to app detection events.
 */
@protocol iHasAppDelegate <NSObject>

@optional

/** Sent to the delegate when the app detection has successfully completed.
 
 @param allApps An array containing NSDictionaries of the iHasApp object's most recently detected apps. Equivalent to calling -detectedApps on the iHasApp object.
 @see appDetectionDidSucceed:
 */
- (void)appDetectionDidSucceed:(NSArray *)allApps;

/** Sent to the delegate when the app detection has unsuccessfully terminated.
 
 @param detectionError Contains an error enum describing the problem.
 @see appDetectionDidSucceed:
 */
- (void)appDetectionDidFail:(iHasAppError)detectionError;

@end


/** The `iHasApp` class is used to perform on-device app detection.
 
 You will need to register for a free account at https://www.ihasapp.com to obtain a valid API key.
 */
@interface iHasApp : NSObject

/**---------------------------------------------------------------------------------------
 * @name Properties
 * ---------------------------------------------------------------------------------------
 */

/** The API key from your https://www.ihasapp.com account dashboard. An incorrect API key will result in a failed app detection. Default is nil.
 */
@property (nonatomic, strong) NSString *APIKey;

/** The delegate object to receive detection events.
 */
@property (nonatomic, assign) NSObject<iHasAppDelegate> *delegate;

/** The two-letter country code for the store you want to search. The search uses the default store front for the specified country. Default is US.
 
 See http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of ISO Country Codes.
 
    //To determine device-specific country codes, use:
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
 
 */
@property (nonatomic, strong) NSString *country;

/**---------------------------------------------------------------------------------------
 * @name Starting the Detection
 * ---------------------------------------------------------------------------------------
 */

/** Initializes and returns the iHasApp object with the specified delegate and APIKey.

 @param delegate The object to receive the delegate callbacks.
 @param key The API key from your https://www.ihasapp.com account dashboard.
 @return An initialized iHasApp object.
 */
- (iHasApp *)initWithDelegate:(id<iHasAppDelegate>)delegate andKey:(NSString *)key;


/** Starts the app detection process.
 */
- (void)beginDetection;

/**---------------------------------------------------------------------------------------
 * @name Informational
 * ---------------------------------------------------------------------------------------
 */

/** Returns an array containing NSDictionaries of the most recently detected apps.
 
 @return An array containing NSDictionaries of the iHasApp object's most recently detected apps, or nil if the detection is incomplete or unsuccessful. The order of the dictionaries in the array is not defined.
 
 The dictionaries are the same as the results returned from an iTunes Search API request. See the "results" of the following api response for an example: http://itunes.apple.com/lookup?id=284882215
 
 @see appIds
 */
- (NSArray *)detectedApps;


/** Returns an array containing NSStrings of the most recently detected app ids (referred to as 'trackId' in iTunes dictionaries).
 
 @return An array containing NSStrings of the iHasApp object's most recently detected app ids, or nil if the detection is incomplete or unsuccessful. The order of the strings in the array is not defined.
 @see detectedApps
 */
- (NSArray *)appIds;


/** Returns the iHasApp framework version string.
 
 @return An NSString representation of the iHasApp framework version.
 */
- (NSString *)version;


@end