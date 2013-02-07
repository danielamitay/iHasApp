//
//  DetailViewController.m
//  iHasAppExample
//
//  Created by Daniel Amitay on 10/21/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize appDictionary = _appDictionary;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setAppDictionary:(NSDictionary *)appDictionary
{
    if (_appDictionary != appDictionary)
    {
        _appDictionary = appDictionary;
        
        [self configureView];
    }
    
    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    [self.tableView reloadData];
    if (self.appDictionary)
    {
        self.title = [self.appDictionary objectForKey:@"trackName"];
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else
    {
        self.title = nil;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureView];
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Apps";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.appDictionary)
    {
		return @"Key-value pairs";
	}
    else
    {
        return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appDictionary.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *key = [self.appDictionary.allKeys objectAtIndex:indexPath.row];
    NSString *value = [[self.appDictionary objectForKey:key] description];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.appDictionary.allKeys objectAtIndex:indexPath.row];
    NSString *value = [[self.appDictionary objectForKey:key] description];
    
    CGSize maxSize = CGSizeMake(self.view.bounds.size.width - 20.0f, CGFLOAT_MAX);
    CGSize labelSize = [value sizeWithFont:[UIFont systemFontOfSize:14.0f]
                         constrainedToSize:maxSize
                             lineBreakMode:NSLineBreakByTruncatingTail];
    
    return (labelSize.height + 30.0f);
}

@end
