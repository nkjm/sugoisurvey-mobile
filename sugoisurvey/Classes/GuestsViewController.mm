//
//  GuestsViewController.m
//  sugoisurvey1
//
//  Created by Kazuki Nakajima on 2013/08/14.
//  Copyright (c) 2013年 Kazuki Nakajima. All rights reserved.
//

#import "GuestsViewController.h"


@implementation GuestsViewController

@synthesize guests;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ゲスト";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(retrieve_guests) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Salesforce REST
- (void)retrieve_guests
{
    NSString *query = [NSString stringWithFormat:@"SELECT Id, sugoisurvey4__Email__c, sugoisurvey4__Name__c, sugoisurvey4__Status__c, sugoisurvey4__Checkin__c, sugoisurvey4__Session__c FROM sugoisurvey4__Guest__c WHERE sugoisurvey4__Session__c = '%@' ORDER BY Name DESC", [self.detailItem objectForKey:@"Id"]];
    NSLog(@"%@", [NSString stringWithFormat:@"query: %@", query]);
    
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    NSArray *records = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    
    SFSmartStore *store = [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
    BOOL exists = [store soupExists:@"Guest"];
    
    if (!exists){
        NSLog(@"Soup does not exist!");
        return;
    }
    
    // Delete all guests in "Guest" soup.
    NSMutableArray *soupEntryIdsToDelete = [[NSMutableArray alloc] init];
    for (NSDictionary *guest in self.guests){
        //[soupEntryIdsToDelete addObject:[NSNumber numberWithInteger:[[guest objectForKey:@"_soupEntryId"] integerValue]]];
        [soupEntryIdsToDelete addObject:[guest objectForKey:@"_soupEntryId"]];
    }
    if ([soupEntryIdsToDelete count] > 0){
        [store removeEntries:soupEntryIdsToDelete fromSoup:@"Guest"];
    }
    
    // Store data into "Guest" soup.
    NSError *err = nil;
    [store upsertEntries:records toSoup:@"Guest" withExternalIdPath:@"Id" error:&err];
    
    // refresh guests property
    [self refresh_guests];
    
    [self update_no_guests];
    
}

- (void)update_no_guests
{
    int no_attending_guests = 0;
    int no_guests = 0;
    for (NSDictionary *guest in self.guests){
        if ([[guest objectForKey:@"sugoisurvey4__Checkin__c"] boolValue]){
            no_attending_guests++;
        }
        no_guests++;
    }
    [self.detailItem setObject:[NSNumber numberWithInt:no_attending_guests] forKey:@"sugoisurvey4__Attending_Guest_Sum__c"];
    [self.detailItem setObject:[NSNumber numberWithInt:no_guests] forKey:@"sugoisurvey4__Guest_Sum__c"];
}

#pragma mark - SmartStore
- (void)refresh_guests
{
    SFSmartStore *store = [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
    BOOL exists = [store soupExists:@"Guest"];
    if (exists){
        SFQuerySpec *querySpec = [SFQuerySpec newExactQuerySpec:@"Guest" withPath:@"sugoisurvey4__Session__c" withMatchKey:[self.detailItem objectForKey:@"Id"] withOrder:kSFSoupQuerySortOrderAscending withPageSize:1000];
        self.guests = [store queryWithQuerySpec:querySpec pageIndex:0];
        NSLog(@"#Guests: %d", self.guests.count);
    }
    
    if (self.tableView){
        [self.tableView reloadData];
    }
    
    if (self.refreshControl){
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.guests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell to show the data.
	NSDictionary *guest = [self.guests objectAtIndex:indexPath.row];
    if ([[guest objectForKey:@"sugoisurvey4__Name__c"] isKindOfClass:[NSString class]]){
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [guest objectForKey:@"sugoisurvey4__Name__c"]];
    } else {
        cell.textLabel.text = @"未設定";
    }
    if ([[guest objectForKey:@"sugoisurvey4__Email__c"] isKindOfClass:[NSString class]]){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [guest objectForKey:@"sugoisurvey4__Email__c"]];
    } else {
        cell.detailTextLabel.text = @"未設定";
    }
    
	//this adds the checkmark if guest has already been checked-in.
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[guest objectForKey:@"sugoisurvey4__Checkin__c"] boolValue]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    /*
     if ([@"attendded" isEqualToString:[NSString stringWithFormat:@"%@", [guest objectForKey:@"sugoisurvey4__Status__c"]]] || [@"submitted" isEqualToString:[NSString stringWithFormat:@"%@", [guest objectForKey:@"sugoisurvey4__Status__c"]]]){
     cell.accessoryType = UITableViewCellAccessoryCheckmark;
     }
     */
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
