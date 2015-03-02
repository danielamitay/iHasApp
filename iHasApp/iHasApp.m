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
                        withFailure:(void (^)(NSError *error))failureBlock {
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        [self retrieveSchemeAppsDictionaryWithSuccess:^(NSDictionary *schemeAppsDictionary) {
            NSMutableArray *schemeDictionaries = [[NSMutableArray alloc] init];
            for (NSString *scheme in schemeAppsDictionary.allKeys) {
                NSArray *appIds = [schemeAppsDictionary objectForKey:scheme];
                NSDictionary *schemeDictionary = @{
                    @"scheme": scheme,
                    @"ids": appIds
                };
                [schemeDictionaries addObject:schemeDictionary];
            }
            UIApplication *application = [UIApplication sharedApplication];
            NSMutableSet *successfulAppIds = [[NSMutableSet alloc] init];
            NSArray *arrayOfArrays =  [self subarraysOfArray:schemeDictionaries withCount:1000];
            for (NSArray *schemeDictionariesArray in arrayOfArrays) {
                NSMutableSet *incrementalAppIds = [[NSMutableSet alloc] init];
                for (NSDictionary *schemeDictionary in schemeDictionariesArray) {
                    NSString *scheme = [schemeDictionary objectForKey:@"scheme"];
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]];
                    if ([application canOpenURL:url]) {
                        NSArray *appIds = [schemeDictionary objectForKey:@"ids"];
                        for (NSString *appId in appIds) {
                            if (![successfulAppIds containsObject:appId]) {
                                [successfulAppIds addObject:appId];
                                [incrementalAppIds addObject:appId];
                            }
                        }
                    }
                }
                if (incrementalBlock && incrementalAppIds.count) {
                    [currentQueue addOperationWithBlock:^{
                        incrementalBlock(incrementalAppIds.allObjects);
                    }];
                }
            }
            if (successBlock) {
                [currentQueue addOperationWithBlock:^{
                    successBlock(successfulAppIds.allObjects);
                }];
            }
        } failure:failureBlock];
    }];
}

- (void)detectAppDictionariesWithIncremental:(void (^)(NSArray *appDictionaries))incrementalBlock
                                 withSuccess:(void (^)(NSArray *appDictionaries))successBlock
                                 withFailure:(void (^)(NSError *error))failureBlock {
    __block BOOL appIdDetectionComplete = NO;
    __block BOOL successBlockExecuted = NO;
    __block NSInteger expectedIncrementalResults = 0;
    NSMutableArray *successfulAppDictionariesArrays = [[NSMutableArray alloc] init];
    void (^evaluateCompletionState)() = ^void {
        if (expectedIncrementalResults == 0 && appIdDetectionComplete && !successBlockExecuted) {
            successBlockExecuted = YES;
            NSMutableSet *successfulAppDictionariesSet = [[NSMutableSet alloc] init];
            for (NSArray *successfulAppDictionaries in successfulAppDictionariesArrays) {
                [successfulAppDictionariesSet addObjectsFromArray:successfulAppDictionaries];
            }
            if (successBlock) {
                successBlock(successfulAppDictionariesSet.allObjects);
            }
        }
    };
    [self detectAppIdsWithIncremental:^(NSArray *appIds) {
        expectedIncrementalResults++;
        [self retrieveAppDictionariesForAppIds:appIds
                                   withSuccess:^(NSArray *appDictionaries) {
                                       expectedIncrementalResults--;
                                       if (incrementalBlock) {
                                           incrementalBlock(appDictionaries);
                                       }
                                       if (appDictionaries) {
                                           [successfulAppDictionariesArrays addObject:appDictionaries];
                                       }
                                       evaluateCompletionState();
                                   } withFailure:^(NSError *error) {
                                       expectedIncrementalResults--;
                                       evaluateCompletionState();
                                   }];
    } withSuccess:^(NSArray *appIds) {
        appIdDetectionComplete = YES;
        evaluateCompletionState();
    } withFailure:failureBlock];
}

- (void)retrieveAppDictionariesForAppIds:(NSArray *)appIds
                             withSuccess:(void (^)(NSArray *appDictionaries))successBlock
                             withFailure:(void (^)(NSError *error))failureBlock {
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        NSString *appString = [appIds componentsJoinedByString:@","];
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
        [requestUrlString appendFormat:@"?id=%@", appString];
        if (self.country) {
            [requestUrlString appendFormat:@"&country=%@", self.country];
        }
        
        NSURLResponse *response = nil;
        NSError *connectionError = nil;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:requestUrlString]];
        [request setTimeoutInterval:20.0f];
        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        NSData *result = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&connectionError];
        if (connectionError && failureBlock) {
            [currentQueue addOperationWithBlock:^{
                failureBlock(connectionError);
            }];
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:result
                                                                           options:NSJSONReadingMutableLeaves
                                                                             error:&jsonError];
            if (jsonError && failureBlock) {
                [currentQueue addOperationWithBlock:^{
                    failureBlock(jsonError);
                }];
            } else if (successBlock) {
                NSArray *results = [jsonDictionary objectForKey:@"results"];
                [currentQueue addOperationWithBlock:^{
                    successBlock(results);
                }];
            }
        }
    }];
}


#pragma mark - Internal methods

- (void)retrieveSchemeAppsDictionaryWithSuccess:(void (^)(NSDictionary *schemeAppsDictionary))successBlock
                                        failure:(void (^)(NSError *error))failureBlock {
    [self retrieveSchemeAppsDictionaryFromLocalWithSuccess:successBlock failure:failureBlock];
}

- (void)retrieveSchemeAppsDictionaryFromLocalWithSuccess:(void (^)(NSDictionary *schemeAppsDictionary))successBlock
                                                 failure:(void (^)(NSError *error))failureBlock {
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        NSString *appSchemesDictionaryPath = [selfBundle pathForResource:@"schemeApps" ofType:@"json"];
        if (!appSchemesDictionaryPath && failureBlock) {
            [currentQueue addOperationWithBlock:^{
                failureBlock(nil);
            }];
        } else {
            NSError *dataError = nil;
            NSData *schemeAppsData = [NSData dataWithContentsOfFile:appSchemesDictionaryPath
                                                            options:NSDataReadingMappedIfSafe
                                                              error:&dataError];
            if (dataError && failureBlock) {
                [currentQueue addOperationWithBlock:^{
                    failureBlock(dataError);
                }];
            } else {
                NSError *jsonError = nil;
                NSDictionary *schemeAppsDictionary = [NSJSONSerialization JSONObjectWithData:schemeAppsData
                                                                                     options:NSJSONReadingMutableLeaves
                                                                                       error:&jsonError];
                if (jsonError && failureBlock) {
                    [currentQueue addOperationWithBlock:^{
                        failureBlock(jsonError);
                    }];
                } else if (successBlock) {
                    [currentQueue addOperationWithBlock:^{
                        successBlock(schemeAppsDictionary);
                    }];
                }
            }
        }
    }];
}


#pragma mark - Helper methods

- (NSArray *)subarraysOfArray:(NSArray *)array withCount:(NSInteger)subarraySize {
    NSInteger rangeLocation = 0;
    NSInteger arrayCount = [array count];
    NSInteger itemsRemaining = [array count];
    NSMutableArray *arrayOfArrays = [[NSMutableArray alloc] init];
    while(rangeLocation < arrayCount) {
        NSInteger rangeLength = MIN(subarraySize, itemsRemaining);
        NSRange range = NSMakeRange(rangeLocation, rangeLength);
        NSArray *subarray = [array subarrayWithRange:range];
        [arrayOfArrays addObject:subarray];
        itemsRemaining -= rangeLength;
        rangeLocation += rangeLength;
    }
    return arrayOfArrays;
}


#pragma mark - Property methods

- (NSString *)country {
    if (!_country) {
        _country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    }
    return _country;
}

@end
