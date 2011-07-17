//
//  CYStoreController.h
//  IsItHelvetica
//
//  Created by Clay Allsopp on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYStoreController;

@protocol CYStoreDelegate <NSObject>
- (int)numberOfStoreItemsForStoreController:(CYStoreController *)store;
- (int)numberOfInstalledItemsForStoreController:(CYStoreController *)store;
- (NSDictionary *)storeController:(CYStoreController *)store dataForStoreItemAtIndex:(int)index;
- (NSDictionary *)storeController:(CYStoreController *)store dataForInstalledItemAtIndex:(int)index;
- (void)storeController:(CYStoreController *)store purchaseItemAtIndex:(int)index;
@optional
- (void)storeController:(CYStoreController *)store storeItemTappedAtIndex:(int)index;
- (void)storeController:(CYStoreController *)store installedItemTappedAtIndex:(int)index;
@end

@interface CYStoreController : UITableViewController {
    id<CYStoreDelegate> _storeDelegate;
    NSString *_storeTitle;
}
@property (nonatomic, assign) id<CYStoreDelegate> storeDelegate;
@property (nonatomic, retain) NSString *storeTitle;
- (void)close:(id)sender;
@end

