//
//  BSDateFormatter.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/05.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>


@interface BSDateFormatter : NSFormatter {

}
+ (id)sharedDateFormatter;
- (NSDate *)baseDateOfToday;
@end


@interface BSStringFromDateTransformer : NSValueTransformer {

}
@end
