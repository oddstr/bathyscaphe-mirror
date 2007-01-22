/**
  * $Id: CMRMessageComposer.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * CMRMessageComposer.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>

@class CMRThreadMessage;
@class CMRThreadMessageAttributes;



@protocol CMRMessageComposer<NSObject>
- (void) composeThreadMessage : (CMRThreadMessage *) message;
- (id) getMessages;
@end



@interface CMRMessageComposer : NSObject<CMRMessageComposer>
// Informal protocol.
// You should never directly invoke these methods.
- (void) prepareForComposing : (CMRThreadMessage *) aMessage;
- (void) composeIndex : (CMRThreadMessage *) aMessage;
- (void) composeName : (CMRThreadMessage *) aMessage;
- (void) composeMail : (CMRThreadMessage *) aMessage;
- (void) composeDate : (CMRThreadMessage *) aMessage;
- (void) composeDatePrefix : (CMRThreadMessage *) aMessage;
- (void) composeID : (CMRThreadMessage *) aMessage;
- (void) composeBeProfile : (CMRThreadMessage *) aMessage;
- (void) composeHost : (CMRThreadMessage *) aMessage;
- (void) composeMessage : (CMRThreadMessage *) aMessage;
- (void) concludeComposing : (CMRThreadMessage *) aMessage;
@end
