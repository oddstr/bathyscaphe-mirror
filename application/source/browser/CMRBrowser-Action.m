/**
  * $Id: CMRBrowser-Action.m,v 1.61 2007/07/27 10:26:39 tsawada2 Exp $
  * 
  * CMRBrowser-Action.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "CMRMainMenuManager.h"
#import "CMRHistoryManager.h"
#import "CMRThreadsList_p.h"
#import "FolderBoardListItem.h"
#import "CMRReplyDocumentFileManager.h"
extern BOOL isOptionKeyDown(unsigned flag_); // described in CMRBrowser-Delegate.m

@class IndexField;

@implementation CMRBrowser(Action)
static int expandAndSelectItem(BoardListItem *selected, NSArray *anArray, NSOutlineView *bLT)
{
	NSEnumerator *iter_ = [anArray objectEnumerator];
	id	eachItem;
	int index = -1;
	while (eachItem = [iter_ nextObject]) {
		// �u���Ă���J�e�S���v�����ɋ���������
		if (NO == [SmartBoardList isCategory: eachItem] || NO == [(FolderBoardListItem *)eachItem hasChildren]) continue;

		if (NO == [bLT isItemExpanded: eachItem]) [bLT expandItem: eachItem];

		index = [bLT rowForItem: selected];
		if (-1 != index) { // ������I
			return index;
		} else { // �J�e�S�����̃T�u�J�e�S�����J���Č�������
			index = expandAndSelectItem(selected, [(FolderBoardListItem *)eachItem items], bLT);
			if (-1 == index) // ���̃J�e�S���̂ǂ̃T�u�J�e�S���ɂ�������Ȃ�����
				[bLT collapseItem: eachItem]; // ���̃J�e�S���͕���
		}
	}
	return index;
}

- (int) searchRowForItemInDeep: (BoardListItem *) boardItem fromSource: (id) source forView: (NSOutlineView *) olView
{
	int	index = [olView rowForItem: boardItem];
	
	if (index == -1) {
		index = expandAndSelectItem(boardItem, source, olView);
	}
	
	return index;
}

#pragma mark -
- (IBAction) focus : (id) sender
{
    [[self window] makeFirstResponder : [[self threadsListTable] enclosingScrollView]];
}

- (void) selectRowWhoseNameIs : (NSString *) brdname_
{
	NSOutlineView	*bLT = [self boardListTable];
    SmartBoardList       *source;
	BoardListItem	*selected;
    int				index;

    source = (SmartBoardList *)[bLT dataSource];
    
    selected = [source itemForName : brdname_];

    if (nil == selected) { // �f���������I�ɒǉ�
		SmartBoardList	*defaultList_ = [[BoardManager defaultManager] defaultList];
		BoardListItem *willAdd_ = [defaultList_ itemForName: brdname_];
		if(nil == willAdd_) {
			NSLog(@"No BoardListItem for board %@ found.", brdname_);
			return;
		} else {
			[source addItem : willAdd_ afterObject : nil];
			selected = [source itemForName : brdname_];
		}
	}

	index = [self searchRowForItemInDeep: selected fromSource: [source boardItems] forView: bLT];	
	if (index == -1) return;
	if ([bLT isRowSelected: index]) { // ���łɑI���������s���I������Ă���
		UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
	} else {
		[bLT selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
	}
	[bLT scrollRowToVisible : index];
}

- (IBAction) reloadThreadsList : (id) sender
{
	[[self document] reloadThreadsList];
	
	int row_ = [[self threadsListTable] selectedRow];
	int mask_ = [CMRPref threadsListAutoscrollMask];
	
	if ((mask_ & CMRAutoscrollWhenTLUpdate) > 0 && row_ != -1){
		// ���X�g�őI������Ă��鍀�ڂ܂ŃX�N���[��
		[[self threadsListTable] scrollRowToVisible : row_];
	}else{
		// ���X�g�̐擪�܂ŃX�N���[��
		[[self threadsListTable] scrollRowToVisible : 0];
	}
}

- (void) openThreadsInThreadWindow : (NSArray *) threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*thread_;
	
	Iter_ = [threads objectEnumerator];
	while ((thread_ = [Iter_ nextObject])) {
		NSString				*path_;
		
		path_ = [CMRThreadAttributes pathFromDictionary : thread_];
		if ([self shouldShowContents] && [path_ isEqualToString: [self path]]) {
			continue;
		}
		[CMRThreadDocument showDocumentWithContentOfFile : path_
											 contentInfo : thread_];
	}
}
- (NSArray *) targetThreadsForAction : (SEL) action
{
	// currentlly no use action.
	NSEvent *event = [NSApp currentEvent];
	NSPoint mouse = [event locationInWindow];
	NSView *targetView = [[[self window] contentView] hitTest : mouse];
	NSArray *result = nil;
	//NSLog(@"%@", NSStringFromClass([targetView class]));
	if ([targetView isKindOfClass : [m_threadsListTable class]] /*|| nil == targetView*/) {	// �X���b�h���X�g����
		result = [self selectedThreadsReallySelected];
		if (0 == [result count]) {
			if (nil == [self threadURL]) {
				result = [NSArray empty];
			}
			result = [self selectedThreads];
		}
	} else if (nil == targetView) {
		// ���j���[�o�[�������̓L�[�C�x���g����
		// ���邢�̓c�[���o�[�{�^������
		// �X���b�h���X�g�Ƀt�H�[�J�X���������Ă��邩�ǂ����őΏۂ��X�C�b�`����B
		NSView *focusedView_ = (NSView *)[[self window] firstResponder];
		if (focusedView_ == [self textView] || [[[focusedView_ superview] superview] isKindOfClass : [IndexField class]]) {
			// �t�H�[�J�X���X���b�h�{���̈�ɂ���
			id selected = [self selectedThread];
			if (nil == selected) {
				result = [NSArray empty];
			} else {
				result = [NSArray arrayWithObject : selected];
			}
		} else { // �t�H�[�J�X������ȊO�̗̈�ɂ���F�X���b�h���X�g�̑I�����ڂ�D��
			result = [self selectedThreadsReallySelected];
			if (0 == [result count]) {
				if (nil == [self threadURL]) {
					result = [NSArray empty];
				}
				result = [self selectedThreads];
			}
		}	
	} else { //�@�X���b�h�{���̈悩��B
		id selected = [self selectedThread];
		if (nil == selected) {
			result = [NSArray empty];
		} else {
			result = [NSArray arrayWithObject : selected];
		}
	}
	return result;
}

- (IBAction) openBBSInBrowser : (id) sender
{
	NSURL		*url_;
	
	url_ = [[self document] boardURL];
	if (url_ != nil) {
		[[NSWorkspace sharedWorkspace] openURL : url_ inBackGround : [CMRPref openInBg]];
	} else {
		[super openBBSInBrowser : sender];
	}
}
/*
- (IBAction) openLogfile : (id) sender
{
	[self openThreadsLogFiles :  [self targetThreadsForAction : _cmd]];
}
- (IBAction) openInBrowser : (id) sender
{
	[self openThreadsInBrowser : [self targetThreadsForAction : _cmd]];
}
*/
- (IBAction) openSelectedThreads : (id) sender
{
	[self openThreadsInThreadWindow : [self targetThreadsForAction : _cmd]];
}
- (IBAction) selectThread : (id) sender
{
	// ����̃��f�B�t�@�C�A�E�L�[��������Ă���Ƃ���
	// �N���b�N�ō��ڂ�I�����Ă��X���b�h��ǂݍ��܂Ȃ�
	if (isOptionKeyDown([[NSApp currentEvent] modifierFlags]))
		return;
	
	if (NO == [self shouldShowContents])
		return;
	
	[self showSelectedThread : self];
}
- (BOOL) shouldLoadThreadAtPath : (NSString *) filepath
{
	if (NO == [self shouldShowContents]) return NO;
	
	return (NO == [filepath isSameAsString : [self path]] || NO == [[NSFileManager defaultManager] fileExistsAtPath : filepath]);
}
- (void) showThreadAtRow : (int) rowIndex
{
	NSTableView				*tbView_ = [self threadsListTable];
	NSDictionary			*thread_;
	NSString				*path_;
	
	NSAssert2(
		(rowIndex >= 0 && rowIndex < [tbView_ numberOfRows]),
		@"  rowIndex was over. size = %d but was %d",
		[tbView_ numberOfRows],
		rowIndex);
	
	thread_ = [[self currentThreadsList] 
				threadAttributesAtRowIndex:rowIndex inTableView:tbView_];
	path_ = [CMRThreadAttributes  pathFromDictionary : thread_];
	
	if ([self shouldLoadThreadAtPath : path_]) {
		[self setThreadContentWithFilePath : path_
								 boardInfo : thread_];
		// �t�H�[�J�X
		//if ([CMRPref moveFocusToViewerWhenShowThreadAtRow]) {
			[[self window] makeFirstResponder : [self textView]];
		//}
		[self synchronizeWindowTitleWithDocumentName];
	}
}

- (IBAction) showSelectedThread : (id) sender
{
	if (-1 == [[self threadsListTable] selectedRow]) return;
	if ([[self threadsListTable] numberOfSelectedRows] != 1) return;
	
	[self showThreadAtRow : [[self threadsListTable] selectedRow]];
}


/*
	2005-06-06 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	Key Binding �̕֋X��}�邽�߂����̃��\�b�h�B
	return �L�[�ɑΉ�����A�N�V�����ɂ�����w�肵�Ă����ƁA2�y�C���̂Ƃ��A3�y�C���̂Ƃ�
	���ꂼ��ɉ����Ď����I�ɓK�؂ȓ���i�ʑ��ŊJ���A�����ɕ\������j���Ăяo����Ƃ����d�|���B
*/
- (IBAction) showOrOpenSelectedThread : (id) sender
{
	if ([self shouldShowContents]) {
		[self showSelectedThread : sender];
	} else {
		[self openSelectedThreads : sender];
	}
}
/*
#pragma mark MeteorSweeper Key Binding Action Additions
- (IBAction) scrollPageDownThViewOrThListProperly: (id) sender
{
	if ([CMRPref moveFocusToViewerWhenShowThreadAtRow] || ![self shouldShowContents]) {
		[[[self threadsListTable] enclosingScrollView] pageDown: sender];
	} else {
		[[self textView] scrollPageDown: sender];
	}
}

- (IBAction) scrollPageUpThViewOrThListProperly: (id) sender
{
	if ([CMRPref moveFocusToViewerWhenShowThreadAtRow] || ![self shouldShowContents]) {
		[[[self threadsListTable] enclosingScrollView] pageUp: sender];
	} else {
		[[self textView] scrollPageUp: sender];
	}
}

- (IBAction) scrollPageDownThreadViewWithoutFocus: (id) sender
{
	if(![self shouldShowContents]) {
		NSBeep();
		return;
	}
	
	[[self textView] scrollPageDown: sender];
}

- (IBAction) scrollPageUpThreadViewWithoutFocus: (id) sender
{
	if(![self shouldShowContents]) {
		NSBeep();
		return;
	}
	
	[[self textView] scrollPageUp: sender];
}
*/
#pragma mark History Menu
- (IBAction) showThreadWithMenuItem : (id) sender
{
	// ���̔̃X���b�h�Ɉړ����邱�Ƃ��l���A�X���ꗗ�ł̑I����Ԃ��������Ă���
	if ([self shouldShowContents]) {
		[[self threadsListTable] deselectAll: nil];
		[super showThreadWithMenuItem : sender];
	} else {
		id historyItem = nil;

		if ([sender respondsToSelector : @selector(representedObject)]) {
			id o = [sender representedObject];
			historyItem = o;
		}
		
		[CMRThreadDocument showDocumentWithHistoryItem: historyItem];	
	}
}

#pragma mark Deletion
- (BOOL) forceDeleteThreads: (NSArray *) threads
{
	NSMutableArray	*array_ = [NSMutableArray arrayWithCapacity: [threads count]];
	NSArray			*arrayWithReplyFiles_;
	NSEnumerator	*iter_ = [threads objectEnumerator];
	NSFileManager	*fm = [NSFileManager defaultManager];
	id				eachItem_;
	NSString		*path_;

	while (eachItem_ = [iter_ nextObject]) {
		path_ = [CMRThreadAttributes pathFromDictionary: eachItem_];
		if ([fm fileExistsAtPath: path_]) {
			[array_ addObject: path_];
		} else {
			NSLog(@"File does not exist (although we're going to remove it!)\n%@", path_);
		}
	}

	arrayWithReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray: array_];
	return [[CMRTrashbox trash] performWithFiles: arrayWithReplyFiles_ fetchAfterDeletion: NO];
}

- (void) _showDeletionAlertSheet : (id) sender
						  ofType : (BSThreadDeletionType) aType
					  allowRetry : (BOOL) allowRetry
				   targetThreads : (NSArray *) threadsArray
{
	NSAlert		*alert_;
	NSString	*title_;
	NSString	*message_;

	alert_ = [[[NSAlert alloc] init] autorelease];

	switch(aType) {
	case BSThreadAtViewerDeletionType:
	{
		NSString *tmp_ = [self localizedString : kDeleteThreadTitleKey];
		NSString *threadTitle_ = [CMRThreadAttributes threadTitleFromDictionary : [threadsArray lastObject]];
		title_ = [NSString stringWithFormat : tmp_, threadTitle_];
		message_ = [self localizedString : kDeleteThreadMessageKey];
	}
		break;
	case BSThreadAtBrowserDeletionType:
		title_ = [self localizedString : kBrowserDelThTitleKey];
		message_ = [self localizedString : kBrowserDelThMsgKey];
		break;
	case BSThreadAtFavoritesDeletionType:
		title_ = [self localizedString : kDeleteFavTitleKey];
		message_ = [self localizedString : kDeleteFavMsgKey];
		break;
	default : 
		title_ = @"Implementaion Error";
		message_ = @"Please report that You see this message. Oh, you should press Cancel button. Sorry.";
		break;
	}
	
	[alert_ setMessageText : title_];
	[alert_ setInformativeText : message_];
	[alert_ addButtonWithTitle : [self localizedString : kDeleteOKBtnKey]];
	[alert_ addButtonWithTitle : [self localizedString : kDeleteCancelBtnKey]];
	if (allowRetry) {
		NSButton	*deleteAndReloadBtn_;
		deleteAndReloadBtn_ = [alert_ addButtonWithTitle : [self localizedString : kDeleteAndReloadBtnKey]];
		[deleteAndReloadBtn_ setKeyEquivalent : @"r"];
	}

	//NSBeep();
	[alert_ beginSheetModalForWindow : [self window]
					   modalDelegate : self
					  didEndSelector : @selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:)
					     contextInfo : [threadsArray retain]];
}

- (IBAction) deleteThread : (id) sender
{
	NSArray			*targets_ = [self targetThreadsForAction : _cmd];
	int				numOfSelected_ = [targets_ count];
	
	if (numOfSelected_ == 0) return;
	
	if (numOfSelected_ == 1) {
		NSString *path_ = [CMRThreadAttributes pathFromDictionary : [targets_ lastObject]];
		if ([CMRPref quietDeletion]) {
			if (NO == [self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
				NSBeep();
				NSLog(@"Deletion failed : %@", path_);
			}
		} else {
			[self _showDeletionAlertSheet : sender
								   ofType : BSThreadAtViewerDeletionType
							   allowRetry : ([CMRPref isOnlineMode] && [self shouldShowContents] && [[self path] isEqualToString : path_])
							targetThreads : targets_];
		}
	} else {
		if ([CMRPref quietDeletion]) {
			if (NO == [self forceDeleteThreads: targets_]) {
				NSBeep();
				NSLog(@"CMRTrashbox returns some error.");
			}			
		} else {
			[self _showDeletionAlertSheet : sender
								   ofType : ([[self currentThreadsList] isFavorites] ? BSThreadAtFavoritesDeletionType
																					 : BSThreadAtBrowserDeletionType)
							   allowRetry : NO
							targetThreads : targets_];
		}
	}
}

- (void) _threadDeletionSheetDidEnd : (NSAlert *) alert
						 returnCode : (int      ) returnCode
						contextInfo : (void	   *) contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		if (NO == [self forceDeleteThreads: (NSArray *)contextInfo]) {
			NSBeep();
			NSLog(@"CMRTrashbox returns some error.");
		}
	} else if (returnCode == NSAlertThirdButtonReturn) {
		id item_ = [(NSArray *)contextInfo lastObject];
		NSString *path_ = [CMRThreadAttributes pathFromDictionary: item_];
		if (NO == [self forceDeleteThreadAtPath: path_ alsoReplyFile: NO]) {
			NSBeep();
			NSLog(@"Deletion failed : %@, so reloading opreation has been canceled.", path_);
		}
	}
}

#pragma mark Filter, Search
- (IBAction) selectFilteringMask : (id) sender
{
	NSNumber	*represent_;
	int			mask_;
	
	if (NO == [sender respondsToSelector : @selector(representedObject)]) {
		UTILDebugWrite(@"Sender must respondsToSelector : -representedObject");
		return;
	}
	
	represent_ = [sender representedObject];
	UTILAssertKindOfClass(represent_, NSNumber);

	mask_ = [represent_ unsignedIntValue];
	[self changeThreadsFilteringMask : mask_];

//	[[CMRMainMenuManager defaultManager] synchronizeStatusFilteringMenuItemState];
}

- (void) clearSearchFilter
{
	[[self document] setSearchString: nil];
	
	// �������ʂ̕\��@�^�C�g���o�[������
	[self synchronizeWindowTitleWithDocumentName];
}

- (void) synchronizeWithSearchField
{
	[[self document] searchThreadsInListWithCurrentSearchString];
	[self synchronizeWindowTitleWithDocumentName];

	[[self threadsListTable] reloadData];
}

- (IBAction) searchThread : (id) sender
{
	[self synchronizeWithSearchField];
}

- (IBAction)collapseOrExpandThreadViewer:(id)sender
{
	[self splitView:[self splitView] didDoubleClickInDivider:0];
}

- (BOOL) ifSearchFieldIsInToolbar
{
	/*
		2005-02-01 tsawada2<ben-sawa@td5.so-net.ne.jp>
		�c�[���o�[�Ɍ����t�B�[���h���\������Ă��邩�`�F�b�N���Đ^�U�l��Ԃ��B
		�����Łu�\������Ă���v�Ƃ́A�ȉ��̂��ׂĂ̏����𖞂����Ƃ��Ɍ���F
		1.�c�[���o�[�̕\�����[�h���u�A�C�R���ƃe�L�X�g�v�܂��́u�A�C�R���̂݁v
		2.�����t�B�[���h���c�[���o�[����͂ݏo���Ă��Ȃ�
	*/
	NSToolbar	*toolBar_;
	
	toolBar_ = [[self window] toolbar];
	if (nil == toolBar_) return NO;
	
	if ([toolBar_ isVisible] == NO || [toolBar_ displayMode] == NSToolbarDisplayModeLabelOnly) {
		return NO;
	} else {
		id obj;
		NSEnumerator *enumerator_;

		enumerator_ = [[toolBar_ visibleItems] objectEnumerator];
		while((obj = [enumerator_ nextObject]) != nil) {
			if ([[obj itemIdentifier] isEqualToString : kToolbarSearchFieldItemKey])
				return YES;
		}
		return NO;
	}
}

// ���X�g�����F�V�[�g�\��
- (IBAction) showSearchThreadPanel : (id) sender
{
	if ([self ifSearchFieldIsInToolbar]) {
		// �c�[���o�[�Ɍ����t�B�[���h�������Ă���Ƃ��́A�P�ɂ����Ƀt�H�[�J�X���ړ����邾���i�V�[�g�͕\�����Ȃ��j
		[[self searchField] selectText : sender];
	} else {
		id		contentView_;
		NSRect	frame_;

		contentView_ = [[self searchField] retain];
		// �����t�B�[���h�̕��� 300px ���Z���ꍇ�́A�ꗥ 300px �ɌŒ肵�ĕ\��
		// �����蒷���ꍇ�́A���̂܂ܕ\��
		frame_ = [contentView_ frame];
		if (frame_.size.height < 300)
			[contentView_ setFrameSize : NSMakeSize(300, frame_.size.height)];

		[[self listSorterSheetController] beginSheetModalForWindow : [self window]
													 modalDelegate : self
													   contentView : contentView_
													   contextInfo : nil];
		[contentView_ release];
	}
}

- (void) controller : (CMRAccessorySheetController *) aController
		sheetDidEnd : (NSWindow					 *) sheet
		contentView : (NSView					 *) contentView
		contextInfo : (id						  ) info;
{
	// Nothing to be done.
}

#pragma mark View Menu

/*- (IBAction) changeBrowserArrangement : (id) sender
{
	NSNumber	*represent_;
	
	if (NO == [sender respondsToSelector : @selector(representedObject)]) {
		UTILDebugWrite(@"Sender must respondsToSelector : -representedObject");
		return;
	}
	
	represent_ = [sender representedObject];
	UTILAssertKindOfClass(represent_, NSNumber);
	[CMRPref setIsSplitViewVertical : [represent_ boolValue]];
	[[CMRMainMenuManager defaultManager] synchronizeBrowserArrangementMenuItemState];
	
	[self setupSplitView];
	[[self splitView] resizeSubviewsWithOldSize : [[self splitView] frame].size];
}*/

- (IBAction) collapseOrExpandBoardList : (id) sender
{
	RBSplitSubview	*tmp_;
	
	tmp_ = [self boardListSubView];
	if ([tmp_ isCollapsed]) {
		[tmp_ expand];
	} else {
		[tmp_ collapse];
	}
}

#pragma mark -

/*
NSTableView action, doubleAction �̓J�����̃N���b�N�ł�
��������̂ŁA�ȉ��̃��\�b�h�Ńt�b�N����B
*/
- (IBAction) tableViewActionDispatch : (id        ) sender
						   actionKey : (NSString *) aKey
					   defaultAction : (SEL       ) defaultAction
{
	SEL				action_;
	
	// �J�����̃N���b�N
	if (-1 == [[self threadsListTable] clickedRow])
		return;

	// �ݒ肳�ꂽ�A�N�V�����Ƀf�B�X�p�b�`
	action_ = SGTemplateSelector(aKey);
	if (NULL == action_ || _cmd == action_)
		action_ = defaultAction;
	
	[NSApp sendAction:action_ to:self from:sender];
}
- (IBAction) listViewAction : (id) sender
{
	[self tableViewActionDispatch : sender
						actionKey : kThreadsListTableActionKey
					defaultAction : @selector(selectThread:)];
}
- (IBAction) listViewDoubleAction : (id) sender
{
	[self tableViewActionDispatch : sender
						actionKey : kThreadsListTableDoubleActionKey
					defaultAction : @selector(openSelectedThreads:)];
}
- (IBAction) boardListViewDoubleAction : (id) sender
{
	UTILAssertKindOfClass(sender, NSOutlineView);

	int	rowNum = [sender clickedRow];
	if (-1 == rowNum) return;
	
	id item_ = [sender itemAtRow : rowNum];

	if ([sender isExpandable : item_]) {
		if ([sender isItemExpanded : item_]) [sender collapseItem : item_];
		else [sender expandItem : item_];
	}
}	
@end
