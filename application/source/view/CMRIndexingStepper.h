//:CMRIndexingStepper.h
/**
  *
  * 
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Sat Sep 28 2002
  *
  */
#import <Cocoa/Cocoa.h>

@class IndexField;

@interface CMRIndexingStepper : NSObject
{
	IBOutlet NSView				*m_frameView;
	IBOutlet NSButton			*m_moveTopButton;
	IBOutlet NSButton			*m_moveEndButton;
	IBOutlet NSButton			*m_movePrevButton;
	IBOutlet NSButton			*m_moveNextButton;
	IBOutlet NSButton			*m_moveUpdatedButton;
	IBOutlet IndexField			*m_indexField;
	
	id			m_delegate;
	NSString	*m_format;
	int			m_intValue;
	int			m_maxValue;
	int			m_minValue;
}
@end



@interface CMRIndexingStepper(Attributes)
- (id) delegate;
- (void) setDelegate : (id) aDelegate;
- (NSView *) contentView;
- (NSTextField *) textField;
- (NSString *) stringValue;

- (NSString *) format;
- (void) setFormat : (NSString *) aFormat;
- (int) maxValue;
- (void) setMaxValue : (int) aMaxValue;
- (int) minValue;
- (void) setMinValue : (int) aMinValue;
- (int) intValue;
- (void) setIntValue : (int) anIntValue;
@end



@interface CMRIndexingStepper(Action)
- (IBAction) increment : (id) sender;
- (IBAction) decrement : (id) sender;
- (IBAction) max : (id) sender;
- (IBAction) min : (id) sender;
- (IBAction) updated : (id) sender;
@end



@interface NSObject(CMRIndexingStepperDelegate)
- (void) indexingStepperDidUpdate : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidEndEditing : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidIncrement : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidDecrement : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidBecomeMin : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidBecomeMax : (CMRIndexingStepper *) stepper;
- (void) indexingStepperDidBecomeUpdated : (CMRIndexingStepper *) stepper;
@end
