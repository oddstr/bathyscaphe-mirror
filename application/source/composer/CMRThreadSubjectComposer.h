/**
  * $Id: CMRThreadSubjectComposer.h,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadSubjectComposer.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import "CocoMonar_Prefix.h"



@protocol CMRSubjectComposer<NSObject>
- (void) composeIndex : (unsigned int) index;
- (void) composeIdentifier : (NSString *) anIdentifier;
- (void) composeTitle : (NSString *) title;
- (void) composeCount : (unsigned int) resCount;
- (id) getSubject;
@end



@interface CMRThreadSubjectComposer : NSObject<CMRSubjectComposer>
{
	NSString				*_boardName;
	NSMutableDictionary		*_subject;
}
+ (id) composerWithBoardName : (NSString *) boardName;
- (NSString *) boardName;
@end
