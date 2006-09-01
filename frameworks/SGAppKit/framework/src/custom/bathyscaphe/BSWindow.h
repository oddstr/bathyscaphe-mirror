//
//  $Id: BSWindow.h,v 1.1.4.1 2006/09/01 13:46:56 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/06/12.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSWindow : NSWindow {

}

@end

@interface NSObject(BSWindowAdditionalDelegate)
- (void) windowWillRunToolbarCustomizationPalette: (NSWindow *) sender;
@end