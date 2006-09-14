/**
  * $Id: CMRFilterPrefController_p.h,v 1.1.1.1.8.1 2006/09/14 20:37:04 tsawada2 Exp $
  * 
  * CMRFilterPrefController_p.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRFilterPrefController.h"
#import "PreferencePanes_Prefix.h"



@interface CMRFilterPrefController(View)
/*- (NSButton *) spamFilterEnabledCheckBox;
- (NSButton *) usesSpamMessageCorpusCheckBox;
- (NSMatrix *) spamFilterBehaviorMatrix;*/

- (NSWindow *) detailSheet;
- (NSTextView *) spamMessageCorpusTextView;
@end

