//: SGTextAccessoryFieldController.m
/**
  * $Id: SGTextAccessoryFieldController.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGTextAccessoryFieldController_p.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static NSString *const kControllerLoadNibName = @"SGTextAccessoryFieldComponents";



@implementation SGTextAccessoryFieldController
+ (float) preferedHeight
{
	return kTextFieldPreferedHeight;
}
- (id) initWithViewFrame : (NSRect) aFrame
{
	if(self = [self init]){
		[[self backgroundView] setFrame : aFrame];
	}
	return self;
}
- (id) init
{
	if(self = [super init]){
		if(NO == [NSBundle loadNibNamed:kControllerLoadNibName owner:self]){
			NSLog(@"can't load Nib file <%@.nib>", kControllerLoadNibName);
			[self autorelease];
			return nil;
		}
	}
	return self;
}
- (void) dealloc
{
	[[self backgroundView] setDelegate : nil];
	[self removeFromNotificationCenter];
	
	[m_componentView release];
	
	[m_accessoryView release];
	[m_clearButton release];
	[super dealloc];
}

- (void) awakeFromNib
{
	[self setupUIComponents];
}
- (BOOL) sendsActionOnTextDidChange
{
	return _sendsActionOnTextDidChange;
}
- (void) setSendsActionOnTextDidChange : (BOOL) flag
{
	_sendsActionOnTextDidChange = flag;
}

- (void) setStringValue : (NSString *) aString
{
	[[self textField] setStringValue : aString];
	[self updateUILayout];
}
- (void) selectAll : (id) sender
{
	[[[self textField] window] makeFirstResponder : [self textField]];
}
- (void) sendTextFieldAction
{
	NSTextField		*field_;
	
	field_ = [self textField];
	[field_ sendAction : [field_ action]
				    to : [field_ target]];
}

- (IBAction) clearText : (id) sender
{
	NSTextField		*field_;
	
	if([self isEmpty]) return;
	
	field_ = [self textField];
	[field_ setStringValue : @""];
	[self updateUILayout];
	if(NULL == [field_ action]) return;
	
	[self sendTextFieldAction];
}
@end



@implementation SGTextAccessoryFieldController(Accessor)
- (NSView *) accessoryView
{
	return m_accessoryView;
}
- (void) setAccessoryView : (NSView *) anAccessoryView
{
	id		tmp;
	
	tmp = m_accessoryView;
	
	if([m_accessoryView isDescendantOf : [self backgroundView]])
		[m_accessoryView removeFromSuperview];
	
	m_accessoryView = [anAccessoryView retain];
	[[self backgroundView] addSubview : m_accessoryView];
	
	[tmp release];
	
	[self updateUILayout];
}
- (BOOL) isEmpty
{
	return (0 == [[[self textField] stringValue] length]);
}
- (BOOL) clearButtonVisible
{
	return [[self clearButton] isDescendantOf : [self backgroundView]];
}
- (void) setVisibleClearButton : (BOOL) flag
{
	if(flag && NO == [self clearButtonVisible])
		[[self backgroundView] addSubview : [self clearButton]];
	else if(NO == flag && [self clearButtonVisible])
		[[self clearButton] removeFromSuperview];
	else
		return;
}
@end



@implementation SGTextAccessoryFieldController(NotificationDelegate)
- (void) controlTextDidChange : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		NSControlTextDidChangeNotification);
	UTILAssertNotificationObject(
		aNotification,
		[self textField]);
	
	[self updateUILayout];
	if([self sendsActionOnTextDidChange])
		[[self textField] sendsAction];
	
	//[[self backgroundView] setNeedsUpdateKeyboardFocusRing : YES];
}
// SGBackgroundSurfaceView Delegate
- (BOOL) backgroundViewShowsKeyboardFocusRing : (SGBackgroundSurfaceView *) aView
{
	return NO;
	//return [[self textField] isFirstResponder];
}
@end



@implementation SGTextAccessoryFieldController(ViewAccessor)
- (NSView *) componentView
{
	return m_componentView;
}
- (SGBackgroundSurfaceView *) backgroundView
{
	return m_backgroundView;
}
- (NSTextField *) textField
{
	return m_textField;
}
- (NSButton *) clearButton
{
	return m_clearButton;
}
@end



@implementation SGTextAccessoryFieldController(ViewInitializer)
- (void) setupUIComponents
{
	[[self backgroundView] setDelegate : self];
	
	[self setupClearButton];
	[self setupTextField];
}
- (void) setupTextField
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		   selector : @selector(controlTextDidChange:)
			   name : NSControlTextDidChangeNotification
			 object : [self textField]];
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
		removeObserver : self
				  name : NSControlTextDidChangeNotification
				object : [self textField]];
}
- (void) setupClearButton
{
	[[self clearButton] setBordered : NO];
	[[[self clearButton] cell] setHighlightsBy:NSNoCellMask];
	[[[self clearButton] cell] setShowsStateBy:NSNoCellMask];
	
	[[self clearButton] retain];
}
- (void) updateUILayout
{
	NSRect		cFrame_;
	NSRect		tFrame_;
	NSRect		bFrame_;
	NSRect		frame_;
	
	frame_ = [[self backgroundView] frame];
	
	cFrame_ = [self accessoryView] 
				? [[self accessoryView] frame]
				: NSZeroRect;
	// cFrame_.origin = NSZeroPoint;
	[[self accessoryView] setFrameOrigin : cFrame_.origin];
	
	bFrame_ = [[self clearButton] frame];
	if([self isEmpty]){
		bFrame_.size.width = kTextFieldOnlyRightSpacing;
		[self setVisibleClearButton : NO];
	}else{
		[self setVisibleClearButton : YES];
	}
	
	{
		NSRect		prev_;
		
		tFrame_ = [[self textField] frame];
		prev_ = tFrame_;
		tFrame_.origin.x = NSMaxX(cFrame_);
		tFrame_.origin.x += kTextFieldAccessoryPadding;
		tFrame_.size.width = NSWidth(frame_) - tFrame_.origin.x;
		tFrame_.size.width -= NSWidth(bFrame_);
		tFrame_.size.width -= kTextFieldCancelButtonPadding;
		tFrame_.size.width -= kTextFieldCancelButtonRightSpacing;
		
		if(NO == NSEqualRects(prev_, tFrame_)){
			[[self textField] setFrame : tFrame_];
		}
	}
	if(NO == [self clearButtonVisible]) return;
	
	bFrame_.origin.x = NSMaxX(tFrame_);
	bFrame_.origin.x += kTextFieldCancelButtonPadding;
	[[self clearButton] setFrameOrigin : bFrame_.origin];
}
@end




@implementation SGPrivateClearTextButton
- (void) mouseDown : (NSEvent *) theEvent
{
	[self sendsAction];
}
@end
