/**
  * $Id: FCController.h,v 1.6 2005/12/03 09:01:50 tsawada2 Exp $
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
	IBOutlet NSButton		*_threadViewFontButton;
	IBOutlet NSButton		*_messageFontButton;
	IBOutlet NSButton		*_itemTitleFontButton;
	IBOutlet NSButton		*_alternateFontButton;
	IBOutlet NSButton		*_hostFontButton;
	IBOutlet NSButton		*_beProfileFontButton;
	IBOutlet NSButton		*_threadsListFontButton;
	IBOutlet NSButton		*_newThreadFontButton;
	IBOutlet NSButton		*m_replyFontButton;

	IBOutlet NSButton		*m_BLtextFontButton;
	IBOutlet NSTextField	*m_BLrowHeightField;
	IBOutlet NSStepper		*m_BLrowHeightStepper;
	
	IBOutlet NSTextField	*m_rowHeightField;
	
	IBOutlet NSStepper		*m_rowHeightStepper;	
}

- (IBAction) changeTableRowSpace : (id) sender;
- (IBAction) fixRowHeightToFont : (id) sender;

- (IBAction) changeBoardListRowHeight : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

- (void) changeFontOf : (int) tagNum To: (NSFont *) newFont;

// SledgeHammer Additions - Cocoa binding support
- (float) msgContIndentValue;
- (void) setMsgContIndentValue : (float) aValue;
- (float) msgContSpacingBeforeValue;
- (void) setMsgContSpacingBeforeValue : (float) aValue;
- (float) msgContSpacingAfterValue;
- (void) setMsgContSpacingAfterValue : (float) aValue;

- (float) resPopUpBgAlphaValue;
- (void) setResPopUpBgAlphaValue : (float) aValue;
- (float) replyBgAlphaValue;
- (void) setReplyBgAlphaValue : (float) aValue;

- (NSColor *) threadTextColor;
- (void) setThreadTextColor : (NSColor *) newColor;
- (NSColor *) msgTextColor;
- (void) setMsgTextColor : (NSColor *) newColor;
- (NSColor *) headerTextColor;
- (void) setHeaderTextColor : (NSColor *) newColor;
- (NSColor *) hostTextColor;
- (void) setHostTextColor : (NSColor *) newColor;
- (NSColor *) linkTextColor;
- (void) setLinkTextColor : (NSColor *) newColor;
- (NSColor *) nameTextColor;
- (void) setNameTextColor : (NSColor *) newColor;
- (NSColor *) threadBgColor;
- (void) setThreadBgColor : (NSColor *) newColor;

- (NSColor *) thListDefaultColor;
- (void) setThListDefaultColor : (NSColor *) newColor;
- (NSColor *) thListNewColor;
- (void) setThListNewColor : (NSColor *) newColor;

- (NSColor *) popupBgColor;
- (void) setPopupBgColor : (NSColor *) newColor;
- (NSColor *) popupTextColor;
- (void) setPopupTextColor : (NSColor *) newColor;

- (NSColor *) replyTextColor;
- (void) setReplyTextColor : (NSColor *) newColor;
- (NSColor *) replyBgColor;
- (void) setReplyBgColor : (NSColor *) newColor;
- (NSColor *) boardListTextColor;
- (void) setBoardListTextColor : (NSColor *) newColor;

- (BOOL) hasAnchorUL;
- (void) setHasAnchorUL : (BOOL) boxState;
- (BOOL) shouldAntiAlias;
- (void) setShouldAntiAlias : (BOOL) boxState;
- (BOOL) drawsGrid;
- (void) setDrawsGrid : (BOOL) boxState;
- (BOOL) drawsStriped;
- (void) setDrawsStriped : (BOOL) boxState;
- (BOOL) popupUsesCustomTextColor;
- (void) setPopupUsesCustomTextColor : (BOOL) boxState;
- (BOOL) popupUsesSmallScroller;
- (void) setPopupUsesSmallScroller : (BOOL) boxState;

// LittleWish Addition
- (NSColor *) hiliteColor;
- (void) setHiliteColor : (NSColor *) newColor;

@end
