//
//  $Id: BSWindow.h,v 1.2 2006/06/17 06:37:15 tsawada2 Exp $
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