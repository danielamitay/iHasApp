//
//  MasterViewController.m
//  iHasAppExample
//
//  Created by Daniel Amitay on 10/21/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "UIImageView+WebCache.h"

#import "iHasApp.h"

@interface MasterViewController ()

@property (nonatomic, strong) iHasApp *detectionObject;
@property (nonatomic, strong) NSArray *detectedApps;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Apps";
    self.tableView.rowHeight = 64.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0f, 600.0f);
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(detectApps)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.detectionObject = [[iHasApp alloc] init];
    
    [self detectApps];
}

#pragma mark - iHasApp methods

- (void)detectApps
{
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible)
    {
        return;
    }
    if (self.detailViewController)
    {
        self.detailViewController.appDictionary = nil;
    }
    
    NSLog(@"Detection begun!");
    [self.detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
        NSLog(@"Incremental appDictionaries.count: %i", appDictionaries.count);
        NSMutableArray *newAppDictionaries = [NSMutableArray arrayWithArray:self.detectedApps];
        [newAppDictionaries addObjectsFromArray:appDictionaries];
        self.detectedApps = newAppDictionaries;
        [self.tableView reloadData];
    } withSuccess:^(NSArray *appDictionaries) {
        NSLog(@"Successful appDictionaries.count: %i", appDictionaries.count);
        self.detectedApps = appDictionaries;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.tableView reloadData];
    } withFailure:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        self.detectedApps = [NSArray array];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self.tableView reloadData];
    }];
    
    self.detectedApps = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.tableView reloadData];
}



#pragma mark - Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.detectedApps)
    {
		return [NSString stringWithFormat:@"%i Apps Detected", self.detectedApps.count];
	}
    else
    {
        return @"Detection in progress...";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detectedApps.count;
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
    
    NSDictionary *appDictionary = [self.detectedApps objectAtIndex:indexPath.row];
    
    NSString *trackName = [appDictionary objectForKey:@"trackName"];
    NSString *trackId = [[appDictionary objectForKey:@"trackId"] description];
    //NSString *artworkUrl60 = [appDictionary objectForKey:@"artworkUrl60"];
    
    NSString *iconUrlString = [appDictionary objectForKey:@"artworkUrl512"];
    NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
    NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
    [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
    iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
    
    cell.textLabel.text = trackName;
    cell.detailTextLabel.text = trackId;
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:iconUrlString]
                   placeholderImage:[UIImage imageNamed:@"placeholder-icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *appDictionary = [self.detectedApps objectAtIndex:indexPath.row];
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
