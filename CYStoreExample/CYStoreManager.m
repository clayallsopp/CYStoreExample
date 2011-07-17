//
//  InAppPurchaseManager.m
//  IsItHelvetica
//
//  Created by Clay Allsopp on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CYStoreManager.h"

@implementation CYStoreManager
@synthesize productIds=_productIds;
@synthesize products=_products;

#pragma mark - Object lifecycle

+ (CYStoreManager *)purchaseManager {
    static CYStoreManager *purchaseManager;
    
    @synchronized(self) {
        if (!purchaseManager) {
            purchaseManager = [[CYStoreManager alloc] init];
        }
    }
    
    return purchaseManager;
}

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        self.productIds = nil;
        self.products = nil;
    }
    
    return self;
}

- (void)dealloc {
    [_productIds release];
    [_products release];
    [super dealloc];
}

#pragma mark - Setup methods

- (void)loadStore {
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestProductData];
}

- (void)requestProductData {
    if (!self.productIds) {
        NSLog(@"HEY! You didn't set .productIds for your CYStoreManager!");
        [self request:nil didFailWithError:nil];
        return;
    }
    NSSet *productIdentifiers = [NSSet setWithArray:self.productIds];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark - Public methods

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProduct:(id)productIdOrProduct; {
    NSLog(@"Purchasing %@", productIdOrProduct);
    if ([productIdOrProduct isKindOfClass:[NSString class]]) {
        NSString *productId = (NSString *)productIdOrProduct;
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else if ([productIdOrProduct isKindOfClass:[SKProduct class]]) {
        SKProduct *product = (SKProduct *)productIdOrProduct;
        [self purchaseProduct:product.productIdentifier];
    }
    else {
        [NSException raise:@"InvalidStoreProductException" format:@"purchaseProduct: received neither a string nor an SKProduct"];
    }
}

#pragma mark - Purchase helpers

- (NSArray *)unpurchasedProducts {
    NSMutableArray *unpurchased = [[[NSMutableArray alloc] initWithCapacity:self.products.count] autorelease];
    for (SKProduct *product in self.products) {
        if ([CYStoreManager canPurchaseProduct:product]) {
            [unpurchased addObject:product];
        }
    }
    return (NSArray *)unpurchased;
}

- (NSArray *)purchasedProducts {
    NSMutableArray *purchased = [[[NSMutableArray alloc] initWithCapacity:self.products.count] autorelease];
    for (SKProduct *product in self.products) {
        if (![CYStoreManager canPurchaseProduct:product]) {
            [purchased addObject:product];
        }
    }
    return (NSArray *)purchased;
}

+ (BOOL)canPurchaseProduct:(id)productIdOrProduct {
    if ([productIdOrProduct isKindOfClass:[NSString class]]) {
        NSString *productId = (NSString *)productIdOrProduct;
        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:[CYStoreManager purchasedKey:productId]];
        return !isPurchased;
    }
    else if ([productIdOrProduct isKindOfClass:[SKProduct class]]) {
        SKProduct *product = (SKProduct *)productIdOrProduct;
        return [self canPurchaseProduct:product.productIdentifier];
    }
    [NSException raise:@"InvalidStoreProductException" format:@"canPurchaseProduct received neither a string nor an SKProduct"];
    return NO;
}

+ (NSString *)purchasedKey:(NSString *)pack {
    return [NSString stringWithFormat:@"is%@UpgradePurchased", [pack capitalizedString]];
}

+ (NSString *)purchasedReceiptKey:(NSString *)pack {
    return [NSString stringWithFormat:@"%@TransactionReceipt", pack];
}

#pragma mark - Saving and enabling features

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    NSString *productId = transaction.payment.productIdentifier;
    if ([self.productIds containsObject:productId]) {
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:[CYStoreManager purchasedReceiptKey:productId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId {
    if ([self.productIds containsObject:productId]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[CYStoreManager purchasedKey:productId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - SKPaymentTransactionObserver Helper Methods

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        NSLog(@"%@", [transaction.error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"There was an error, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark - SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (!self.products) {
        NSMutableArray *p = [[NSMutableArray alloc] init];
        self.products = p;
        [p release];
    }
    [self.products addObjectsFromArray:response.products];
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [_productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Product request failed :(");
    _failed = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

- (BOOL)failed {
    return _failed;
}

#pragma mark - ISHStoreDelegate Methods

- (int)numberOfStoreItemsForStoreController:(CYStoreController *)store {
    return [[self unpurchasedProducts] count];
}

- (int)numberOfInstalledItemsForStoreController:(CYStoreController *)store {
    return [[self purchasedProducts] count];
}

- (NSDictionary *)storeController:(CYStoreController *)store dataForStoreItemAtIndex:(int)index {
    SKProduct *product = [[self unpurchasedProducts] objectAtIndex:index];
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:product.priceLocale];
    NSString *currencyString = [formatter stringFromNumber:product.price];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Tap for description", @"topText",
            product.localizedTitle,@"middleText",
            currencyString, @"price", 
            product.localizedDescription, @"description",
            [UIImage imageNamed:@"icon_font"], @"image",
            nil];
}

- (NSDictionary *)storeController:(CYStoreController *)store dataForInstalledItemAtIndex:(int)index {
    NSLog(@"%@",[self purchasedProducts]);
    SKProduct *product = [[self purchasedProducts] objectAtIndex:index];

    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Tap for description", @"topText",
            product.localizedTitle,@"middleText",
            product.localizedDescription, @"description",
            [UIImage imageNamed:@"icon_font"], @"image",
            nil];
}
- (void)storeController:(CYStoreController *)store purchaseItemAtIndex:(int)index {
    if ([self canMakePurchases]) {
        [self purchaseProduct:[[self unpurchasedProducts] objectAtIndex:index]];
    }
}

- (void)storeController:(CYStoreController *)store storeItemTappedAtIndex:(int)index {
    NSDictionary *data = [self storeController:store dataForStoreItemAtIndex:index];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[data objectForKey:@"middleText"] message:[data objectForKey:@"description"] delegate:nil cancelButtonTitle:@"OK, cool" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)storeController:(CYStoreController *)store installedItemTappedAtIndex:(int)index {
    NSDictionary *data = [self storeController:store dataForInstalledItemAtIndex:index];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[data objectForKey:@"middleText"] message:[data objectForKey:@"description"] delegate:nil cancelButtonTitle:@"OK, cool" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
