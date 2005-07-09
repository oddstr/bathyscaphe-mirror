//:CMRStatusLine_p.h
#import "CMRStatusLine.h"

#import <SGAppKit/SGAppKit.h>
#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "AppDefaults.h"


//:CMRStatusLine-ViewAccessor.m
@interface CMRStatusLine(View)
- (NSView *) statusLineView;
- (NSTextField *) statusTextField;
- (NSTextField *) browserInfoTextField;
- (NSProgressIndicator *) progressIndicator;
- (NSButton *) stopButton;

- (void) setInfoTextFieldObjectValue : (id) anObject;
- (void) setBrowserInfoTextFieldObjectValue : (id) anObject;
- (void) setupStatusLineView;
- (void) setupUIComponents;
- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;

@end