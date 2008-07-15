//
//  BSIPIArrayController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/11.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <AppKit/NSArrayController.h>


@interface BSIPIArrayController : NSArrayController {

}
- (void)removeAll:(id)sender;
- (void)selectFirst:(id)sender;
- (void)selectLast:(id)sender;
@end
