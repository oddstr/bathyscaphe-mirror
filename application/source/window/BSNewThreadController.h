//
//  BSNewThreadController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/09.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyController.h"


@interface BSNewThreadController : CMRReplyController {
	IBOutlet NSTextField	*m_newThreadTitleField;
}

- (NSTextField *)newThreadTitleField;
@end
