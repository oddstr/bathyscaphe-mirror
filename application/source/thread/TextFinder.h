/**
  * $Id: TextFinder.h,v 1.7 2007/03/17 19:28:58 tsawada2 Exp $
  * 
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import <Cocoa/Cocoa.h>

@class BSSearchOptions;

@interface TextFinder : NSWindowController
{
	IBOutlet NSTextField	*_findTextField;
	IBOutlet NSTextField	*_notFoundField;
	IBOutlet NSBox			*m_optionsBox;
	IBOutlet NSMatrix		*m_targetMatrix;
	IBOutlet NSView			*m_findButtonsView;
	IBOutlet NSButton		*m_disclosureTriangle;
	IBOutlet NSButton		*_findNextBtn;
	IBOutlet NSButton		*_findPrevBtn;
	IBOutlet NSButton		*_findFromHeadBtn;
	IBOutlet NSButton		*_findAllBtn;
	IBOutlet NSButton		*_findPopupBtn;
	NSString				*m_findString;
}
+ (id) standardTextFinder;
- (NSTextField *) findTextField;
- (NSTextField *) notFoundField;
- (NSBox *) optionsBox;
- (NSMatrix *) targetMatrix;
- (NSView *) findButtonsView;

- (void) setupUIComponents;

- (BSSearchOptions *) currentOperation;

- (NSString *) findString;
- (void) setFindString: (NSString *) aString;

// Binding...
- (BOOL) isCaseInsensitive;
- (void) setIsCaseInsensitive : (BOOL) checkBoxState;
- (BOOL) isLinkOnly;
- (void) setIsLinkOnly : (BOOL) checkBoxState;
- (BOOL) usesRegularExpression;
- (void) setUsesRegularExpression : (BOOL) checkBoxState;

- (IBAction) changeTargets: (id) sender;
- (IBAction) togglePanelMode: (id) sender;

- (NSString *) loadFindStringFromPasteboard;
- (void) setFindStringToPasteboard;

- (void) expandOrShrinkPanel: (BOOL) willExpand animate: (BOOL) shouldAnimate;

- (void) registerToNotificationCenter;
@end
