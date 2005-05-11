/**
  * $Id: CMRMessageComposer.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRMessageComposer.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRMessageComposer.h"



@implementation CMRMessageComposer
- (void) composeThreadMessage : (CMRThreadMessage *) aMessage
{
	if (nil == aMessage) return;
	
	[self prepareForComposing : aMessage];
	[self composeIndex : aMessage];
	[self composeName : aMessage];
	[self composeMail : aMessage];
	[self composeDate : aMessage];
	[self composeDatePrefix : aMessage];
	[self composeID : aMessage];
	[self composeBeProfile : aMessage];
	[self composeHost : aMessage];
	[self composeMessage : aMessage];
	[self concludeComposing : aMessage];
}
- (id) getMessages
{
	return nil;
}
// Informal protocol.
// You should never directly invoke these methods.
- (void) prepareForComposing : (CMRThreadMessage *) aMessage{ ; }
- (void) composeIndex : (CMRThreadMessage *) aMessage{ ; }
- (void) composeName : (CMRThreadMessage *) aMessage{ ; }
- (void) composeMail : (CMRThreadMessage *) aMessage{ ; }
- (void) composeDate : (CMRThreadMessage *) aMessage{ ; }
- (void) composeDatePrefix : (CMRThreadMessage *) aMessage{ ; }
- (void) composeID : (CMRThreadMessage *) aMessage{ ; }
- (void) composeBeProfile : (CMRThreadMessage *) aMessage{ ; }
- (void) composeHost : (CMRThreadMessage *) aMessage{ ; }
- (void) composeMessage : (CMRThreadMessage *) aMessage{ ; }
- (void) concludeComposing : (CMRThreadMessage *) aMessage{ ; }
@end
