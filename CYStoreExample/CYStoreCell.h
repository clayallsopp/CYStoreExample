//
//  ISHStoreCell.h
//  IsItHelvetica
//
//  Created by Clay Allsopp on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYStoreCell : UITableViewCell
- (void)setTopText:(NSString *)text;
- (void)setMiddleText:(NSString *)text;
- (void)setMiddleText:(NSString *)text font:(NSString *)font;
- (void)setBottomText:(NSString *)text;
- (void)setImage:(id)image;
- (CGFloat)imageOffset;
- (void)setLabelColors:(UIColor *)color;
- (void)showLabelShadows:(BOOL)show;
- (void)showAccessory:(BOOL)show;
- (void)showAccessoryEnabled:(BOOL)show title:(NSString *)title confirm:(NSString *)confirm;
- (void)reset;
@end
