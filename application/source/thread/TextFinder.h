/**
  * $Id: TextFinder.h,v 1.1.1.1.4.1 2005/12/14 16:05:06 masakih Exp $
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
}
+ (id) standardTextFinder;
- (NSTextField *) findTextField;
- (NSTextField *) notFoundField;

- (void) setupUIComponents;

- (CMRSearchOptions *) currentOperation;
- (void) setFindString: (NSString *)aString;

// Binding...
- (BOOL) isCaseInsensitive;
- (void) setIsCaseInsensitive : (BOOL) checkBoxState;
- (BOOL) isLinkOnly;
- (void) setIsLinkOnly : (BOOL) checkBoxState;

- (NSString *) loadFindStringFromPasteboard;
- (void) setFindStringToPasteboard;

- (void) registerToNotificationCenter;
@end
