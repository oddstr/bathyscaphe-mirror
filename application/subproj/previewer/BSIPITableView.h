//
//  BSIPITableView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/10.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPITableView : NSTableView {

}

@end

@interface NSObject(BSIPITableViewAddition)
- (BOOL) tableView: (BSIPITableView *) aTableView shouldPerformKeyEquivalent: (NSEvent *) theEvent;
@end