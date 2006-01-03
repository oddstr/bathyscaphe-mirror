/* SmartBLIEditorHelper */

#import <Cocoa/Cocoa.h>

@class ColorBackgroundView;

@interface SmartBLIEditorHelper : NSObject
{
    IBOutlet NSPopUpButton *allOrAnyPopUp;
    IBOutlet NSScrollView *container;
    IBOutlet NSButton *includeFallInDATCheck;
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
