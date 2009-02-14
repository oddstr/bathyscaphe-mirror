//
//  CMRTaskItemController.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/10.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@protocol CMRTask;

@interface CMRTaskItemController : NSObject {
	IBOutlet NSView					*_contentView;
	IBOutlet NSObjectController		*m_taskController;
	
	id<CMRTask>						_task;
}

- (id)initWithTask:(id<CMRTask>)aTask;

- (IBAction)stop:(id)sender;
- (id<CMRTask>)task;

- (NSView *)contentView;
- (NSObjectController *)taskController;
@end
