//
//  EditBoardSheetController.h - CMRBrowser-BLEditor.m から分割
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/04.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EditBoardSheetController : NSWindowController {
	IBOutlet NSTextField	*m_titleField;
	IBOutlet NSTextField	*m_messageField;
	IBOutlet NSTextField	*m_labelField;
	
	NSString				*m_enteredText;
}

- (NSTextField *) titleField;
- (NSTextField *) messageField;
- (NSTextField *) labelField;

- (NSString *) enteredText;
- (void) setEnteredText: (NSString *) someText;

- (IBAction) pressOK: (id) sender;
- (IBAction) pressCancel: (id) sender;
- (IBAction) pressHelp: (id) sender;

- (void) beginEditBoardSheetForWindow: (NSWindow *) targetWindow
						modalDelegate: (id) aDelegate
						  contextInfo: (id) contextInfo; // 通常、対象 Board を表すオブジェクトが渡される
- (void) beginEditCategorySheetForWindow: (NSWindow *) targetWindow
						   modalDelegate: (id) aDelegate
							 contextInfo: (id) contextInfo; // 通常、対象 Category を表すオブジェクトが渡される
- (void) beginAddCategorySheetForWindow: (NSWindow *) targetWindow
						  modalDelegate: (id) aDelegate
						    contextInfo: (id) contextInfo; // 通常、nil が渡される
@end

@interface NSObject(EBSDelegate)
- (void) controller: (EditBoardSheetController *) controller didEndSheet: (NSWindow *) sheet returnCode: (int) returnCode;
@end
