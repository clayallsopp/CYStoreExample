//
//  CYStoreController.m
//
//  Created by Clay Allsopp on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CYStoreController.h"
#import "CYStoreCell.h"
#import "CYStoreManager.h"

#import "UIColor+HexString.h"

@implementation CYStoreController
@synthesize storeDelegate=_storeDelegate;
@synthesize storeTitle=_storeTitle;

- (void)dealloc {
    [_storeTitle release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.storeTitle = (self.storeTitle) ? self.storeTitle : @"Store";
    self.title = self.storeTitle;
    
    self.tableView.rowHeight = 74.0f;
    self.tableView.separatorColor = [UIColor colorWithHexString:@"adadb0"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"86868a"];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = left;
    [left release];
    
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchased:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (id<CYStoreDelegate>)storeDelegate {
    if (!_storeDelegate) {
        return [CYStoreManager purchaseManager];
    }
    return _storeDelegate;
}


#pragma  mark - callbacks

- (void)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)storeReady:(NSNotification *)event {
    [self.tableView reloadData];
}

- (void)purchased:(NSNotification *)event {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return ([[CYStoreManager purchaseManager] failed]) ? @"Store (connection failed)" : @"Store";
    return @"Installed";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return [self.storeDelegate numberOfStoreItemsForStoreController:self];
    return [self.storeDelegate numberOfInstalledItemsForStoreController:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    CYStoreCell *cell = (CYStoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CYStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row % 2 != 0) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"store_even_row"]]];
        [cell setBackgroundColor:cell.contentView.backgroundColor];
    }
    else {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"store_odd_row"]]];
        [cell setBackgroundColor:cell.contentView.backgroundColor];
    }
    [cell reset];
    
    NSDictionary *data;
    if (indexPath.section == 0) {
        data = [self.storeDelegate storeController:self dataForStoreItemAtIndex:indexPath.row];
        
        [cell showAccessory:YES];
        NSString *price = [NSString stringWithFormat:@"%@", [data objectForKey:@"price"]];
        [cell showAccessoryEnabled:NO title:price confirm:@"Purchase"];
        [cell setMiddleText:[data objectForKey:@"middleText"] font:@"Helvetica-Bold"];
    }
    else {
        data = [self.storeDelegate storeController:self dataForInstalledItemAtIndex:indexPath.row];
        [cell showAccessory:NO];
    }
    if ([data objectForKey:@"topText"]) [cell setTopText:[data objectForKey:@"topText"]];
    if ([data objectForKey:@"bottomText"]) [cell setBottomText:[data objectForKey:@"bottomText"]];
    if ([data objectForKey:@"image"]) [cell setImage:[data objectForKey:@"image"]];
    if ([data objectForKey:@"middleText"]) {
        if ([data objectForKey:@"font"]) [cell setMiddleText:[data objectForKey:@"middleText"] font:[data objectForKey:@"font"]];
        else [cell setMiddleText:[data objectForKey:@"middleText"]];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 != 0) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"store_even_row"]]];
        [cell setBackgroundColor:cell.contentView.backgroundColor];
    }
    else {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"store_odd_row"]]];
        [cell setBackgroundColor:cell.contentView.backgroundColor];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([self.storeDelegate respondsToSelector:@selector(storeController:storeItemTappedAtIndex:)]) {
            [self.storeDelegate storeController:self storeItemTappedAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 1) {
        if ([self.storeDelegate respondsToSelector:@selector(storeController:installedItemTappedAtIndex:)]) {
            [self.storeDelegate storeController:self installedItemTappedAtIndex:indexPath.row];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.storeDelegate storeController:self purchaseItemAtIndex:indexPath.row];
    }
}

@end
