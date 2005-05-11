//: SGTextAccessoryFieldController_p.h
/**
  * $Id: SGTextAccessoryFieldController_p.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGTextAccessoryFieldController.h"

#import "SGAppKitFrameworkDefines.h"
#import "SGBackgroundSurfaceView.h"
#import "NSTextField-SGExtensions.h"
#import "NSControl-SGExtensions.h"
#import "SGPrivateClearTextButton.h"

#define kTextFieldPreferedHeight			22.0f
#define kTextFieldOnlyRightSpacing			10.0f
#define kTextFieldCancelButtonRightSpacing	4.0f
#define kTextFieldAccessoryPadding			3.0f
#define kTextFieldCancelButtonPadding		3.0f

@interface SGTextAccessoryFieldController(ViewInitializer)
- (void) setupUIComponents;
- (void) setupTextField;
- (void) setupClearButton;

- (void) removeFromNotificationCenter;
- (void) updateUILayout;
@end



@interface SGTextAccessoryFieldController(NotificationDelegate)
- (void) controlTextDidChange : (NSNotification *) aNotification;
@end

