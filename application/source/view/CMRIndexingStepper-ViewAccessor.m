//:CMRIndexingStepper-ViewAccessor.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/28  2:12:28 PM)
  *
  */
#import "CMRIndexingStepper_p.h"
#import <SGAppKit/SGAppKit.h>


@implementation CMRIndexingStepper(ViewAccessor)
/* Accessor for m_frameView */
- (NSView *) frameView
{
	return m_frameView;
}
/* Accessor for m_moveTopButton */
- (NSButton *) moveTopButton
{
	return m_moveTopButton;
}
/* Accessor for m_moveEndButton */
- (NSButton *) moveEndButton
{
	return m_moveEndButton;
}
/* Accessor for m_movePrevButton */
- (NSButton *) movePrevButton
{
	return m_movePrevButton;
}
/* Accessor for m_moveNextButton */
- (NSButton *) moveNextButton
{
	return m_moveNextButton;
}
/* Accessor for m_moveUpdatedButton */
- (NSButton *) moveUpdatedButton
{
	return m_moveUpdatedButton;
}
/* Accessor for m_indexField */
- (IndexField *) indexField
{
	return m_indexField;
}

@end



@implementation CMRIndexingStepper(ViewInitializeHelper)
+ (NSSize) defaultButtonSize
{
	return NSMakeSize(
				APP_INDEXINGSTEPPER_BUTTON_WIDTH,
				APP_INDEXINGSTEPPER_BUTTON_HEIGHT);
}


- (void) setupButton : (NSButton *) button
		   iconImage : (NSImage  *) icon
{
	UTILAssertNotNilArgument(button, @"button");
	
	[button setFrameSize : [[self class] defaultButtonSize]];
	[button setContinuous : YES];
	[button  setImagePosition : NSImageOnly];
	[button  setImage : icon];
}
@end



@implementation CMRIndexingStepper(ViewInitializer)
- (void) setupMoveTopButton
{
	NSImage		*image_;
	
	image_ = [NSImage imageAppNamed : APP_INDEXINGSTEPPER_MIN_BUTTON_NAME];
	[self setupButton : [self moveTopButton] 
			iconImage : image_];
}
- (void) setupMoveEndButton
{
	NSImage		*image_;
	
	image_ = [NSImage imageAppNamed : APP_INDEXINGSTEPPER_MAX_BUTTON_NAME];
	[self setupButton : [self moveEndButton]
			iconImage : image_];
}
- (void) setupMovePrevButton
{
	NSImage		*image_;
	
	image_ = [NSImage imageAppNamed : APP_INDEXINGSTEPPER_DEC_BUTTON_NAME];
	
	[self setupButton : [self movePrevButton]
			iconImage : image_];
}
- (void) setupMoveNextButton
{
	NSImage		*image_;
	
	image_ = [NSImage imageAppNamed : APP_INDEXINGSTEPPER_INC_BUTTON_NAME];
	[self setupButton : [self moveNextButton]
			iconImage : image_];

}
- (void) setupMoveUpdatedButton
{
	NSImage		*image_;
	
	image_ = [NSImage imageAppNamed : APP_INDEXINGSTEPPER_UPDATED_BUTTON_NAME];
	[self setupButton : [self moveUpdatedButton]
			iconImage : image_];
	
}
- (void) setupIndexField
{
	NSFont			*labelFont_;
	
	labelFont_ = [NSFont systemFontOfSize : [NSFont smallSystemFontSize]];
	
	[[self indexField] setFont : labelFont_];
	[[self indexField] setAlignment : NSCenterTextAlignment];

	[[self indexField] setDelegate : self];
	//[[self indexField] setAction : @selector(moveToScanedIndex:)];
	[[self indexField] setFocusRingType : NSFocusRingTypeNone];
}
//- (void) setupFrameView
//{
//}
@end



@implementation CMRIndexingStepper(Updating)
- (void) updateMoveButtonEnabled
{
	BOOL	mTopNext_;
	BOOL	mPrevEnd_;
	
	mTopNext_ = ([self intValue] > [self minValue]);
	mPrevEnd_ = ([self intValue] < [self maxValue]);
	
	[[self moveTopButton]  setEnabled : mTopNext_];
	[[self movePrevButton] setEnabled : mTopNext_];
	[[self moveNextButton] setEnabled : mPrevEnd_];
	[[self moveEndButton]  setEnabled : mPrevEnd_];
	[[self moveUpdatedButton]  setEnabled : [self canScrollToLastUpdatedMessage]];
	[[self indexField] setEnabled : ([self maxValue] > 0)];
}
- (void) updateIndexField
{
	NSString *info_;
	info_ = [NSString stringWithFormat :
					  [self format],
					  [self intValue], 
					  [self maxValue]];
	
	[[self indexField] setStringValue : info_];
	
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidUpdate:)];
}
- (void) updateUIComponents
{
	[self updateMoveButtonEnabled];
	[self updateIndexField];
}
@end



@implementation CMRIndexingStepper(NibOwner)
- (void) validateNibSettings
{
}
- (void) setupUIComponents
{
	[self setupMoveTopButton];
	[self setupMoveEndButton];
	[self setupMovePrevButton];
	[self setupMoveNextButton];
	[self setupMoveUpdatedButton];
	[self setupIndexField];
	//[self setupFrameView];
	
	[self updateUIComponents];
}
@end
