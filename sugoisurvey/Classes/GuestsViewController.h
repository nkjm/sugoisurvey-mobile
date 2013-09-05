//
//  GuestsViewController.h
//  sugoisurvey1
//
//  Created by Kazuki Nakajima on 2013/08/14.
//  Copyright (c) 2013年 Kazuki Nakajima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "SFSmartStore.h"
#import "SFQuerySpec.h"

@interface GuestsViewController : UITableViewController <SFRestDelegate>

@property (nonatomic, strong) id detailItem;
@property (nonatomic, strong) NSArray *guests;

-(void)refresh_guests;
-(void)retrieve_guests;
-(void)update_no_guests;

@end
