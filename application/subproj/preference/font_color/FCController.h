/**
  * $Id: FCController.h,v 1.8 2007/01/20 20:31:58 tsawada2 Exp $
  * 
  * FCController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"



@interface FCController : PreferencesController
{	
/*	IBOutlet NSButton		*_threadViewFontButton;
	IBOutlet NSButton		*_messageFontButton;
	IBOutlet NSButton		*_itemTitleFontButton;
	IBOutlet NSButton		*_alternateFontButton;
	IBOutlet NSButton		*_hostFontButton;
	IBOutlet NSButton		*_beProfileFontButton;
	IBOutlet NSButton		*_threadsListFontButton;
	IBOutlet NSButton		*_newThreadFontButton;
	IBOutlet NSButton		*m_replyFontButton;

	IBOutlet NSButton		*m_BLtextFontButton;*/
}

- (IBAction) fixRowHeightToFont : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

//- (void) changeFontOf : (int) tagNum To: (NSFont *) newFont;
@end
/*
@interface FCController(ViewAccessor)
- (NSButton *) alternateFontButton;
- (NSButton *) threadViewFontButton;
- (NSButton *) messageFontButton;
- (NSButton *) itemTitleFontButton;
- (NSButton *) threadsListFontButton;
- (NSButton *) newThreadFontButton;
- (NSButton *) replyFontButton;
- (NSButton *) hostFontButton;
- (NSButton *) boardListTextFontButton;
- (NSButton *) beProfileFontButton;

- (NSFont *) getFontOf : (int) btnTag;
@end*/
