/**
  * $Id: CMRFilterPrefController-View.m,v 1.2 2006/11/05 13:02:21 tsawada2 Exp $
  * 
  * CMRFilterPrefController-View.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRFilterPrefController_p.h"



@implementation CMRFilterPrefController(View)
/*- (NSButton *) spamFilterEnabledCheckBox
{
	return _spamFilterEnabledCheckBox;
}
- (NSButton *) usesSpamMessageCorpusCheckBox
{
	return _usesSpamMessageCorpusCheckBox;
}
- (NSMatrix *) spamFilterBehaviorMatrix
{
	return _spamFilterBehaviorMatrix;
}*/
- (NSWindow *) detailSheet
{
	return _detailSheet;
}
- (NSTextView *) spamMessageCorpusTextView
{
	return _spamMessageCorpusTextView;
}


/*- (void) setupSpamFilterComponents
{
	[self preferencesRespondsTo : @selector(spamFilterEnabled)
					  ofControl : [self spamFilterEnabledCheckBox]];
	[self preferencesRespondsTo : @selector(usesSpamMessageCorpus)
					  ofControl : [self usesSpamMessageCorpusCheckBox]];
	[self preferencesRespondsTo : @selector(spamFilterBehavior)
					  ofControl : [self spamFilterBehaviorMatrix]];
}
- (void) updateSpamFilterComponents
{
	[self syncButtonState : [self spamFilterEnabledCheckBox]
					 with : @selector(spamFilterEnabled)];
	[self syncButtonState : [self usesSpamMessageCorpusCheckBox]
					 with : @selector(usesSpamMessageCorpus)];
	
	[self syncSelectedTag : [self spamFilterBehaviorMatrix]
					 with : @selector(spamFilterBehavior)];
}*/

- (void) updateUIComponents
{
	//[self updateSpamFilterComponents];
}
- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
	//[self setupSpamFilterComponents];
	//[self updateUIComponents];
}
@end
