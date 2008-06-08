//
//  CMRTaskItemController.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@protocol CMRTask;

@interface CMRTaskItemController : NSObject {
	IBOutlet NSView					*_contentView;
	IBOutlet NSProgressIndicator	*_indicator;
	
	id<CMRTask>						_task;
}

- (id)initWithTask:(id<CMRTask>)aTask;

- (IBAction)stop:(id)sender;
- (id<CMRTask>)task;
- (void)setTask:(id<CMRTask>)aTask;

- (NSView *)contentView;
- (NSProgressIndicator *)indicator;
@end
