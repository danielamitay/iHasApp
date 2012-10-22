//
//  MasterViewController.h
//  iHasAppExample
//
//  Created by Daniel Amitay on 10/21/12.
//  Copyright (c) 2012 Objective-See. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
