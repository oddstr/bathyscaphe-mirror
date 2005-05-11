//: SGAppKit.h
/**
  * $Id: SGAppKit.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */


#ifndef SGAPPKIT_INCLUDED
#define SGAPPKIT_INCLUDED


#import <Cocoa/Cocoa.h>


// フレームワークの初期化
extern void SGAppKitFrameworkInit(void);


#import <SGAppKit/NSCell-SGExtensions.h>
#import <SGAppKit/NSColor-SGExtensions.h>
#import <SGAppKit/NSControl-SGExtensions.h>
#import <SGAppKit/NSView-SGExtensions.h>
#import <SGAppKit/NSMenu-SGExtensions.h>
#import <SGAppKit/NSBrowserCell-SGExtensions.h>
#import <SGAppKit/NSImage-SGExtensions.h>
#import <SGAppKit/NSMatrix-SGExtensions.h>
#import <SGAppKit/NSPasteboard-SGExtensions.h>
#import <SGAppKit/NSScrollView-SGExtensions.h>
#import <SGAppKit/NSTextView-SGExtensions.h>
#import <SGAppKit/NSTextField-SGExtensions.h>
#import <SGAppKit/NSToolbar-SGExtensions.h>
#import <SGAppKit/NSWindow-SGExtensions.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <SGAppKit/NSUserDefaults+SGAppKitExtensions.h>

#import <SGAppKit/SGContainerTableView.h>
#import <SGAppKit/SGSplitView.h>
#import <SGAppKit/SGTableViewBase.h>
#import <SGAppKit/SGTableView.h>
#import <SGAppKit/SGOutlineView.h>

/* buggy...
#import <SGAppKit/SGBezelStyleTextField.h>
#import <SGAppKit/SGBezelStyleTextFieldCell.h>
*/

#import <SGAppKit/SGBackgroundSurfaceView.h>
#import <SGAppKit/SGTextAccessoryFieldController.h>
#import <SGAppKit/SGFixImageButtonCell.h>
#import <SGAppKit/SGToolbarIconItemButton.h>
#import <SGAppKit/SGControlToolbarItem.h>

#import <SGAppKit/SGKeyBindingSupport.h>




#endif /* SGAPPKIT_INCLUDED */
