/**
  * $Id: CMRBrowser-Action.m,v 1.33 2006/01/12 18:00:24 tsawada2 Exp $
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

@implementation CMRBrowser(Action)
- (IBAction) focus : (id) sender
{
    [[self window] makeFirstResponder : [[self threadsListTable] enclosingScrollView]];
}

- (void) selectRowWhoseNameIs : (NSString *) brdname_
{
    BoardList       *source;
    NSDictionary	*selected;
    int				index;

    source = (BoardList *)[[self boardListTable] dataSource];
    
    selected = [source itemForName : brdname_];
    if (nil == selected)
        return;
    
    index = [[self boardListTable] rowForItem : selected];
    if (-1 == index) {
        return;
    }
    
    [[self boardListTable] selectRow : index 
                byExtendingSelection : NO];
    [[self boardListTable] scrollRowToVisible : index];
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
	
	if ([targetView isKindOfClass : [m_threadsListTable class]] || nil == targetView) {	// �X���b�h���X�g����
		result = [self selectedThreadsReallySelected];
		if (0 == [result count]) {
			if (nil == [self threadURL]) {
				result = [NSArray empty];
			}
			result = [self selectedThreads];
		}
//	} else if (nil == targetView) {
		// ���j���[�o�[�������̓L�[�C�x���g���� ���̓X���b�h���X�g�̏ꍇ�Ɠ���
	} else { //�@�X���b�h���X�g����B
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

- (IBAction) openLogfile : (id) sender
{
	[self openThreadsLogFiles :  [self targetThreadsForAction : _cmd]];
}
- (IBAction) openInBrowser : (id) sender
{
	[self openThreadsInBrowser : [self targetThreadsForAction : _cmd]];
}

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
		[[self window] makeFirstResponder : [self textView]];
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

#pragma mark Filter, Search Popup
- (IBAction) selectFilteringMask : (id) sender
{
	NSPopUpButton	*popUpButton_;
	NSNumber		*representedObject_;
	unsigned int	mask_;
	
	if (nil == [self currentThreadsList]) return;
	if (nil == sender) return;
	
	UTILAssertKindOfClass(sender, NSPopUpButton);
	
	popUpButton_ = (NSPopUpButton*) sender;
	representedObject_ = [[popUpButton_ selectedItem] representedObject];
	UTILAssertKindOfClass(representedObject_, NSNumber);

	mask_ = [representedObject_ unsignedIntValue];
	[self changeThreadsFilteringMask : mask_];
}

- (IBAction) searchToolbarPopupChanged : (id) sender
{
	CMRSearchMask		prefOption_;		// �ݒ�ς݂̃I�v�V����
	CMRSearchMask		settingOpt_;		// �ݒ�܂��͉������ꂽ�I�v�V����
	BOOL				isOnState_;			// �ݒ肩
	
	if (NO == [sender respondsToSelector:@selector(representedObject)]) return;
	if (NO == [sender respondsToSelector:@selector(state)]) return;
	
	prefOption_ = [CMRPref threadSearchOption];
	settingOpt_ = [[sender representedObject] unsignedIntValue];
	isOnState_  = NSOffState == [(NSMenuItem*)sender state];
	
	[sender setState : isOnState_ ? NSOnState : NSOffState];
	if (CMRSearchOptionCaseInsensitive == settingOpt_ || 
	   CMRSearchOptionZenHankakuInsensitive == settingOpt_) {
		// �Ӗ����t�ɂȂ��Ă���B
		isOnState_ = (NO == isOnState_);
	}
	if (isOnState_) {
		[CMRPref setThreadSearchOption : 
			prefOption_ | settingOpt_];
	} else {
		[CMRPref setThreadSearchOption : 
			(prefOption_ & (~settingOpt_))];
	}
	
}

#pragma mark Deletion
- (void) _showDeletionAlertSheet : (id) sender
						  ofType : (BSThreadDeletionType) aType
					  allowRetry : (BOOL) allowRetry
				   targetThreads : (id) anObj
{
	NSAlert		*alert_;
	NSString	*title_;
	NSString	*message_;
	SEL			didEndSel_;

	alert_ = [[NSAlert alloc] init];

	switch(aType) {
	case BSThreadAtViewerDeletionType:
		{
		NSString *tmp_ = [self localizedString : kDeleteThreadTitleKey];
		title_ = [NSString stringWithFormat : tmp_, [self title]];
		message_ = [self localizedString : kDeleteThreadMessageKey];
		didEndSel_ = @selector(_threadDeletionSheetForViewerDidEnd:returnCode:contextInfo:);
		}
		break;
	case BSThreadAtBrowserDeletionType:
		title_ = [self localizedString : kBrowserDelThTitleKey];
		message_ = [self localizedString : kBrowserDelThMsgKey];
		didEndSel_ = @selector(_threadDeletionSheetForListDidEnd:returnCode:contextInfo:);
		break;
	case BSThreadAtFavoritesDeletionType:
		title_ = [self localizedString : kDeleteFavTitleKey];
		message_ = [self localizedString : kDeleteFavMsgKey];
		didEndSel_ = @selector(_threadDeletionSheetForListDidEnd:returnCode:contextInfo:);
		break;
	default : 
		title_ = @"Implementaion Error";
		message_ = @"Please report that You see this message. Oh, you should press Cancel button. Sorry.";
		didEndSel_ = nil;
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
					  didEndSelector : didEndSel_
					     contextInfo : nil];

	[alert_ release];
}

- (IBAction) deleteThread : (id) sender
{
    CMRThreadsList	*threadsList = [self currentThreadsList];
    NSTableView		*tableView   = [self threadsListTable];
 
	NSArray			*selected_	= [self selectedThreadsReallySelected];
   
    if ([selected_ count] == 0) {
		/* �ꗗ�ŉ����I������Ă��Ȃ� */
		if ([self shouldShowContents]) {
			/* 3�y�C���\���Ȃ�A���O�\���̈�ŕ\�����̃X�����폜���� */
			NSString *path_ = [[self path] copy];
			if ([CMRPref quietDeletion]) {
				if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
					[self checkIfFavItemThenRemove : path_];
				} else {
					NSBeep();
					NSLog(@"Deletion failed : %@", path_);
				}
			} else {
				[self _showDeletionAlertSheet : sender
									   ofType : BSThreadAtViewerDeletionType
								   allowRetry : YES
								targetThreads : nil];
			}
			[path_ release];
			return;
		} else {
			/* 2�y�C���\���Ȃ�A�폜������͉̂������� */
			return;
		}
    }
    if (NO == [CMRPref quietDeletion]) {
		/* �ȉ��̏ꍇ�A�u�폜���čĎ擾�v�͋����Ȃ��F
		   1.�I�t���C�����[�h��
		   2.2�y�C���\�����i�ʃE�C���h�E�ŊJ���Ă���ǂ����j
		   3.�����̃X���b�h���I������Ă���Ƃ�
		*/
		// �ǉ��F3�y�C�����Ɉꗗ�őI������Ă���X���b�h�ƃr���[�A�ŕ\������Ă���X���b�h����v���Ȃ����́A
		//�@�@�@�@�t�H�[�J�X�̓������Ă���r���[�Ŕ��f����B�������A�t�H�[�J�X���ꗗ���ɂ����Ă��A�r���[�A�ƑI���X���b�h����v���Ă��鎞��
		//�@�@�@�@�Ď擾��������B

		// 3�y�C���A���A�I�����ڂ�������Ȃ�
		if ([self shouldShowContents] && ([selected_ count] == 1)) {
			int			selectedNum = [tableView selectedRow];
			NSString	*checkPath_;
			checkPath_ = [threadsList threadFilePathAtRowIndex : selectedNum
												   inTableView : tableView
														status : NULL];
			// �I���X���ƕ\���X������v�A�܂��̓t�H�[�J�X���r���[�A�ɂ��遨�r���[�A�̃X����ΏۂɁA�Ď擾���t����
			if ([checkPath_ isEqualToString : [self path]] || ([[self window] firstResponder] == [self textView])) {
				[self _showDeletionAlertSheet : sender
									   ofType : BSThreadAtViewerDeletionType
								   allowRetry : [CMRPref isOnlineMode]
								targetThreads : nil];
			// �I���X���ƕ\���X������v���Ȃ��A���A�t�H�[�J�X�͈ꗗ���ɂ��遨�Ď擾�͋����Ȃ�
			} else {
				[self _showDeletionAlertSheet : sender
									   ofType : BSThreadAtBrowserDeletionType
								   allowRetry : NO
								targetThreads : nil];
			}
			return;
		}
		// 3�y�C���őI�����ڂ��������邩�A�܂��͑I�����ڐ��Ɋւ�炸2�y�C��
		if(NO == [threadsList isFavorites])
			[self _showDeletionAlertSheet : sender ofType : BSThreadAtBrowserDeletionType allowRetry : NO
					targetThreads : nil];
		else
			[self _showDeletionAlertSheet : sender ofType : BSThreadAtFavoritesDeletionType allowRetry : NO
					targetThreads : nil];
    } else {
		[threadsList tableView : tableView
				removeIndexSet : [tableView selectedRowIndexes]
			 delFavIfNecessary : YES];
		[tableView reloadData];
	}
}

- (void) _threadDeletionSheetForListDidEnd : (NSAlert *) alert
								returnCode : (int      ) returnCode
							   contextInfo : (void	   *) contextInfo
{
    CMRThreadsList *threadsList = [self currentThreadsList];
    NSTableView    *tableView   = [self threadsListTable];
	
	//UTILAssertKindOfClass(contextInfo, [NSArray class]);

	switch(returnCode){
	case NSAlertFirstButtonReturn: // delete
		{
			[threadsList tableView : tableView
					removeIndexSet : [tableView selectedRowIndexes]
				 delFavIfNecessary : YES];
			[tableView reloadData];
		}
		break;
	/*case NSAlertThirdButtonReturn: // delete & reload
		{
			NSEnumerator		*Iter_;
			NSDictionary		*threadAttributes_;

			if ([threadsList tableView : tableView
					removeIndexSet : [tableView selectedRowIndexes]
				 delFavIfNecessary : NO])
			{
				[tableView reloadData];
				Iter_ = [(NSArray *)contextInfo objectEnumerator];
				while ((threadAttributes_ = [Iter_ nextObject])) {
					NSString			*path_;
					NSString			*title_;
					CMRThreadSignature	*threadSignature_;
					
					path_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
					title_ = [threadAttributes_ objectForKey : CMRThreadTitleKey];
					threadSignature_ = [CMRThreadSignature threadSignatureFromFilepath : path_];

					[self downloadThread : threadSignature_
								   title : title_
							   nextIndex : 0];
				}
			} else {
				NSBeep();
				NSLog(@"Deletion failed :\n%@", [(NSArray *)contextInfo description]);
			}
		}
		break;*/
	case NSAlertSecondButtonReturn: // cancel
		break;
	default:
		break;
	}
	
}


- (void) _threadDeletionSheetForViewerDidEnd : (NSAlert *) alert
								  returnCode : (int      ) returnCode
								 contextInfo : (void *) contextInfo
{
	//UTILAssertKindOfClass(contextInfo, [NSString class]);

	switch(returnCode){
	case NSAlertFirstButtonReturn: // delete
		{
			NSString *path_ = [self path];
			if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
				[self checkIfFavItemThenRemove : path_];
			} else {
				NSBeep();
				NSLog(@"Deletion failed : %@", path_);
			}
		}
		break;
	case NSAlertThirdButtonReturn: // delete & reload
		{
			NSString *path_ = [self path];
			if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : NO]) {
				[self reloadAfterDeletion : path_];
				[[self threadsListTable] reloadData]; // really need?
			} else {
				NSBeep();
				NSLog(@"Deletion failed : %@ , so reloading opreation has been canceled.", path_);
			}			
		}
		break;
	case NSAlertSecondButtonReturn: // cancel
		break;
	default:
		break;
	}	
}

#pragma mark Search

- (void) showSearchResultAppInfoWithFound : (BOOL) aResult
{	
	if (NO == aResult) {
		_filterResultMessage = [self localizedString : kSearchListNotFoundKey];
	} else {
		_filterResultMessage = [NSString stringWithFormat : [self localizedString : kSearchListResultKey],
															[[self currentThreadsList] numberOfFilteredThreads]];
	}

	[[self window] setTitle : [NSString stringWithFormat : @"%@ (%@)", [[self document] displayName], _filterResultMessage]];
}
- (BOOL) showsSearchResult
{
	return (_filterString != nil);
}
- (void) clearSearchFilter
{
	[_filterString release];
	_filterString = nil;
	
	// �������ʂ̕\��@�^�C�g���o�[������
	[self synchronizeWindowTitleWithDocumentName];
	_filterResultMessage = nil;
}
- (void) synchronizeWithSearchField
{
	[self searchThreadWithString : _filterString];
}
- (void) searchThreadWithString : (NSString *) aString
{
	BOOL		result = NO;
	
	if (nil == aString || [aString isEmpty]) {
		int		mask_;
		
		mask_ = [[self currentThreadsList] filteringMask];
		[self changeThreadsFilteringMask : mask_];
	} else {
		result = [[self document] searchThreadsInListWithString : aString];
		[self showSearchResultAppInfoWithFound : result];
	}
	
	if (result && _filterString != aString) {
		[_filterString autorelease]; 
		_filterString = [aString copy];
	}

	[[self threadsListTable] reloadData];
}
- (IBAction) searchThread : (id) sender
{
	if (NO == [sender respondsToSelector : @selector(stringValue)])
		return;

	[self searchThreadWithString : [sender stringValue]];
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