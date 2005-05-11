/**
  * $Id: FCController.h,v 1.1.1.1 2005/05/11 17:51:10 tsawada2 Exp $
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
	IBOutlet NSColorWell	*_threadViewBGColorWell;
	IBOutlet NSColorWell	*_threadViewColorWell;
	IBOutlet NSColorWell	*_messageColorWell;
	IBOutlet NSColorWell	*_messageNameColorWell;
	IBOutlet NSColorWell	*_messageTitleColorWell;
	IBOutlet NSColorWell	*_messageAnchorColorWell;
	IBOutlet NSColorWell	*_messageFilteredColorWell;
	IBOutlet NSColorWell	*_messageTextEnhancedColorWell;
	
	IBOutlet NSButton		*_hasAnchorULButton;
	
	IBOutlet NSButton		*_threadsListFontButton;
	IBOutlet NSButton		*_newThreadFontButton;
	IBOutlet NSColorWell	*_newThreadColorWell;
	IBOutlet NSColorWell	*_threadsListColorWell;
	
	IBOutlet NSButton		*m_drawsGridCheckBox;
	IBOutlet NSButton		*m_drawStripedCheckBox;
	
	IBOutlet NSTextField	*m_rowHeightField;
	IBOutlet NSTextField	*m_spaceWidthField;
	IBOutlet NSTextField	*m_spaceHeightField;
	
	IBOutlet NSStepper		*m_rowHeightStepper;
	IBOutlet NSStepper		*m_spaceWidthStepper;
	IBOutlet NSStepper		*m_spaceHeightStepper;
	
	// その他
	IBOutlet NSColorWell	*_resPopUpBGColorWell;
	IBOutlet NSColorWell	*_resPopUpTextColorWell;
	IBOutlet NSButton		*_resPopUpUsesTCButton;
	IBOutlet NSButton		*_resPopUpIsSeeThroughButton;
	IBOutlet NSButton		*m_shouldAntialiasButton;
	
	IBOutlet NSButton		*_resPopUpScrollerIsSmall;
	
	IBOutlet NSButton		*m_replyFontButton;
	IBOutlet NSColorWell	*m_replyTextColorWell;
	IBOutlet NSColorWell	*m_replyBackgroundColorWell;
	
	// ステータス行
	IBOutlet NSMatrix		*_progressStyleRadioBotton;
}

- (IBAction) changeHasAnchorUnderline : (id) sender;
- (IBAction) changeResPopUpUsesTextColor : (id) sender;
- (IBAction) changeResPopUpSeeThrough : (id) sender;
- (IBAction) changeShouldThreadAntialias : (id) sender;
- (IBAction) changeColor : (id) sender;
- (IBAction) changeDrawsGrid : (id) sender;
- (IBAction) changeDrawStriped : (id) sender;
- (IBAction) changeTableRowSpace : (id) sender;
- (IBAction) fixRowHeightToFont : (id) sender;

- (IBAction) chooseProgressStyleRadioBotton : (id) sender;

- (IBAction) changePopUpScrollerSize : (id) sender;
@end
