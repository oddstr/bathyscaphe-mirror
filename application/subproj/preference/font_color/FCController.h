/**
  * $Id: FCController.h,v 1.4 2005/09/24 06:07:50 tsawada2 Exp $
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
	IBOutlet NSColorWell	*_threadViewBGColorWell;
	IBOutlet NSColorWell	*_threadViewColorWell;
	IBOutlet NSColorWell	*_messageColorWell;
	IBOutlet NSColorWell	*_messageNameColorWell;
	IBOutlet NSColorWell	*_messageTitleColorWell;
	IBOutlet NSColorWell	*_messageAnchorColorWell;
	IBOutlet NSColorWell	*_messageFilteredColorWell;
	IBOutlet NSColorWell	*_messageTextEnhancedColorWell;
	IBOutlet NSColorWell	*_messageHostColorWell;
	
	IBOutlet NSButton		*_hasAnchorULButton;
	
	IBOutlet NSButton		*_threadsListFontButton;
	IBOutlet NSButton		*_newThreadFontButton;
	IBOutlet NSColorWell	*_newThreadColorWell;
	IBOutlet NSColorWell	*_threadsListColorWell;
	
	IBOutlet NSButton		*m_drawsGridCheckBox;
	IBOutlet NSButton		*m_drawStripedCheckBox;
	
	IBOutlet NSTextField	*m_rowHeightField;
	//IBOutlet NSTextField	*m_spaceWidthField;
	//IBOutlet NSTextField	*m_spaceHeightField;
	
	IBOutlet NSStepper		*m_rowHeightStepper;
	//IBOutlet NSStepper		*m_spaceWidthStepper;
	//IBOutlet NSStepper		*m_spaceHeightStepper;
	
	// ‚»‚Ì‘¼
	IBOutlet NSColorWell	*_resPopUpBGColorWell;
	IBOutlet NSColorWell	*_resPopUpTextColorWell;
	IBOutlet NSButton		*_resPopUpUsesTCButton;
	//IBOutlet NSButton		*_resPopUpIsSeeThroughButton;
	IBOutlet NSButton		*m_shouldAntialiasButton;
	
	IBOutlet NSButton		*_resPopUpScrollerIsSmall;
	
	IBOutlet NSButton		*m_replyFontButton;
	IBOutlet NSColorWell	*m_replyTextColorWell;
	IBOutlet NSColorWell	*m_replyBackgroundColorWell;

	IBOutlet NSButton		*m_BLtextFontButton;
	IBOutlet NSColorWell	*m_BLtextColorWell;
	IBOutlet NSTextField	*m_BLrowHeightField;
	IBOutlet NSStepper		*m_BLrowHeightStepper;
}

- (IBAction) changeHasAnchorUnderline : (id) sender;
- (IBAction) changeResPopUpUsesTextColor : (id) sender;
//- (IBAction) changeResPopUpSeeThrough : (id) sender;
- (IBAction) changeShouldThreadAntialias : (id) sender;
- (IBAction) changeColor : (id) sender;
- (IBAction) changeDrawsGrid : (id) sender;
- (IBAction) changeDrawStriped : (id) sender;
- (IBAction) changeTableRowSpace : (id) sender;
- (IBAction) fixRowHeightToFont : (id) sender;

- (IBAction) changeBoardListRowHeight : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

- (IBAction) changePopUpScrollerSize : (id) sender;
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
@end
