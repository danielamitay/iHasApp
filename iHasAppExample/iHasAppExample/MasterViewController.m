//
//  MasterViewController.m
//  iHasAppExample
//
//  Created by Daniel Amitay on 6/21/12.
//  Copyright (c) 2012 Objective-See, LLC. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "UIImageView+WebCache.h"

#import <iHasApp/iHasApp.h>

@interface MasterViewController () <iHasAppDelegate>
{
    iHasApp *appEngine;
    NSArray *detectedApps;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
					
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Apps";
    self.tableView.rowHeight = 57.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0f, 600.0f);
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(detectApps)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    #warning Replace YOUR-API-KEY accordingly
    appEngine = [[iHasApp alloc] initWithDelegate:self andKey:@"YOUR-API-KEY"];
    appEngine.country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    [self detectApps];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - iHasApp methods

- (void)detectApps
{
    if (self.detailViewController)
    {
        self.detailViewController.appDictionary = nil;
    }
    [appEngine beginDetection];
    NSLog(@"appDetectionDidBegin");
    detectedApps = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.tableView reloadData];
}

- (void)appDetectionDidSucceed:(NSArray *)appsDetected
{
    NSLog(@"appDetectionDidSucceed:");
    detectedApps = appsDetected;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
}

- (void)appDetectionDidFail:(iHasAppError)detectionError
{
    NSLog(@"appDetectionDidFail:");
    detectedApps = [NSArray array];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *error;
    switch (detectionError)
    {
        case iHasAppErrorUnknown:
            error = @"iHasAppError: Unknown";
            break;
        case iHasAppErrorConnection:
            error = @"iHasAppError: Connection";
            break;
        case iHasAppErrorInvalidKey:
            error = @"iHasAppError: InvalidKey";
            break;
        case iHasAppErrorReachedLimit:
            error = @"iHasAppError: ReachedLimit";
            break;
            
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(detectedApps)
    {
		return [NSString stringWithFormat:@"%i Apps Detected", [[appEngine detectedApps] count]];
	}
    else
    {
        return @"Detection in progress...";	
	}	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return detectedApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    NSDictionary *appDictionary = [detectedApps objectAtIndex:indexPath.row];
    
    NSString *trackName = [appDictionary objectForKey:@"trackName"];
    NSString *trackId = [[appDictionary objectForKey:@"trackId"] description];
    NSString *artworkUrl60 = [appDictionary objectForKey:@"artworkUrl60"];
    
    cell.textLabel.text = trackName;
    cell.detailTextLabel.text = trackId;
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:artworkUrl60]
                   placeholderImage:[UIImage imageNamed:@"placeholder-icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *appDictionary = [detectedApps objectAtIndex:indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
	    if (!self.detailViewController)
        {
	        self.detailViewController = [[DetailViewController alloc] init];
	    }
	    self.detailViewController.appDictionary = appDictionary;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
	    self.detailViewController.appDictionary = appDictionary;
    }
}

@end
