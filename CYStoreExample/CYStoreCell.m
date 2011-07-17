//
//  ISHStoreCell.m
//  IsItHelvetica
//
//  Created by Clay Allsopp on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CYStoreCell.h"

#import "UIColor+HexString.h"
#import "MAConfirmButton.h"
#import <QuartzCore/QuartzCore.h>

#define TAG_TopLabel 500
#define TAG_MiddleLabel 501
#define TAG_Image 502
#define TAG_Button 503
#define TAG_BottomButton 504

#define HEIGHT_TopPadding 12.0f
#define WIDTH_LeftPadding 10.0f

@implementation CYStoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self showLabelShadows:!highlighted];
    if (animated) {
        [self setLabelColors:(highlighted) ? [UIColor whiteColor] : nil];    
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{[self setLabelColors:(highlighted) ? [UIColor whiteColor] : nil]; }];
    }
    
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self showLabelShadows:!selected];
    if (!animated) {
        [self setLabelColors:(selected) ? [UIColor whiteColor] : nil];    
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{[self setLabelColors:(selected) ? [UIColor whiteColor] : nil]; }];
    }
    
    [self setNeedsDisplay];
}

- (CGFloat)imageOffset {
    return WIDTH_LeftPadding + 57.0f + WIDTH_LeftPadding;
}

- (void)reset {
    [self setTopText:@""];
    [self setMiddleText:@""];
    [self setBottomText:@""];
    [self setImage:nil];
    MAConfirmButton *button = (MAConfirmButton *)self.accessoryView;
    if (button) {
        [button resetDisabled];
    }
}

- (void)setTopText:(NSString *)text {
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_TopLabel];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake([self imageOffset], HEIGHT_TopPadding, self.contentView.frame.size.width - [self imageOffset], 15.0f)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:TAG_TopLabel];
        [label setTextColor:[UIColor colorWithHexString:@"3a3a3a"]];
        [label setShadowColor:[UIColor colorWithHexString:@"c1c1c4"]];
        [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [label setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.contentView addSubview:label];
        [label release];
    }
    
    [label setText:text];
}

- (void)setMiddleText:(NSString *)text {
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_MiddleLabel];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake([self imageOffset], HEIGHT_TopPadding + 13.0f, self.contentView.frame.size.width - [self imageOffset], 20.0f)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:TAG_MiddleLabel];
        [label setTextColor:[UIColor colorWithHexString:@"000000"]];
        [label setShadowColor:[UIColor colorWithHexString:@"c1c1c4"]];
        [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [label setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [self.contentView addSubview:label];
        [label release];
    }
    
    [label setText:text];
}

- (void)setBottomText:(NSString *)text {
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_BottomButton];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake([self imageOffset], HEIGHT_TopPadding + 26.0f, self.contentView.frame.size.width - [self imageOffset], 15.0f)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:TAG_TopLabel];
        [label setTextColor:[UIColor colorWithHexString:@"3a3a3a"]];
        [label setShadowColor:[UIColor colorWithHexString:@"c1c1c4"]];
        [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [label setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.contentView addSubview:label];
        [label release];
    }
    
    [label setText:text];
}

- (void)setMiddleText:(NSString *)text font:(NSString *)font {
    [self setMiddleText:text];
    
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_MiddleLabel];
    [label setFont:[UIFont fontWithName:font size:16.0f]];
}

- (void)setLabelColors:(UIColor *)color {
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_TopLabel];
    if (label) {
        [label setTextColor:(color) ? color : [UIColor colorWithHexString:@"3a3a3a"]];
    }
    label = (UILabel *)[self.contentView viewWithTag:TAG_MiddleLabel];
    if (label) {
        [label setTextColor:(color) ? color : [UIColor colorWithHexString:@"000000"]];
    }
}

- (void)showLabelShadows:(BOOL)shadows {
    UILabel *label = (UILabel *)[self.contentView viewWithTag:TAG_TopLabel];
    CGSize offset = CGSizeMake(0.0f, 1.0f);
    UIColor *color = [UIColor colorWithHexString:@"c1c1c4"];
    if (!shadows) {
        offset.height = 0.0f; 
        color = [UIColor clearColor];
    }
    if (label) {
        [label setShadowOffset:offset];
        [label setShadowColor:color];
    }
    label = (UILabel *)[self.contentView viewWithTag:TAG_MiddleLabel];
    if (label) {
        [label setShadowOffset:offset];
        [label setShadowColor:color];
    }
}

- (void)setImage:(id)image {
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:TAG_Image];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_LeftPadding, 5.0f, 57.0f, 57.0f)];
        [imageView setTag:TAG_Image];
        [self.contentView addSubview:imageView];
        [imageView release];
        
        CALayer *layer = imageView.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        layer.shadowRadius = 1.0f;
        layer.masksToBounds = NO;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:10.0f];
        layer.shadowPath = path.CGPath;
    }
    if (!image) {
        [imageView setHidden:YES];
    }
    else if ([image isKindOfClass:[NSString class]]) {
        [imageView setHidden:NO];
    }
    else if ([image isKindOfClass:[UIImage class]]) {
        [imageView setHidden:NO];
        [imageView setImage:image];
    }
}

- (void)showAccessory:(BOOL)show {
    MAConfirmButton *button = (MAConfirmButton *)self.accessoryView;
    if (button && show) {
        return;
    }
    else if (button && !show) {
        self.accessoryView = nil;
    }
}

- (void)showAccessoryEnabled:(BOOL)enabled title:(NSString *)title confirm:(NSString *)confirm {
    MAConfirmButton *button = (MAConfirmButton *)self.accessoryView;
    if (!button) {
        button = [MAConfirmButton buttonWithTitle:title confirm:confirm];
        [button addTarget:self action:@selector(accessoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;
    }
    [button setTitle:title forState:(enabled) ? UIControlStateNormal : UIControlStateDisabled];
    [button setSelected:enabled];
}

- (void)accessoryPressed:(id)sender {
    [(MAConfirmButton *)sender disableWithTitle:@"Downloading"];
    if([self.superview isKindOfClass:[UITableView class]]) {
        UITableView *table = (UITableView *)self.superview;
        NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell: self];
        [table.delegate tableView:table accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@end
