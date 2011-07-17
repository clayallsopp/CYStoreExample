//
//  InAppPurchaseManager.h
//  IsItHelvetica
//
//  Created by Clay Allsopp on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CYConstants.h"
#import "CYStoreController.h"

@interface CYStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, CYStoreDelegate> {
    NSArray *_productIds;
    NSMutableArray *_products;
    SKProductsRequest *_productsRequest;
    BOOL _failed;
}
@property (nonatomic, retain) NSArray *productIds;
@property (nonatomic, retain) NSMutableArray *products;

+ (CYStoreManager *)purchaseManager;
- (void)loadStore;
- (void)requestProductData;

- (BOOL)canMakePurchases;
+ (BOOL)canPurchaseProduct:(id)productIdOrProduct;

- (NSArray *)unpurchasedProducts;
- (NSArray *)purchasedProducts;
+ (NSString *)purchasedKey:(NSString *)productId;
+ (NSString *)purchasedReceiptKey:(NSString *)productId;
- (BOOL)failed;
@end