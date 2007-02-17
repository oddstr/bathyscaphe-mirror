/**
  * $Id: TextFinder.h,v 1.5 2007/02/17 15:34:10 tsawada2 Exp $
  * 
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import <Cocoa/Cocoa.h>

@class CMRSearchOptions;

@interface TextFinder : NSWindowController
{
	IBOutlet NSTextField	*_findTextField;
	IBOutlet NSTextField	*_notFoundField;
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

- (void) setupUIComponents;

- (CMRSearchOptions *) currentOperation;

- (NSString *) findString;
- (void) setFindString: (NSString *) aString;

// Binding...
- (BOOL) isCaseInsensitive;
- (void) setIsCaseInsensitive : (BOOL) checkBoxState;
- (BOOL) isLinkOnly;
- (void) setIsLinkOnly : (BOOL) checkBoxState;

- (NSString *) loadFindStringFromPasteboard;
- (void) setFindStringToPasteboard;

- (void) registerToNotificationCenter;
@end
