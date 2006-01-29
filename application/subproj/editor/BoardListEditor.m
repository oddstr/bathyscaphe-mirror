/**
 * $Id: BoardListEditor.m,v 1.3.4.2 2006/01/29 17:10:34 masakih Exp $
 * 
 * BoardListEditor.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import "BoardListEditor_p.h"



@implementation BoardListEditor
- (id) init
{
	if (self = [super initWithWindowNibName : @"BoardListEditor"]) {
		;
	}
	return self;
}
- (id) initWithDefaultList : (SmartBoardList *) defaultList 
				  userList : (SmartBoardList *) userList;
{
	if (self = [self init]) {
		_defaultList = [defaultList retain];
		_userList = [userList retain];
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_userList release];
	[_defaultList release];
	[super dealloc];
}

- (void) awakeFromNib
{
	[self setupUIComponents];
}


- (NSString *) localizedString : (NSString *) key
{
	return [[NSBundle bundleForClass : [self class]]
					localizedStringForKey : key
							        value : key
						            table : nil];
}

- (SmartBoardList *) defaultList
{
	return _defaultList;
}
- (SmartBoardList *) userList
{
	return _userList;
}



- (IBAction) reloadDefaultList : (id) sender
{
	NSArray *fileTypes = [NSArray arrayWithObjects:@"brd", nil];
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];

	[openPanel setAllowsMultipleSelection:NO];
	
	[openPanel
		beginSheetForDirectory : NSHomeDirectory()
				  file : nil
			     types : fileTypes
		modalForWindow : [self window]
		 modalDelegate : self
		didEndSelector : @selector(didEndBrdReloadSheet:returnCode:contextInfo:)
		   contextInfo : nil];
}

- (NSArray *) defaultListWithContentsOfFile : (NSString *) thePath
{
	NSString *contents_ = nil;
	NSArray  *lines_;
	
	NSEnumerator	*iter_			= nil;
	NSArray			*array			= nil;
	NSMutableArray	*root			= [NSMutableArray array];
	NSMutableArray	*boardsArray	= nil;
	NSString		*categoryName	= nil;

    {
		NSData          *data;
		TextEncoding	enc;
		
		
		data = [[NSData alloc] initWithContentsOfFile : thePath];

        enc = CF2NSEncoding(kCFStringEncodingDOSJapanese);
        contents_ = [NSString stringWithData:data encoding:enc];
        if (nil == contents_) {
            enc = CF2NSEncoding(kCFStringEncodingMacJapanese);
            contents_ = [NSString stringWithData:data encoding:enc];
        }
        [data release];
    }

	lines_ = [contents_ componentsSeparatedByNewline];
	iter_ = [lines_ objectEnumerator];
	
	// 一行めは飛ばす
	[iter_ nextObject];

	while ((array = [[iter_ nextObject] componentsSeparatedByString:@"\t"])) {
		if ([array count] == 2) {
			NSDictionary *categoryDict;
			
			//要素数が2ならカテゴリ名
			categoryName = [array objectAtIndex : 0];
			boardsArray  = [NSMutableArray array];
			categoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
									boardsArray, BoardPlistContentsKey,
									categoryName, BoardPlistNameKey,
									nil];
			[root addObject : categoryDict];
		}else if ([array count] > 2 && boardsArray != nil) {
			// 2以上なら掲示板
			NSString     *server_;		//サーバ名
			NSString     *path_;		//パス
			NSString     *name_;		//掲示板名
			NSString     *url_;
			NSDictionary *board_;
			
			server_ = [array objectAtIndex : 1];
			path_   = [array objectAtIndex : 2];
			url_    = [NSString stringWithFormat:@"http://%@/%@/", server_, path_];
			name_   = ([array count] > 3) ? [array objectAtIndex : 3]
										  : @"Untitled";
			board_  = [NSDictionary dictionaryWithObjectsAndKeys:
											url_,  BoardPlistURLKey,
											name_, BoardPlistNameKey,
											nil];
			[boardsArray addObject : board_];
		}
	}
	return root;
}

- (IBAction) addToUserList : (id) sender
{
	/*ユーザ定義掲示板リスト*/
	int usr_rowIndex_;				//選択インデックス
	NSDictionary *usr_selItem_;		//選択された項目
	/*ユーザ定義掲示板リスト*/
	NSEnumerator *def_iter_;		//選択された項目インデックスの列挙子
	NSNumber     *def_index_;		//選択された項目インデックス
	
	NSMutableArray *error_names_;	//追加できなかった項目
	
	error_names_ = [NSMutableArray array];
	
	usr_rowIndex_ = [[self userListTable] selectedRow];
	//何も選択されていない場合はnil。
	//ルート要素の末尾に追加する。
	usr_selItem_  = [[self userListTable] itemAtRow : usr_rowIndex_];
	
	def_iter_ = [[self defaultListTable] selectedRowEnumerator];
	
	while (def_index_ = [def_iter_ nextObject]) {
		NSDictionary *item_;		//選択中の項目
		
		
		item_ = [[self defaultListTable] itemAtRow : [def_index_ intValue]];
		if (NO == [[self userList] outlineView : [self userListTable]
									   addItem : item_
						             afterItem : usr_selItem_]) {
			NSString     *name_;		//掲示板またはカテゴリの名前

			name_ = [item_ objectForKey : @"Name"];
			//重複するエントリのため、追加できない。
			[error_names_ addObject : name_];
		}
	}
	
	if ([error_names_ count] > 0) {
		NSString *message_;
		
		message_ = [error_names_ componentsJoinedByString:@"\", \""];
		message_ = [NSString stringWithFormat : @"\"%@\"",  message_];

		NSBeginInformationalAlertSheet(
			[self localizedString : @"Same Name Exists"],
			[self localizedString : @"OK"],
			nil,
			nil,
			[self window],
			self,
			NULL,
			NULL,
			nil,
			[self localizedString : @"%@ are not added to user defined list."],
			message_
		);
	}
}

//- (IBAction) changeCreateView : (id) sender
//{
//}

- (IBAction) createGroup : (id) sender
{
	[[self categoryEditNameField] setStringValue : [self localizedString : @"Untitled"]];

	[[NSApplication sharedApplication]
		   beginSheet : [self categoryEditSheet]
	   modalForWindow : [self window]
	    modalDelegate : self
	   didEndSelector : @selector(didEndCategoryEditSheet:returnCode:contextInfo:)
	      contextInfo : nil];
}

- (IBAction) createItem : (id) sender
{
	[[self boardAddNameCell] setStringValue : @""];
	[[self boardAddURLCell] setStringValue : @""];

	[[NSApplication sharedApplication]
		   beginSheet : [self boardAddSheet]
	   modalForWindow : [self window]
	    modalDelegate : self
	   didEndSelector : @selector(didEndAddBoardSheet:returnCode:contextInfo:)
	      contextInfo : nil];
}

- (IBAction) editUserList : (id) sender
{
	int           rowIndex_;
	NSDictionary *item_;
	
	NSWindow *sheet_;
	SEL didEndSel_;
	
	rowIndex_ = 0;
	item_ = nil;
	sheet_ = nil;
	didEndSel_ = NULL;
	
	rowIndex_ = [[self userListTable] selectedRow];
	if (-1 == rowIndex_) return;
	
	item_ = [[self userListTable] itemAtRow : rowIndex_];
	
	if ([[[self userList] class] isFavorites : item_]) return;
	if ([[[self userList] class] isBoard : item_]) {
		sheet_ = [self boardEditSheet];
		didEndSel_ = @selector(didEndBoardEditSheet:returnCode:contextInfo:);
		[[self boardEditNameCell] 
			setStringValue : [item_ objectForKey : BoardPlistNameKey]];
		[[self boardEditURLCell]
			setStringValue : [item_ objectForKey : BoardPlistURLKey]];
	}else if ([[[self userList] class] isCategory : item_]) {
		sheet_ = [self categoryEditSheet];
		didEndSel_ = @selector(didEndCategoryEditSheet:returnCode:contextInfo:);
		[[self categoryEditNameField]
			setStringValue : [item_ objectForKey : BoardPlistNameKey]];
	} else {
		return;
	}
	
	
	[[NSApplication sharedApplication]
		   beginSheet : sheet_
	   modalForWindow : [self window]
	    modalDelegate : self
	   didEndSelector : didEndSel_
	      contextInfo : (void*)item_];
}

- (IBAction) endEditSheet : (id) sender
{
	
	[[NSApplication sharedApplication]
		   endSheet : [sender window]
		 returnCode : ([sender tag] == 1) ? NSOKButton : NSCancelButton];
}

- (IBAction) moveItem : (id) sender
{
     int usr_rowIndex_;
     NSDictionary *usr_selItem_;
     int direction_;
	
    // Multipul-selection was not supported.
     if ( 1 != [[self userListTable] numberOfSelectedRows] ) {
         return;
     }
     usr_rowIndex_ = [[self userListTable] selectedRow];
     usr_selItem_  = [[self userListTable] itemAtRow : usr_rowIndex_];
     if ( NULL == usr_selItem_ ) return;
     direction_ = [(NSControl*)sender tag];
     [[self userList] moveItem:usr_selItem_ direction:direction_];
}

//- (IBAction) removeAllFromUserList : (id) sender
//{
//}

- (IBAction) removeFromUserList : (id) sender
{
    NSBeginInformationalAlertSheet(
		[self localizedString : @"Remove Selected Items"],
		[self localizedString : @"OK"],
		[self localizedString : @"Cancel"],
        nil,
        [self window],
        self,
        NULL,
        @selector(didEndRemoveSheet:returnCode:contextInfo:),
        sender,
        [self localizedString : @"Do you want to remove selected items from user defined list?"]);
}

//- (IBAction) resetUserList : (id) sender
//{
//}

- (IBAction) launchBW : (id) sender
{
	NSBundle* mainBundle;
    NSString* fileName;

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource:@"BWAgent" ofType:@"app"];
	
    [[NSWorkspace sharedWorkspace] launchApplication:fileName];
}

/* sheet delegate method */
- (void) didEndBrdReloadSheet : (NSOpenPanel *) sheet
                   returnCode : (int          ) returnCode
                  contextInfo : (void        *) contextInfo
{
	NSArray		*newItems_;
	NSString	*brdpath_;
	NSString	*path_;
	BOOL		result_;
	
	if (NO == (returnCode == NSOKButton)) return;
	
	brdpath_ = [sheet filename];
	newItems_ = [self defaultListWithContentsOfFile : brdpath_];
	
	if (nil == newItems_ || 0 == [newItems_ count]) {
		NSBeginInformationalAlertSheet(
			[self localizedString : @"CanNotLoadBrdFile"],
			[self localizedString : @"OK"],
			nil,
			nil,
			[self window],
			self,
			NULL,
			NULL,
			nil,
			[self localizedString : @"Reason:CanNotLoadBrdFile"],
			brdpath_
		);
		return;
	}
	
	path_ = [[[self defaultList] class] defaultBoardListPath];
	result_ = [newItems_ writeToFile : path_
			              atomically : YES];
	if (result_) {
		[[self defaultList] synchronizeWithFile : path_];
		[[self defaultListTable] reloadData];
	} else {
		NSBeginInformationalAlertSheet(
			[self localizedString : @"CanNotSaveBrdFile"],
			[self localizedString : @"OK"],
			nil,
			nil,
			[self window],
			self,
			NULL,
			NULL,
			nil,
			[self localizedString : @"Reason:CanNotSaveBrdFile"],
			path_
		);
	}
}

- (void) didEndAddBoardSheet : (NSWindow *) sheet
				  returnCode : (int) returnCode
				 contextInfo : (void *) contextInfo
{
	if ([self boardAddSheet] != sheet) return;
	
	if (NSOKButton == returnCode) {
		NSMutableDictionary *newItem_;
		NSString *name_;
		NSString *url_;

		name_ = [[self boardAddNameCell] stringValue];
		url_ = [[self boardAddURLCell] stringValue];
		
		if ([name_ isEqualToString : @""]|[url_ isEqualToString : @""]) {
			// 名前またはURLが入力されていない場合は中止
			NSBeep();
			[sheet close];
			return;
		} else {
			id userList = [self userList];

			if ([userList containsItemWithName : name_  ofType : (BoardListFavoritesItem | BoardListBoardItem)]) {
				[sheet close];	
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"],
					nil,
					nil,
					[self window],
					self,
					NULL,
					NULL,
					nil,
					[self localizedString : @"So cannot add board."]
				);
				return;
			}

			int rowIndex;
			id selectedItem;
		
			newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys :
							name_,
							BoardPlistNameKey,
							url_,
							BoardPlistURLKey,
							nil];

			rowIndex = [[self userListTable] selectedRow];

			selectedItem = (rowIndex >= 0) 
						? [[self userListTable] itemAtRow : rowIndex]
						: nil;
	
			if ([[userList class] isFavorites : selectedItem]){
				[userList addItem:newItem_ afterObject:nil];
			}else{
				[userList addItem:newItem_ afterObject:selectedItem];
			}
			[[self userListTable] reloadData];
		}
	}
	[sheet close];
}


- (void) didEndBoardEditSheet : (NSWindow *) sheet
                   returnCode : (int       ) returnCode
                  contextInfo : (void     *) contextInfo
{
	if ([self boardEditSheet] != sheet) return;
	
	if (NSOKButton == returnCode) {
		NSMutableDictionary *newItem_;
		NSString *name_;
		NSString *url_;
		
		name_ = [[self boardEditNameCell] stringValue];
		url_ = [[self boardEditURLCell] stringValue];
		newItem_ = (NSMutableDictionary *)contextInfo;
		
		// overwrite if duplicate entry
		[[self userList] item : newItem_
					  setName : name_
					   setURL : url_];
		[[self userListTable] reloadData];
	}
	
	[sheet close];
}

- (void) didEndCategoryEditSheet : (NSWindow *) sheet
                      returnCode : (int       ) returnCode
                     contextInfo : (void     *) contextInfo
{
	if ([self categoryEditSheet] != sheet) return;
	
	if (NSOKButton == returnCode) {

		NSMutableDictionary *newItem_;
		NSString *name_;
		id userList = [self userList];
	
		name_ = [[self categoryEditNameField] stringValue];

		if ([name_ isEqualToString : @""]) {
			NSBeep();
			[sheet close];
			return;
		}
		// 既存カテゴリの編集でシートを表示した時は、contextInfo に MutableDIctionary が入っている。
		// 新規カテゴリ作成でシートを表示した時は、contextInfo が nil になっている。
		if (contextInfo != nil) {
			// 既存カテゴリの編集
			NSString *oldname_;
		
			newItem_ = (NSMutableDictionary *)contextInfo;
			oldname_ = [newItem_ objectForKey : BoardPlistNameKey];
		
			if ([userList containsItemWithName : name_ ofType : (BoardListFavoritesItem | BoardListCategoryItem)] &&
				(NO == [oldname_ isEqualToString : name_])) {
				[sheet close];	
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"],
					nil,
					nil,
					[self window],
					self,
					NULL,
					NULL,
					nil,
					[self localizedString : @"So cannot change name."]
				);
				return;
			}
			[userList item : newItem_
				   setName : name_
					setURL : nil];

		} else {
			// 新規カテゴリの追加
			if ([userList containsItemWithName : name_ ofType : (BoardListFavoritesItem | BoardListCategoryItem)]) {
				[sheet close];	
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"],
					nil,
					nil,
					[self window],
					self,
					NULL,
					NULL,
					nil,
					[self localizedString : @"So cannot add category."]
				);
				return;
			}

			int rowIndex;
			id selectedItem;
	
			newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys :
						name_,
						BoardPlistNameKey,
						[NSMutableArray array],
						BoardPlistContentsKey,
						nil];
	
			// 何も選択されていない状態では掲示板自体（配列）
			// お気に入りが選択された場合も同様に考える。
			rowIndex = [[self userListTable] selectedRow];
			selectedItem = (rowIndex >= 0) ? [[self userListTable] itemAtRow : rowIndex]: nil;
	
			if ([[userList class] isFavorites : selectedItem]){
				[userList addItem:newItem_ afterObject:nil];
			}else{
				[userList addItem:newItem_ afterObject:selectedItem];
			}
		}
		[[self userListTable] reloadData];
	}
	
	[sheet close];
}

- (void) didEndRemoveSheet : (NSWindow *) theWindow
                returnCode : (int       ) returnCode
               contextInfo : (void     *) contextInfo
{
	NSEnumerator	*iter_;
	id				rowIndex_;
	
	if (returnCode != NSOKButton)
		return;
	
	iter_ = [[[[self userListTable] selectedRowEnumerator] allObjects] reverseObjectEnumerator];
	while (rowIndex_ = [iter_ nextObject]) {
		NSDictionary	*item_;
		int				index_;
		
		index_ = [rowIndex_ intValue];
		item_ = [[self userListTable] itemAtRow : index_];
		[[self userList] removeItemWithName : [item_ objectForKey : BoardPlistNameKey]
									 ofType : [item_ type]];
	}
	[[self userListTable] reloadData];
	[[self userListTable] deselectAll : nil];
}

// NSWindowController
- (IBAction) showWindow : (id) sender
{
	[super showWindow : sender];
	[[self defaultListTable] reloadData];
	[[self userListTable] reloadData];
}

- (IBAction) openHelp : (id) sender
{
	[[NSHelpManager sharedHelpManager] findString:[self localizedString : @"FindStr_"] inBook:[self localizedString : @"HelpBookName"]];
}
@end
