//
//  DetailViewController.h
//  iHasAppExample
//
//  Created by Daniel Amitay on 10/21/12.
//  Copyright (c) 2012 Objective-See. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *appDictionary;

@end
