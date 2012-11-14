//
//  iHasApp.m
//  iHasApp
//
//  Created by Daniel Amitay on 10/21/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "iHasApp.h"

@implementation iHasApp

@synthesize country = _country;

#pragma mark - Public methods

- (void)detectAppIdsWithIncremental:(void (^)(NSArray *appIds))incrementalBlock
                        withSuccess:(void (^)(NSArray *appIds))successBlock
                        withFailure:(void (^)(NSError *error))failureBlock
{
    dispatch_queue_t detection_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(detection_thread, ^{
        
        [self retrieveSchemeAppsDictionaryWithSuccess:^(NSDictionary *schemeAppsDictionary) {
            NSMutableArray *schemeDictionaries = [NSMutableArray new];
            for (NSString *scheme in schemeAppsDictionary.allKeys)
            {
                NSArray *appIds = [schemeAppsDictionary objectForKey:scheme];
                NSDictionary *schemeDictionary = @{@"scheme" : scheme, @"ids" : appIds};
                [schemeDictionaries addObject:schemeDictionary];
            }
            
            __block BOOL successBlockExecuted = FALSE;
            NSMutableSet *successfulAppIds = [NSMutableSet set];
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            NSArray *arrayOfArrays =  [self subarraysOfArray:schemeDictionaries
                                                   withCount:1000];
            for (NSArray *schemeDictionariesArray in arrayOfArrays)
            {
                [operationQueue addOperationWithBlock: ^{
                    NSMutableSet *incrementalAppIds = [NSMutableSet set];
                    for (NSDictionary *schemeDictionary in schemeDictionariesArray)
                    {
                        NSString *scheme = [schemeDictionary objectForKey:@"scheme"];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]];
                        if([[UIApplication sharedApplication] canOpenURL:url])
                        {
                            NSArray *appIds = [schemeDictionary objectForKey:@"ids"];
                            for (NSString *appId in appIds)
                            {
                                if (![successfulAppIds containsObject:appId])
                                {
                                    [successfulAppIds addObject:appId];
                                    [incrementalAppIds addObject:appId];
                                }
                            }
                        }
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (incrementalBlock && incrementalAppIds.count)
                        {
                            incrementalBlock(incrementalAppIds.allObjects);
                        }
                    });
                    /* Unhappy with this implementation */
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC),
                                   dispatch_get_main_queue(), ^{
                                       if (operationQueue.operationCount == 0 && successBlock && !successBlockExecuted)
                                       {
                                           successBlockExecuted = TRUE;
                                           successBlock(successfulAppIds.allObjects);
                                       }
                                   });
                }];
            }
        } failure:failureBlock];
        
    });
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(detection_thread);
    #endif
}

- (void)detectAppDictionariesWithIncremental:(void (^)(NSArray *appDictionaries))incrementalBlock
                                 withSuccess:(void (^)(NSArray *appDictionaries))successBlock
                                 withFailure:(void (^)(NSError *error))failureBlock
{
    __block BOOL successBlockExecuted = FALSE;
    __block BOOL appIdDetectionComplete = FALSE;
    __block NSInteger netAppIncrements = 0;
    NSMutableArray *successfulAppDictionaries = [NSMutableArray new];
    [self detectAppIdsWithIncremental:^(NSArray *appIds) {
        netAppIncrements += 1;
        [self retrieveAppDictionariesForAppIds:appIds
                                   withSuccess:^(NSArray *appDictionaries) {
                                       [successfulAppDictionaries addObjectsFromArray:appDictionaries];
                                       incrementalBlock(appDictionaries);
                                       netAppIncrements -= 1;
                                       /* Unhappy with this implementation */
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC),
                                                      dispatch_get_main_queue(), ^{
                                                          if (appIdDetectionComplete &&
                                                              !netAppIncrements &&
                                                              successBlock &&
                                                              !successBlockExecuted)
                                                          {
                                                              successBlockExecuted = TRUE;
                                                              successBlock(successfulAppDictionaries);
                                                          }
                                                      });
                                   } withFailure:^(NSError *error) {
                                       netAppIncrements -= 1;
                                       /* Unhappy with this implementation */
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC),
                                                      dispatch_get_main_queue(), ^{
                                                          if (appIdDetectionComplete &&
                                                              !netAppIncrements &&
                                                              successBlock &&
                                                              !successBlockExecuted)
                                                          {
                                                              successBlockExecuted = TRUE;
                                                              successBlock(successfulAppDictionaries);
                                                          }
                                                      });
                                   }];
    } withSuccess:^(NSArray *appIds) {
        appIdDetectionComplete = TRUE;
    } withFailure:failureBlock];
}

- (void)retrieveAppDictionariesForAppIds:(NSArray *)appIds
                             withSuccess:(void (^)(NSArray *appDictionaries))successBlock
                             withFailure:(void (^)(NSError *error))failureBlock
{
    dispatch_queue_t retrieval_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(retrieval_thread, ^{
        
        NSString *appString = [appIds componentsJoinedByString:@","];
        NSMutableString *requestUrlString = [NSMutableString new];
        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
        [requestUrlString appendFormat:@"?id=%@", appString];
        [requestUrlString appendFormat:@"&country=%@", self.country];
        
        NSURLResponse *response;
        NSError *connectionError;
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:[NSURL URLWithString:requestUrlString]];
        [request setTimeoutInterval:20.0f];
        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        NSData *result = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&connectionError];
        if (connectionError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock)
                {
                    failureBlock(connectionError);
                }
            });
        }
        else
        {
            NSError *jsonError;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:result
                                                                           options:0
                                                                             error:&jsonError];
            if (jsonError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock)
                    {
                        failureBlock(jsonError);
                    }
                });
            }
            else
            {
                NSArray *results = [jsonDictionary objectForKey:@"results"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock)
                    {
                        successBlock(results);
                    }
                });
            }
        }
    });
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(retrieval_thread);
    #endif
}

#pragma mark - Internal methods

- (void)retrieveSchemeAppsDictionaryWithSuccess:(void (^)(NSDictionary *schemeAppsDictionary))successBlock
                                        failure:(void (^)(NSError *error))failureBlock
{
    [self retrieveSchemeAppsDictionaryFromLocalWithSuccess:successBlock
                                                   failure:^(NSError *error) {
                                                       [self retrieveSchemeAppsDictionaryFromWebWithSuccess:successBlock
                                                                                                    failure:failureBlock];
                                                   }];
}

- (void)retrieveSchemeAppsDictionaryFromLocalWithSuccess:(void (^)(NSDictionary *schemeAppsDictionary))successBlock
                                                 failure:(void (^)(NSError *error))failureBlock
{
    dispatch_queue_t retrieval_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(retrieval_thread, ^{
        
        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        NSString *appSchemesDictionaryPath = [selfBundle pathForResource:@"schemeApps"
                                                                  ofType:@"json"];
        
        NSError *dataError;
        NSData *schemeAppsData = [NSData dataWithContentsOfFile:appSchemesDictionaryPath
                                                        options:0
                                                          error:&dataError];
        if (dataError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock)
                {
                    failureBlock(dataError);
                }
            });
        }
        else
        {
            NSError *jsonError;
            NSDictionary *schemeAppsDictionary = [NSJSONSerialization JSONObjectWithData:schemeAppsData
                                                                                 options:0
                                                                                   error:&jsonError];
            if (jsonError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock)
                    {
                        failureBlock(jsonError);
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock)
                    {
                        successBlock(schemeAppsDictionary);
                    }
                });
            }
        }
    });
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(retrieval_thread);
    #endif
}

- (void)retrieveSchemeAppsDictionaryFromWebWithSuccess:(void (^)(NSDictionary *schemeAppsDictionary))successBlock
                                               failure:(void (^)(NSError *error))failureBlock
{
    dispatch_queue_t retrieval_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(retrieval_thread, ^{
        
        NSURLResponse *response;
        NSError *connectionError;
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*2];
        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [request setURL:[NSURL URLWithString:@"https://ihasapp.herokuapp.com/api/schemeApps.json"]];
        [request setTimeoutInterval:30.0f];
        NSData *result = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&connectionError];
        if (connectionError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock)
                {
                    failureBlock(connectionError);
                }
            });
        }
        else
        {
            NSError *jsonError;
            NSDictionary *schemeAppsDictionary = [NSJSONSerialization JSONObjectWithData:result
                                                                                 options:0
                                                                                   error:&jsonError];
            if (jsonError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock)
                    {
                        failureBlock(jsonError);
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock)
                    {
                        successBlock(schemeAppsDictionary);
                    }
                });
            }
        }
    });
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(retrieval_thread);
    #endif
}


#pragma mark - Helper methods

- (NSArray *)subarraysOfArray:(NSArray *)array withCount:(NSInteger)subarraySize
{
    int j = 0;
    int itemsRemaining = [array count];
    NSMutableArray *arrayOfArrays = [NSMutableArray new];
    while(j < [array count])
    {
        NSRange range = NSMakeRange(j, MIN(subarraySize, itemsRemaining));
        NSArray *subarray = [array subarrayWithRange:range];
        [arrayOfArrays addObject:subarray];
        itemsRemaining -= range.length;
        j += range.length;
    }
    return arrayOfArrays;
}

#pragma mark - Property methods

- (NSString *)country
{
    if (!_country)
    {
        _country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    }
    return _country;
}

@end
