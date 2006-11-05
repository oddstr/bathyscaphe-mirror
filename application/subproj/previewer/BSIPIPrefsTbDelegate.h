//
//  BSIPIPrefsTbDelegate.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPIPrefsTbDelegate : NSObject {
	IBOutlet NSPanel		*m_prefsWindow;
	IBOutlet NSTabView		*m_prefsTabView;
}

- (NSPanel *) prefsWindow;
- (NSTabView *) prefsTabView;
@end
