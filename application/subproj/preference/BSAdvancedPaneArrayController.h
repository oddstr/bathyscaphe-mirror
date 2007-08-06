//
//  BSAdvancedPaneArrayController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/06.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSAdvancedPaneArrayController : NSArrayController {
	IBOutlet NSTableView *m_tableView;
}
- (NSTableView *)tableView;
@end
