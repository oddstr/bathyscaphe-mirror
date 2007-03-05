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

@implementation CMRIndexingStepper(ViewAccessor)
/* Accessor for m_frameView */
- (NSView *) frameView
{
	return m_frameView;
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
- (NSMatrix *) moveForPrevMatrix
{
	return m_moveForPrevMatrix;
}
- (NSMatrix *) moveForNextMatrix
{
	return m_moveForNextMatrix;
}
@end


@implementation CMRIndexingStepper(ViewInitializer)
- (void) setupCell: (NSButtonCell *) cell iconImageName: (NSString *) imageName
{
	UTILAssertNotNilArgument(cell, @"NSButtonCell");
	
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) {
		[cell setBezelStyle: NSSmallSquareBezelStyle]; // Tiger or later
	} else {
		[cell setBezelStyle: NSShadowlessSquareBezelStyle];
	}
	if (imageName != nil) {
		[cell setImage: [NSImage imageAppNamed: imageName]];
	}
}

- (void) setupMoveForNextMatrix
{
	NSMatrix *matrix = [self moveForNextMatrix];
	[self setupCell: [matrix cellWithTag: 0] iconImageName: APP_INDEXINGSTEPPER_INC_BUTTON_NAME];
	[self setupCell: [matrix cellWithTag: 1] iconImageName: APP_INDEXINGSTEPPER_MAX_BUTTON_NAME];
}

- (void) setupMoveForPrevMatrix
{
	NSMatrix *matrix = [self moveForPrevMatrix];
	[self setupCell: [matrix cellWithTag: 0] iconImageName: APP_INDEXINGSTEPPER_MIN_BUTTON_NAME];
	[self setupCell: [matrix cellWithTag: 1] iconImageName: APP_INDEXINGSTEPPER_DEC_BUTTON_NAME];
}

- (void) setupMoveUpdatedButton
{
	[self setupCell: [[self moveUpdatedButton] cell] iconImageName: nil];
}

- (void) setupIndexField
{
	NSFont			*labelFont_;
	
	labelFont_ = [NSFont systemFontOfSize : [NSFont smallSystemFontSize]];
	
	[[self indexField] setFont : labelFont_];
	[[self indexField] setAlignment : NSCenterTextAlignment];

	[[self indexField] setDelegate : self];
}
@end



@implementation CMRIndexingStepper(Updating)
- (void) updateMoveButtonEnabled
{
	BOOL	mTopNext_;
	BOOL	mPrevEnd_;
	
	mTopNext_ = ([self intValue] > [self minValue]);
	mPrevEnd_ = ([self intValue] < [self maxValue]);
	
	[[self moveForPrevMatrix] setEnabled: mTopNext_];
	[[self moveForNextMatrix] setEnabled: mPrevEnd_];
	[[self moveUpdatedButton] setEnabled: [self canScrollToLastUpdatedMessage]];
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
- (void) setupUIComponents
{
	[self setupMoveForPrevMatrix];
	[self setupMoveForNextMatrix];
	[self setupMoveUpdatedButton];
	[self setupIndexField];
	
	[self updateUIComponents];
}
@end
