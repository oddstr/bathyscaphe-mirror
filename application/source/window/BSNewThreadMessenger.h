//
//  BSNewThreadMessenger.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/09.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyMessenger.h"


@interface BSNewThreadMessenger : CMRReplyMessenger {
	NSString	*m_newThreadTitle;
}

- (id)initWithBoardName:(NSString *)boardName;

- (NSString *)newThreadTitle;
- (void)setNewThreadTitle:(NSString *)string;
@end

extern NSString *const BSNewThreadMessengerDidFinishPostingNotification;

#define kPostedSubjectKey	@"subject"
#define kPostedBoardNameKey	@"boardName"
