/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"
#import "SessionDetailViewController.h"

@implementation RootViewController

@synthesize dataRows;

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"イベント";
    
    // retrieve survey list from salesforce.
    [self retrieve_sessions];
    
    // create smartstore database if it does not exist.
    [self create_soup:@"Guest"];
    
    // pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(retrieve_sessions) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

#pragma mark - Salesforce REST
- (void)retrieve_sessions
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Id, Name, sugoisurvey4__Open__c, sugoisurvey4__Date__c, sugoisurvey4__Guest_Sum__c, sugoisurvey4__Attending_Guest_Sum__c, sugoisurvey4__Presenter__r.Name, sugoisurvey4__Presenter__r.sugoisurvey4__Title__c, sugoisurvey4__Presenter__r.sugoisurvey4__Company__c FROM sugoisurvey4__Session__c ORDER BY sugoisurvey4__Date__c DESC, CreatedDate DESC"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    NSArray *records = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    self.dataRows = records;
    [self.tableView reloadData];
    if (self.refreshControl){
        [self.refreshControl endRefreshing];
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    
	// Configure the cell to show the data.
	NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
	cell.textLabel.text =  [obj objectForKey:@"Name"];
    
	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.sessionDetailViewController) {
        //self.sessionDetailViewController = [[SessionDetailViewController alloc] initWithNibName:@"SessionDetailViewController" bundle:nil];
        self.sessionDetailViewController = [[SessionDetailViewController alloc] initWithNibName:nil bundle:nil];
    }
    NSDictionary *object = [dataRows objectAtIndex:indexPath.row];
    self.sessionDetailViewController.detailItem = object;
    [self.navigationController pushViewController:self.sessionDetailViewController animated:YES];
}

#pragma mark - SmartStore
- (void)create_soup:(NSString *)soup_name
{
    SFSmartStore *store = [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
    
    //[store removeAllSoups];
    
    BOOL exists = [store soupExists:soup_name];
    if (exists){
        return;
    }
    
    NSLog(@"Going to create a new soup...");
    
    NSMutableDictionary *col_id = [[NSMutableDictionary alloc] init];
    [col_id setObject:@"Id" forKey:@"path"];
    [col_id setObject:@"string" forKey:@"type"];
    
    NSMutableDictionary *col_session__c = [[NSMutableDictionary alloc] init];
    [col_session__c setObject:@"sugoisurvey4__Session__c" forKey:@"path"];
    [col_session__c setObject:@"string" forKey:@"type"];
    
    NSMutableDictionary *col_email__c = [[NSMutableDictionary alloc] init];
    [col_email__c setObject:@"sugoisurvey4__Email__c" forKey:@"path"];
    [col_email__c setObject:@"string" forKey:@"type"];
    
    [store registerSoup:soup_name withIndexSpecs:[NSArray arrayWithObjects:col_id, col_session__c, col_email__c, nil]];
}

@end
