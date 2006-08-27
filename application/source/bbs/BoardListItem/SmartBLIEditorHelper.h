/* SmartBLIEditorHelper */

#import <Cocoa/Cocoa.h>

#import "SmartCondition.h"

@class ColorBackgroundView;

@interface SmartBLIEditorHelper : NSObject
{
    IBOutlet NSPopUpButton *allOrAnyPopUp;
    IBOutlet NSScrollView *container;
    IBOutlet NSButton *includeFallInDATCheck;
	IBOutlet NSButton *excludeAdThreadCheck;
    IBOutlet NSTextField *nameField;
	
	IBOutlet id expressionView;
    IBOutlet id numberView;
	IBOutlet id dateView;
	
	SmartBLIEditorHelper *previousHelper;
	SmartBLIEditorHelper *nextHelper;
}
- (IBAction)addCriterion:(id)sender;
- (IBAction)changeCriterionPop:(id)sender;
- (IBAction)removeCriterion:(id)sender;
@end

@interface SmartBLIEditorHelper(SmartConditionAccesor)
- (id<SmartCondition>)condition;
- (BOOL)buildHelperFromCondition:(id<SmartCondition>)condition;
@end