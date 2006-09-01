//:CMRIndexingStepper_p.h
#import "CMRIndexingStepper.h"
#import "CocoMonar_Prefix.h"
#import <SGAppKit/IndexField.h>


#define APP_INDEXINGSTEPPER_LOADNIB_NAME		@"CMRIndexingStepper"
#define APP_INDEXINGSTEPPER_FORMAT				@"%d/%d"
#define APP_INDEXINGSTEPPER_BUTTON_WIDTH		16.0f
#define APP_INDEXINGSTEPPER_BUTTON_HEIGHT		18.0f
#define APP_INDEXINGSTEPPER_MIN_BUTTON_NAME		@"moveTop"
#define APP_INDEXINGSTEPPER_DEC_BUTTON_NAME		@"movePrev"
#define APP_INDEXINGSTEPPER_INC_BUTTON_NAME		@"moveNext"
#define APP_INDEXINGSTEPPER_MAX_BUTTON_NAME		@"moveEnd"
#define APP_INDEXINGSTEPPER_UPDATED_BUTTON_NAME		@"moveUpdated"


@interface CMRIndexingStepper(Private)
- (void) invokeDelegateMethodWithSelector : (SEL) aSelector;
- (BOOL) canScrollToLastUpdatedMessage;
@end



@interface CMRIndexingStepper(Scan)
- (unsigned) nthfield : (unsigned ) anIndex
                field : (NSRange *) aRange;
- (unsigned) unsignedIntAfterPrefix : (NSString *) prefix
                              field : (NSRange  *) aRange;
- (void) selectEditableRange : (NSText *) textObj;
- (NSRange) editableRange : (unsigned *) value;
- (NSString *) prefixToBeSkiped;
@end



@interface CMRIndexingStepper(ViewAccessor)
/* Accessor for m_frameView */
- (NSView *) frameView;
/* Accessor for m_moveTopButton */
- (NSButton *) moveTopButton;
/* Accessor for m_moveEndButton */
- (NSButton *) moveEndButton;
/* Accessor for m_movePrevButton */
- (NSButton *) movePrevButton;
/* Accessor for m_moveNextButton */
- (NSButton *) moveNextButton;
/* Accessor for m_moveUpdatedButton */
- (NSButton *) moveUpdatedButton;
/* Accessor for m_indexField */
- (IndexField *) indexField;
@end



@interface CMRIndexingStepper(ViewInitializeHelper)
+ (NSSize) defaultButtonSize;
- (void) setupButton : (NSButton *) button
		   iconImage : (NSImage  *) icon;
@end


@interface CMRIndexingStepper(ViewInitializer)
//- (void) setupFrameView;
- (void) setupMoveTopButton;
- (void) setupMoveEndButton;
- (void) setupMovePrevButton;
- (void) setupMoveNextButton;
- (void) setupMoveUpdatedButton;
- (void) setupIndexField;
@end



@interface CMRIndexingStepper(Updating)
- (void) updateMoveButtonEnabled;
- (void) updateIndexField;
- (void) updateUIComponents;
@end



@interface CMRIndexingStepper(NibOwner)
- (void) setupUIComponents;
@end
