/**
  * $Id: CMRStatusLineWindowController.h,v 1.10 2009/02/14 18:46:15 tsawada2 Exp $
  * BathyScaphe
  *
  * �� CMRStatusLineWindowController �� CMRToolbarWindowController �𓝍�
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>
#import "CocoMonar_Prefix.h"
#import "CMRToolbarDelegate.h"
#import "CMRStatusLine.h"
#import "BSNSControlTbItem.h"

@protocol CMRToolbarDelegate;

@interface CMRStatusLineWindowController: NSWindowController<NSUserInterfaceValidations>
{
	@private
	CMRStatusLine				*m_statusLine;
	id<CMRToolbarDelegate>		m_toolbarDelegateImp;
}
+ (Class) toolbarDelegateImpClass;
- (id<CMRToolbarDelegate>) toolbarDelegate;

// board / thread signature for historyManager .etc
//- (id) boardIdentifier;
- (id) threadIdentifier;
@end

@interface CMRStatusLineWindowController(Action)
- (IBAction) saveAsDefaultFrame: (id) sender;
- (IBAction) cancelCurrentTask: (id) sender;
@end

@interface CMRStatusLineWindowController(ViewInitializer)
- (void) setupUIComponents;

+ (Class) statusLineClass;
//- (NSString *) statusLineFrameAutosaveName;
- (void) setupStatusLine;
- (CMRStatusLine *) statusLine;
@end
