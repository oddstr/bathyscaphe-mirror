/**
  * $Id: TextFinder.h,v 1.8 2007/03/18 14:53:31 tsawada2 Exp $
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
	IBOutlet NSButton		*m_linkOnlyButton;
	NSString				*m_findString;
}
+ (id) standardTextFinder;
- (NSTextField *) findTextField;
- (NSTextField *) notFoundField;
- (NSBox *) optionsBox;
- (NSMatrix *) targetMatrix;
- (NSView *) findButtonsView;
- (NSButton *) linkOnlyButton;

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
- (void) updateLinkOnlyBtnEnabled;

- (void) registerToNotificationCenter;
@end
