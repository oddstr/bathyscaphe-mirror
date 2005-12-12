//
//  AddBoardSheetController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/12.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SmartBoardList;

/*!
    @header AddBoardSheetController
    @abstract   掲示板リストの編集：「掲示板を追加」シートのインタフェース
    @discussion AddBoardSheetController は、「掲示板を追加」シートのコントローラです。標準リストからの選択、または
				手入力での掲示板追加をサポートします。
				掲示板の編集・カテゴリの作成／編集・項目の削除については、CMRBrowser 側で直接処理します。
*/

@interface AddBoardSheetController : NSWindowController {
	IBOutlet NSOutlineView	*m_defaultListOLView;
	IBOutlet NSSearchField	*m_searchField;

	IBOutlet NSTextFieldCell	*m_brdNameField;
	IBOutlet NSTextFieldCell	*m_brdURLField;

	IBOutlet NSButton		*m_OKButton;
	IBOutlet NSButton		*m_cancelButton;
	IBOutlet NSButton		*m_helpButton;
	
	@private
	NSString					*_currentSearchStr;
}

- (NSOutlineView *) defaultListOLView;
- (NSSearchField *) searchField;

- (NSTextFieldCell *) brdNameField;
- (NSTextFieldCell *) brdURLField;

- (NSButton *) OKButton;
- (NSButton *) cancelButton;
- (NSButton *) helpButton;

- (NSString *) currentSearchStr;
- (void) setCurrentSearchStr : (NSString *) newStr;

- (IBAction) searchBoards : (id) sender; 
- (IBAction) openHelp : (id) sender;
- (IBAction) close : (id) sender;
- (IBAction) doAddAndClose : (id) sender;

- (BOOL) addToUserListFromOLView : (id) sender;
- (BOOL) addToUserListFromForm : (id) sender;
- (BOOL) selectMatchedItem: (NSString*) keyword
                     items: (NSArray*) items;
- (void) selectMatchedItem: (NSString*) keyword;

- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contextInfo : (id		   ) info;
@end
