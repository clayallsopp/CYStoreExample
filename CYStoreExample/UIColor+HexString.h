//
//  UIColor+HexString.h
//  ProFolio
//
//  Created by Clay Allsopp on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end

