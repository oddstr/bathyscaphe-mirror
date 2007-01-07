/**
  * $Id: CMRBrowser-Action.m,v 1.51 2007/01/07 17:04:23 masakih Exp $
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

extern BOOL isOptionKeyDown(unsigned flag_); // described in CMRBrowser-Delegate.m

@class IndexField;

@implementation CMRBrowser(Action)
static int expandAndSelectItem(NSDictionary *selected, NSArray *anArray, NSOutlineView *bLT)
{
	NSEnumerator *iter_ = [anArray objectEnumerator];
	id	eachItem;
	int index = -1;
	while (eachItem = [iter_ nextObject]) {
		if (![SmartBoardList isCategory: eachItem]) continue;
		// �J�e�S����������c
		if ([bLT isItemExpanded: eachItem]) continue; // ���łɊJ����Ă���Ȃ�X���[
		[bLT expandItem: eachItem]; // ���Ă���J�e�S�����J��

		index = [bLT rowForItem: selected];
		if (-1 != index) { // ������I
			return index;
		} else { // �J�e�S�����̃T�u�J�e�S�����J���Č�������
			index = expandAndSelectItem(selected, [eachItem objectForKey: BoardPlistContentsKey], bLT);
			if (-1 == index) // ���̃J�e�S���̂ǂ̃T�u�J�e�S���ɂ�������Ȃ�����
				[bLT collapseItem: eachItem]; // ���̃J�e�S���͕���
		}
	}
	return index;
}

- (IBAction) focus : (id) sender
{
    [[self window] makeFirstResponder : [[self threadsListTable] enclosingScrollView]];
}

- (void) selectRowWhoseNameIs : (NSString *) brdname_
{
	NSOutlineView	*bLT = [self boardListTable];
    SmartBoardList       *source;
    NSDictionary	*selected;
    int				index;

    source = (SmartBoardList *)[bLT dataSource];
    
    selected = [source itemForName : brdname_];

    if (nil == selected) { // �f���������I�ɒǉ�
		SmartBoardList	*defaultList_ = [[BoardManager defaultManager] defaultList];
		NSDictionary *willAdd_ = [defaultList_ itemForName : brdname_];
		if(nil == willAdd_) {
			NSLog(@"No data for board %@ found.", brdname_);
			return;
		} else {
			[source addItem : willAdd_ afterObject : nil];
			selected = [source itemForName : brdname_];
		}
	}
		
    index = [bLT rowForItem : selected];
    if (-1 == index) {
		index = expandAndSelectItem(selected, [source boardItems], bLT);
    } else if ([bLT isRowSelected: index]) { // ���łɑI���������s�͑I������Ă���
		UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
	}

    [bLT selectRow : index byExtendingSelection : NO];
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
		
		NSDictionary	*info_;
		NSString *path_ = [historyItem threadDocumentPath];
		
		info_ = [NSDictionary dictionaryWithObjectsAndKeys : 
						[historyItem BBSName] ,	ThreadPlistBoardNameKey,
						[historyItem identifier],	ThreadPlistIdentifierKey,
						nil];
		[CMRThreadDocument showDocumentWithContentOfFile : path_
											 contentInfo : info_];	
	}
}

#pragma mark Deletion
- (void) _showDeletionAlertSheet : (id) sender
						  ofType : (BSThreadDeletionType) aType
					  allowRetry : (BOOL) allowRetry
				   targetThreads : (NSArray *) threadsArray
{
	NSAlert		*alert_;
	NSString	*title_;
	NSString	*message_;

	alert_ = [[NSAlert alloc] init];

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
			NSEnumerator	*enumerator_;
			id				eachItem_;
			enumerator_ = [targets_ objectEnumerator];
			while ((eachItem_ = [enumerator_ nextObject])) {
				NSString	*path_ = [CMRThreadAttributes pathFromDictionary : eachItem_];
				if (NO == [self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
					NSBeep();
					NSLog(@"Deletion failed : %@", path_);
					continue;
				}
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
	switch(returnCode){
	case NSAlertFirstButtonReturn: // delete
		{
			NSEnumerator	*enumerator_;
			id				eachItem_;
			enumerator_ = [(NSArray *)contextInfo objectEnumerator];
			while ((eachItem_ = [enumerator_ nextObject])) {
				NSString	*path_ = [CMRThreadAttributes pathFromDictionary : eachItem_];
				if (NO == [self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
					NSBeep();
					NSLog(@"Deletion failed : %@", path_);
					continue;
				}
			}
		}
		break;
	case NSAlertThirdButtonReturn: // delete & reload
		{
			NSEnumerator	*enumerator_;
			id				eachItem_;
			enumerator_ = [(NSArray *)contextInfo objectEnumerator];
			while ((eachItem_ = [enumerator_ nextObject])) {
				NSString	*path_ = [CMRThreadAttributes pathFromDictionary : eachItem_];
				if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : NO]) {
					//[self reloadAfterDeletion : path_];
					//[[self threadsListTable] reloadData]; // really need?
				} else {
					NSBeep();
					NSLog(@"Deletion failed : %@, so reloading opreation has been canceled.", path_);
					continue;
				}
			}
		}
		break;
	case NSAlertSecondButtonReturn: // cancel
		break;
	default:
		break;
	}
	[alert release];
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

	[[CMRMainMenuManager defaultManager] synchronizeStatusFilteringMenuItemState];
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

- (IBAction) changeBrowserArrangement : (id) sender
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
}

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
	int	rowNum;
	id	bLT = [self boardListTable];

	rowNum = [bLT clickedRow];
	if (-1 == rowNum) return;
	
	id item_ = [bLT itemAtRow : rowNum];

	if ([bLT isExpandable : item_]) {
		if ([bLT isItemExpanded : item_]) [bLT collapseItem : item_];
		else [bLT expandItem : item_];
	}
}	
@end
