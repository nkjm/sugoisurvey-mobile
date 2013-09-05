//
//  SessionDetailViewController.m
//  sugoisurvey
//
//  Created by Kazuki Nakajima on 2013/08/19.
//  Copyright (c) 2013年 Kazuki Nakajima. All rights reserved.
//

#import "SessionDetailViewController.h"
#import "GuestsViewController.h"


@interface SessionDetailViewController ()

@end

@implementation SessionDetailViewController

@synthesize dataRows;

UIActivityIndicatorView *indicator;

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        self.title = [NSString stringWithFormat:@"%@", [self.detailItem objectForKey:@"Name"]];
        
        // create guestViewControllerInstance
        if (!self.guestsViewController) {
            //self.guestsViewController = [[GuestsViewController alloc] initWithNibName:@"GuestsViewController" bundle:nil];
            self.guestsViewController = [[GuestsViewController alloc] initWithNibName:nil bundle:nil];
        }
        self.guestsViewController.detailItem = self.detailItem;
        
        // Retrieve Guests from local database
        [self.guestsViewController refresh_guests];
        
        // Retrieve Guests from Salesforce if the number of guests is different between local and salesforce.
        NSInteger guests_sum_local = [self.guestsViewController.guests count];
        NSInteger guests_sum_cloud = [[self.detailItem objectForKey:@"sugoisurvey4__Guest_Sum__c"] integerValue];
        if (guests_sum_local != guests_sum_cloud){
            [self.guestsViewController retrieve_guests];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger no_rows;
    switch (section){
        case 0:
            no_rows = 3;
            break;
        case 1:
            no_rows = 2;
            break;
    }
    return no_rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.section == 0){
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        }
        switch (indexPath.row){
            case 0:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text =  @"イベント";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.detailItem objectForKey:@"Name"]];
                break;
            case 1:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text =  @"開催日";
                if ([[self.detailItem objectForKey:@"sugoisurvey4__Date__c"] isKindOfClass:[NSString class]]){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.detailItem objectForKey:@"sugoisurvey4__Date__c"]];
                } else {
                    cell.detailTextLabel.text = @"未設定";
                }
                break;
            case 2:
                cell.textLabel.text =  @"ゲスト";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@ (出席/登録)", [self.detailItem objectForKey:@"sugoisurvey4__Attending_Guest_Sum__c"], [self.detailItem objectForKey:@"sugoisurvey4__Guest_Sum__c"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
        }
    } else if (indexPath.section == 1){
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        switch (indexPath.row){
            case 0:
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text =  @"QRコードをスキャン";
                break;
            case 1:
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text =  @"名刺をスキャン";
                break;
        }
    }
    
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
    if (indexPath.section == 0 && indexPath.row == 2){
        self.guestsViewController.detailItem = self.detailItem;
        [self.navigationController pushViewController:self.guestsViewController animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0){
        // create instance for QR-code scanner
        ZXingWidgetController *zxingWidgetController = [[ZXingWidgetController alloc]
                                                        initWithDelegate:self
                                                        showCancel:YES
                                                        OneDMode:NO];
        QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
        zxingWidgetController.readers = [[NSSet alloc] initWithObjects:qrcodeReader, nil];
        
        // show QR-code scanner
        [self presentViewController:zxingWidgetController animated:NO completion:nil];
    }
    
    if (indexPath.section == 1 && indexPath.row == 1){
        [self showUIImagePicker];
    }
}

#pragma mark - QR-Code Scanner

- (void)zxingController:(ZXingWidgetController*)controller
          didScanResult:(NSString *)result
{
    // close scanner
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // do something
    NSLog(@"%@", result);
    if ([self isRegistered:result]){
        [SVProgressHUD showSuccessWithStatus:@"チェックイン完了"];
        [self.tableView reloadData];
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@は未登録です", result]];
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    // close scanner
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Bcard Scanner

- (void)showUIImagePicker
{
    // カメラが使用可能かどうか判定する
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    // UIImagePickerControllerのインスタンスを生成
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    // デリゲートを設定
    imagePickerController.delegate = self;
    
    // 画像の取得先をカメラに設定
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // 画像取得後に編集するかどうか（デフォルトはNO）
    imagePickerController.allowsEditing = YES;
    
    // 撮影画面をモーダルビューとして表示する
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

// 画像が選択された時に呼ばれるデリゲートメソッド
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    // close modal view
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // do scan with Tesseract
    [self tess_scan:image];
}

// 画像の選択がキャンセルされた時に呼ばれるデリゲートメソッド
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // close modal view
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 画像の保存完了時に呼ばれるメソッド
- (void)targetImage:(UIImage *)image
didFinishSavingWithError:(NSError *)error
        contextInfo:(void *)context
{
    if (error) {
        // 保存失敗時の処理
    } else {
        // 保存成功時の処理
    }
}


- (void)tess_scan:(UIImage *)img
{
    [SVProgressHUD showWithStatus:@"スキャン中..." maskType:SVProgressHUDMaskTypeBlack];
    NSLog(@"Entered tess_scan");
    
    // set lang
    Tesseract *tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    
    // set option
    
    if (img){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // set image
            [tesseract setImage:img];
            
            // do scan
            [tesseract recognize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                NSString *multiLineString = [tesseract recognizedText];
                NSString *line;
                NSRange range, subRange;
                
                // 最初に文字列全範囲を示すRangeを作成する
                range = NSMakeRange(0, multiLineString.length);
                
                // １行ずつ読み出す
                while (range.length > 0) {
                    // １行分を示すRangeを取得します。
                    subRange = [multiLineString lineRangeForRange:NSMakeRange(range.location, 0)];
                    // 1行分を示すRangeを用いて、文字列から１行抜き出す
                    line = [multiLineString substringWithRange:subRange];
                    NSLog(@"line = %@", line);
                    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ MATCHES '^[0-9a-zA-Z_+-.|:= ]+@[0-9a-zA-Z_-|]+.[0-9a-zA-Z_.-|]+\\n$'", line];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ MATCHES '.+@.+'", line];
                    BOOL matched = [predicate evaluateWithObject:nil];
                    if (matched){
                        line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@"|" withString:@"l"];
                        line = [line stringByReplacingOccurrencesOfString:@"I" withString:@"l"];
                        line = [line lowercaseString];
                        line = [line stringByReplacingOccurrencesOfString:@"email" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@"e-mail" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@"mail" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@":" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@"=" withString:@""];
                        line = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        NSLog(@"%@", [NSString stringWithFormat:@"Corrected line: %@", line]);
                        
                        // Check if this email has been registered as guest
                        if ([self isRegistered:line]){
                            [SVProgressHUD showSuccessWithStatus:@"チェックイン完了"];
                            [self.tableView reloadData];
                        } else {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@は未登録です", line]];
                        }
                        return;
                    }
                    
                    // 1行分を示すRangeの最終位置を、
                    // 次の探索に使うRangeの最初として設定する
                    range.location = NSMaxRange(subRange);
                    // 文字列の終端を、次の探索に使うRangeの最終位置に登録します
                    range.length -= subRange.length;
                }
                
                [SVProgressHUD showErrorWithStatus:@"Emailが検出できませんでした"];
            });
        });
    }
}

- (Boolean)isRegistered:(NSString *)key_for_guest
{
    if (self.guestsViewController.guests){
        for (NSMutableDictionary *guest in self.guestsViewController.guests){
            Boolean match = NO;
            
            if ([key_for_guest isEqualToString:[NSString stringWithFormat:@"%@", [guest objectForKey:@"Id"]]]){
                match = YES;
            } else if ([key_for_guest isEqualToString:[NSString stringWithFormat:@"%@", [guest objectForKey:@"sugoisurvey4__Email__c"]]]){
                match = YES;
            }
            
            if (match){
                NSLog(@"%@", [NSString stringWithFormat:@"Registered Guest: %@", [guest objectForKey:@"sugoisurvey4__Name__c"]]);
                
                Boolean checkin = YES;
                [guest setObject:@"attended" forKey:@"sugoisurvey4__Status__c"];
                [guest setObject:[NSNumber numberWithBool:checkin] forKey:@"sugoisurvey4__Checkin__c"];
                
                // update local database
                SFSmartStore *store = [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
                [store upsertEntries:self.guestsViewController.guests toSoup:@"Guest"];
                
                // update no_attending_guests
                [self.guestsViewController update_no_guests];
                
                // update salesforce database
                NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:@"attended", @"sugoisurvey4__Status__c", nil];
                SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpsertWithObjectType:@"sugoisurvey4__Guest__c" externalIdField:@"Id" externalId:[guest objectForKey:@"Id"] fields:fields];
                [[SFRestAPI sharedInstance] send:request delegate:self];
                return true;
            }
        }
    }
    return false;
}

@end
