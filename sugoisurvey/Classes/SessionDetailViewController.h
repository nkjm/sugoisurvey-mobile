//
//  SessionDetailViewController.h
//  sugoisurvey
//
//  Created by Kazuki Nakajima on 2013/08/19.
//  Copyright (c) 2013年 Kazuki Nakajima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "SFSmartStore.h"
#import "SFQuerySpec.h"
#import "Tesseract.h"
#import "SVProgressHUD.h"
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>

@class GuestsViewController;

@interface SessionDetailViewController : UITableViewController <SFRestDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ZXingDelegate> {
    
}

@property (nonatomic, strong) GuestsViewController *guestsViewController;
@property (nonatomic, strong) id detailItem;
@property (nonatomic, strong) NSArray *dataRows;

@end



