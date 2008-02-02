//
//  BSNSControlTbItem.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSNSControlToolbarItem : NSToolbarItem {

}

@end

@interface NSObject(BSNSControlToolbarItemValidation)
- (BOOL)validateNSControlToolbarItem:(NSToolbarItem *)item;
@end
