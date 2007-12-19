//
//  EditBoardSheetController.h - CMRBrowser-BLEditor.m から分割
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/04.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface EditBoardSheetController : NSWindowController {
	IBOutlet NSTextField	*m_messageField;
	IBOutlet NSTextField	*m_warningField;
	
	NSString				*m_enteredText;
	BOOL					m_partialStringIsValid;

@private
	BOOL	m_shouldValidate;
}

- (NSTextField *)messageField;
- (NSTextField *)warningField;

- (NSString *)enteredText;
- (void)setEnteredText:(NSString *)someText;

- (BOOL)partialStringIsValid;
- (void)setPartialStringIsValid:(BOOL)flag;

- (IBAction)pressOK:(id)sender;
- (IBAction)pressCancel:(id)sender;
- (IBAction)pressHelp:(id)sender;

- (void)beginEditBoardSheetForWindow:(NSWindow *)targetWindow
					   modalDelegate:(id)aDelegate
						 contextInfo:(id)contextInfo; // 通常、対象 (Board)BoardListItemが渡される
- (void)beginEditCategorySheetForWindow:(NSWindow *)targetWindow
						  modalDelegate:(id)aDelegate
							contextInfo:(id)contextInfo; // 通常、対象 (Folder)BoardListItem が渡される
- (void)beginAddCategorySheetForWindow:(NSWindow *)targetWindow
						 modalDelegate:(id)aDelegate
						   contextInfo:(id)contextInfo; // 通常、nil が渡される
@end


@interface NSObject(EBSDelegate)
- (void)controller:(EditBoardSheetController *)controller didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode;
@end
