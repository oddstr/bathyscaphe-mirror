/**
  * $Id: CMRBrowser-ViewAccessor.m,v 1.13 2005/06/18 22:33:27 tsawada2 Exp $
  * 
  * CMRBrowser-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "CMRBBSListTemplateKeys.h"
#import "CMRBrowserTemplateKeys.h"

#import "NSTableColumn+CMXAdditions.h"
#import "CMRTextColumnCell.h"
#import "CMRPullDownIconBtn.h"
#import "CMRMainMenuManager.h"

// Constants
#define kBrowserListColumnsPlist        @"browserListColumns.plist"
#define kChooseColumnAction             @selector(chooseColumn:)
#define kToolbarSearchFieldItemKey		@"Search Thread"

#pragma mark -

@implementation CMRBrowser(ViewAccessor)
- (CMRThreadViewer *) threadViewer
{
    return nil;
}
- (CMRSplitView *) splitView
{
    return m_splitView;
}
- (RBSplitSubview *) boardListSubView
{
    return m_boardListSubView;
}
- (ThreadsListTable *) threadsListTable
{
    return m_threadsListTable;
}
- (CMXScrollView *) threadsListScrollView
{
    CMXScrollView    *sview_;
    
    sview_ = (CMXScrollView*)[[self threadsListTable] enclosingScrollView];
    UTILAssertKindOfClass(sview_, CMXScrollView);
    
    return sview_;
}
- (NSPopUpButton *) threadsFilterPopUp
{
    return m_threadsFilterPopUp;
}
- (NSOutlineView *) boardListTable
{
    return m_boardListTable;
}
- (id) brdListActMenuBtn
{
    return m_brdListActMenuBtn;
}
- (id) splitterBtn
{
	return m_splitterBtn;
}

- (NSMenu *) listContextualMenu
{
    return m_listContextualMenu;
}
- (NSMenu *) drawerContextualMenu
{
    return m_drawerContextualMenu;
}

#pragma mark -

- (NSWindow *) drawerItemEditSheet
{
	return m_drawerItemEditSheet;
}
- (NSTextField *) dItemEditSheetMsgField
{
	return m_dItemEditSheetMsgField;
}
- (NSTextField *) dItemEditSheetLabelField
{
	return m_dItemEditSheetLabelField;
}
- (NSTextField *) dItemEditSheetInputField
{
	return m_dItemEditSheetInputField;
}
- (NSTextField *) dItemEditSheetTitleField
{
	return m_dItemEditSheetTitleField;
}
- (NSWindow *) drawerItemAddSheet
{
	return m_drawerItemAddSheet;
}
- (NSTextFieldCell *) dItemAddSheetNameField
{
	return m_dItemAddNameField;
}
- (NSTextFieldCell *) dItemAddSheetURLField
{
	return m_dItemAddURLField;
}

#pragma mark -

- (id) searchToolbarItem
{
    return [[self listSorter] pantherSearchField];
}
- (NSTextField *) searchTextField
{
	return [self searchToolbarItem];
}

#pragma mark -

- (void) setupThreadsListSorter : (CMRNSSearchField *) sorter
{
	[[sorter pantherSearchField] setTarget : self];
	[[sorter pantherSearchField] setAction : @selector(searchThread:)];
}
- (CMRNSSearchField *) listSorter
{
    if (nil == m_listSorter) {
        m_listSorter = [[CMRNSSearchField alloc] init];
    }
    [self setupThreadsListSorter : m_listSorter];
    return m_listSorter;
}
- (CMRNSSearchField *) listSorterSub
{
	if (nil == m_listSorterSub) {
        NSView        *view_;
        NSSize        cSize_;
        NSSize        wSize_;
        
        m_listSorterSub = [[CMRNSSearchField alloc] init];
        view_ = [m_listSorterSub pantherSearchField];
        cSize_ = [view_ frame].size;
        wSize_ = [[self window] frame].size;
        cSize_.width = wSize_.width / 2;
        
        [view_ setFrameSize : cSize_];
        [view_ setAutoresizingMask : NSViewNotSizable];
        
        [self setupThreadsListSorter : m_listSorterSub];
    }
    return m_listSorterSub;
}

- (CMRAccessorySheetController *) listSorterSheetController
{
    if (nil == m_listSorterSheetController) {
        CMRNSSearchField        *sorter_;
		NSRect                  frame_;
        
        sorter_ = [self listSorterSub];
		frame_ = [[sorter_ pantherSearchField] frame];

        m_listSorterSheetController = 
            [[CMRAccessorySheetController alloc] 
                    initWithContentSize : frame_.size
                           resizingMask : NSViewNotSizable];
    }
    return m_listSorterSheetController;
}
@end

#pragma mark -

@implementation CMRBrowser(UIComponents)
- (void) setupLoadedComponents
{
    NSView        *containerView_;
    
    containerView_ = [self containerView];
    UTILAssertNotNil(containerView_);
    
    [containerView_ retain];
    [containerView_ removeFromSuperviewWithoutNeedingDisplay];
    
    [[self splitView] addSubview : containerView_];
    [containerView_ release];
}

- (BOOL) ifSearchFieldIsInToolbar
{
	/*
		2005-02-01 tsawada2<ben-sawa@td5.so-net.ne.jp>
		ツールバーに検索フィールドが表示されているかチェックして真偽値を返す。
		ここで「表示されている」とは、以下のすべての条件を満たすときに限る：
		1.ツールバーの表示モードが「アイコンとテキスト」または「アイコンのみ」
		2.検索フィールドがツールバーからはみ出していない
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
@end

#pragma mark -

@implementation CMRBrowser(TableColumnInitializer)
- (NSArray *) defaultColumnsArray
{
    NSBundle    *bundles[] = {
                [NSBundle applicationSpecificBundle], 
                [NSBundle mainBundle],
                nil};
    NSBundle    **p = bundles;
    NSString    *path = nil;
    
    for (; *p != nil; p++)
        if (path = [*p pathForResourceWithName : kBrowserListColumnsPlist])
            break;
    
    return (nil == path) ? nil : [NSArray arrayWithContentsOfFile : path];
}

- (id) defaultColumnsArrayPropertyListRep
{
    NSMutableArray        *array_;
    NSEnumerator        *iter_;
    NSTableColumn        *column_;
    
    array_ = [NSMutableArray array];
    iter_ = [[[self threadsListTable] tableColumns] objectEnumerator];
    while (column_ = [iter_ nextObject]) {
        NSDictionary    *rep_;
        
        rep_ = [column_ propertyListRepresentation];
        if (nil == rep_) continue;
        [array_ addObject : rep_];
    }
    return array_;
}
- (NSTableColumn *) tableColumnWithPropertyListRep : (id) rep
{
    NSTableColumn        *column_;
    
    column_ = [[NSTableColumn alloc] initWithPropertyListRepresentation : rep];
    [self setupTableColumn : column_];
    return [column_ autorelease];
}

- (void) setupColumnsMenuWithTableView : (NSTableView *) tableView
{
    NSEnumerator        *iter_;
    NSMenuItem          *rep_;
    NSMenu              *menu_ = [[[CMRMainMenuManager defaultManager] browserListColumnsMenuItem] submenu];
    
    iter_ = [[menu_ itemArray] objectEnumerator];
    while (rep_ = [iter_ nextObject]) {
        int                    state_;
                
        state_ = 
            (-1 == [tableView columnWithIdentifier : [rep_ representedObject]])
                ? NSOffState
                : NSOnState;

        [rep_ setState : state_];
        [rep_ setAction : kChooseColumnAction];
    }
}

- (IBAction) chooseColumn : (id) sender
{
    NSString        *identifier_;
    NSTableColumn    *column_;
        
    if (NO == [sender respondsToSelector : @selector(representedObject)])
        return;
    
    identifier_ = [sender representedObject];
    UTILAssertKindOfClass(identifier_, NSString);
    
    column_ = [[self threadsListTable] tableColumnWithIdentifier : identifier_];
    if (column_ != nil) {
        [[self threadsListTable] removeTableColumn : column_];
    } else {
        column_ = [self defaultTableColumnWithIdentifier : identifier_];
        if (nil == column_) return;
        
        [[self threadsListTable] addTableColumn : column_];
    }
	
	[sender setState : (NSOffState == [sender state]) ? NSOnState : NSOffState];
    
    [[self threadsListTable] sizeLastColumnToFit];
}

- (NSTableColumn *) defaultTableColumnWithIdentifier : (NSString *) anIdentifer
{
    NSEnumerator        *iter_;
    id                    rep_;
    
    if (nil == anIdentifer) return nil;
    
    iter_ = [[self defaultColumnsArray] objectEnumerator];
    while (rep_ = [iter_ nextObject]) {
        NSTableColumn        *column_;
        
        column_ = [self tableColumnWithPropertyListRep : rep_];
        if (nil == column_) continue;
        if (NO == [anIdentifer isEqualToString : [column_ identifier]]) continue;
        
        return column_;
    }
    return nil;
}
- (void) createDefaultTableColumnsWithTableView : (NSTableView *) tableView
{
    NSEnumerator        *iter_;
    id                    rep_;
    
    iter_ = [[self defaultColumnsArray] objectEnumerator];
    while (rep_ = [iter_ nextObject]) {
        NSTableColumn        *column_;
        
        column_ = [self tableColumnWithPropertyListRep : rep_];
        if (nil == column_) continue;
        
        [[self threadsListTable] addTableColumn : column_];
    }
}


- (void) setupDateFormaterWithTableColumn : (NSTableColumn *) column
{
    NSCell                *dataCell_;
    NSDateFormatter        *formater_;
    
    if (nil == column) return;
    
    dataCell_ = [column dataCell];
    UTILAssertNotNil(dataCell_);
    
    formater_ = [CMXDateFormatter sharedInstance];
    [dataCell_ setFormatter : formater_];
}

- (void) setupStatusColumnWithTableColumn : (NSTableColumn *) column
{
    NSImage            *statusImage_;
    NSImageCell        *imageCell_;
    
    statusImage_ = [NSImage imageAppNamed : STATUS_HEADER_IMAGE_NAME];
    imageCell_  = [[NSImageCell alloc] initImageCell : nil];
    
    [[column headerCell] setAlignment : NSCenterTextAlignment];
    [[column headerCell] setImage : statusImage_];
    
    [imageCell_ setImageAlignment : NSImageAlignCenter];
    [imageCell_ setImageScaling : NSScaleNone];
    [imageCell_ setImageFrameStyle : NSImageFrameNone];
    
    [column setDataCell : imageCell_];
    [imageCell_ release];
}
- (void) setupTableColumn : (NSTableColumn *) column
{
    CMRTextColumnCell    *cell_;
    
    if ([CMRThreadStatusKey isEqualToString : [column identifier]]) {
        [self setupStatusColumnWithTableColumn : column];
        return;
    }
    
    cell_ = [[CMRTextColumnCell alloc] initTextCell : @""];
    [cell_ setAttributesFromCell : [column dataCell]];
    [column setDataCell : cell_];
    [cell_ release];
    
    if ( [CMRThreadModifiedDateKey isEqualToString : [column identifier]] ||
         [CMRThreadCreatedDateKey isEqualToString : [column identifier]])
        [self setupDateFormaterWithTableColumn : column];
}
@end

#pragma mark -

@implementation CMRBrowser(ViewInitializer)
+ (Class) toolbarDelegateImpClass
{
    return [CMRBrowserTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName
{
    return APP_BROWSER_STATUSLINE_IDENTIFIER;
}

- (void) setupSplitView
{
    [[self splitView] setVertical : [CMRPref isSplitViewVertical]];
    topSubview = [[[self splitView] subviews] objectAtIndex:0];
    bottomSubview = [[[self splitView] subviews] objectAtIndex:1];

}

- (void) updateDefaultsWithTableView : (NSTableView *) tbview
{
    [tbview setIntercellSpacing : [CMRPref threadsListIntercellSpacing]];
    [tbview setRowHeight : [CMRPref threadsListRowHeight]];
    [tbview setFont : [CMRPref threadsListFont]];
    
    [tbview setUsesAlternatingRowBackgroundColors : [CMRPref browserSTableDrawsStriped]];
	
	if([CMRPref browserSTableDrawsBackground]) [tbview setBackgroundColor : [CMRPref browserSTableBackgroundColor]];
	[tbview setGridStyleMask : ([CMRPref threadsListDrawsGrid] ? NSTableViewSolidVerticalGridLineMask : NSTableViewGridNone)];    
}

- (void) setupThreadsListTable
{
    ThreadsListTable    *tbView_ = [self threadsListTable];
    
    [self createDefaultTableColumnsWithTableView : tbView_];
    [self updateDefaultsWithTableView : tbView_];
    

    [tbView_ setTarget : self];
    [tbView_ setDelegate : self];

    // dispatch in listViewAction:
    [tbView_ setAction : @selector(listViewAction:)];
    [tbView_ setDoubleAction : @selector(listViewDoubleAction:)];
	
	// Favorites Item's Drag & Drop operation support:
	[tbView_ registerForDraggedTypes : [NSArray arrayWithObjects : CMRFavoritesItemsPboardType, nil]];
    
    [tbView_ setAutosaveName : APP_BROWSER_THREADSLIST_TABLE_AUTOSAVE_NAME];
    [tbView_ setAutosaveTableColumns : YES];
    [tbView_ setVerticalMotionCanBeginDrag : NO];
        
    // Menu and Contextual Menus
    [self setupColumnsMenuWithTableView : tbView_]; // これは必ず[tbView_ setAutosaveTableColumns : YES] の後に実行しなければならない
    [tbView_ setMenu : [self listContextualMenu]];
}

- (void) setupThreadsListScrollView
{
    CMXScrollView    *scrollView_ = [self threadsListScrollView];
    
    [scrollView_ addAccessoryView : [self threadsFilterPopUp]
                        alignment : CMXScrollViewHorizontalRight];
}

#pragma mark -

- (void) setupThreadsFilterPopUpButton : (NSPopUpButton *) popUpBtn
{
    [popUpBtn setFont : [NSFont labelFontOfSize : 10.0f]];
    [popUpBtn setPullsDown : NO];
    [popUpBtn setBezelStyle : NSShadowlessSquareBezelStyle];
    [popUpBtn setBordered : YES];
    [popUpBtn removeAllItems];
    [popUpBtn setAction : @selector(selectFilteringMask:)];
    [popUpBtn setTarget : self];
}
- (void) setupThreadsFilterPopUpButtonCell : (NSPopUpButtonCell *) popUpBtnCell
{
    [popUpBtnCell setControlSize : NSSmallControlSize];
    [popUpBtnCell setArrowPosition : NSPopUpArrowAtBottom];
}
- (void) setupThreadsFilterPopUpButtonItems : (NSPopUpButton *) popUpBtn
{
    NSString *menuKeys[] = {
                            @"Show All Threads",
							@"Show New & Local Threads",
                            @"Show Local Threads",
                            @"Show NoCached Threads",
                            @"Show New Threads"
                           };
    int filteringMasks[] = 
      {
        ThreadStandardStatus,
		~ThreadNoCacheStatus,
        ThreadLogCachedStatus,
        ThreadNoCacheStatus,
        ThreadNewCreatedStatus ^ ThreadNoCacheStatus
      };
    
    int i, cnt;
    int filtering_mask_;
    
    i = 0;
    cnt = UTILNumberOfCArray(filteringMasks);
    filtering_mask_ = [CMRPref browserStatusFilteringMask];
    NSAssert(
        (cnt == UTILNumberOfCArray(menuKeys)),
        @"Menu item and RepresentedObjects must be same count.");
    
    for (i = 0; i < cnt; i++) {
        NSString *title_;
        
        title_ = [self localizedString : menuKeys[i]];
        [popUpBtn addItemWithTitle : title_];
        [[popUpBtn lastItem] setRepresentedObject : 
            [NSNumber numberWithUnsignedInt : filteringMasks[i]]];

        if (filteringMasks[i] == filtering_mask_) {
            [popUpBtn selectItem : [popUpBtn lastItem]];
        }
    }
}
- (void) setupThreadsFilterPopUp
{
    [self setupThreadsFilterPopUpButton : [self threadsFilterPopUp]];
    [self setupThreadsFilterPopUpButtonCell : [[self threadsFilterPopUp] cell]];
    [self setupThreadsFilterPopUpButtonItems : [self threadsFilterPopUp]];
}

#pragma mark -

- (void) setupBoardListOutlineView : (NSOutlineView *) outlineView
{
    id        tmp;
    
    // D & D
    [outlineView registerForDraggedTypes : 
        [NSArray arrayWithObjects : 
                        CMRBBSListItemsPboardType,
                        NSFilenamesPboardType,
                        nil]];
    
    [outlineView setDelegate : self];
    [outlineView setDataSource : [[BoardManager defaultManager] userList]];
    {
        NSTableColumn    *column_;
        NSBrowserCell    *cell_;
        
        column_ = [outlineView tableColumnWithIdentifier : BoardPlistNameKey];
        cell_ = [[NSBrowserCell alloc] initTextCell : @""];
        
        [cell_ setLeaf : YES];
        [cell_ setEditable : NO];
        [column_ setDataCell : cell_];
        [cell_ release];
        
        [column_ setEditable : NO];
    }
    
    [outlineView setRowHeight : [CMRPref boardListRowHeight]];
    
    tmp = SGTemplateResource(kBBSListIntercellSpacingKey);
    UTILAssertRespondsTo(tmp, @selector(stringValue));
    [outlineView setIntercellSpacing : NSSizeFromString([tmp stringValue])];
    
    tmp = SGTemplateResource(kBBSListIndentationPerLevelKey);
    UTILAssertRespondsTo(tmp, @selector(floatValue));
    [outlineView setIndentationPerLevel : [tmp floatValue]];
    
	tmp = [CMRPref boardListBgColor];
    if (NO == [tmp isEqual : [NSColor whiteColor]]) [outlineView setBackgroundColor : tmp];
		
	[outlineView setMenu : [self drawerContextualMenu]];
}
- (void) setupBoardListTableDefaults
{
    [self setupBoardListOutlineView : [self boardListTable]];
    
    [[self boardListTable] setDelegate : self];
	[[self boardListTable] setAutosaveName : APP_BROWSER_THREADSLIST_TABLE_AUTOSAVE_NAME];
    [[self boardListTable] setAutosaveExpandedItems : YES];
}

- (void) setupBoardListTableLastSelected
{
    CMRBBSSignature *lastBoard;
    NSString        *boardName;
    
    lastBoard = [CMRPref browserLastBoard];
    if (nil == lastBoard) {
        NSLog(@"Last Board Setting not found.");
        return;
    }
    [self showThreadsListWithBBSSignature : lastBoard];
    
    // Select
    boardName = [lastBoard name];
	[self selectRowWhoseNameIs : boardName];
}

- (void) selectLastBBS : (NSNotification *) aNotification
{
    [self setupBoardListTableLastSelected];
}
- (void) setupBoardListTable
{
    [self setupBoardListTableDefaults];
    // Since selecting board kick-start another thread,
    // we should run this task after application did finish
    // launching
    
    NSNotification *notification;
    
    notification = [NSNotification notificationWithName : kSelectLastBBSNotification
        object : self];
    
    [[NSNotificationCenter defaultCenter]
        addObserver : self
        selector : @selector(selectLastBBS:)
        name : kSelectLastBBSNotification
        object : self];
    [[NSNotificationQueue defaultQueue]
        enqueueNotification : notification
        postingStyle : NSPostWhenIdle];
    
    [self setupBoardListTableLastSelected];
}

#pragma mark -

- (void) setupStatusLine
{
    [super setupStatusLine];
    //[[self statusLine] setBoardHistoryEnabled : YES];
}

- (void) setupFrameAutosaveName
{
    [self setupSplitView];
    [[self window] setFrameAutosaveName : APP_BROWSER_WINDOW_AUTOSAVE_NAME];
	//[[self boardListSplitView] setPositionAutosaveName : APP_BROWSER_BL_SPVIEW_AUTOSAVE_NAME];
	[[self splitView] setPositionAutosaveName : APP_BROWSER_SPVIEW_AUTOSAVE_NAME];
}
- (void) setupKeyLoops
{
    [[self searchTextField] setNextKeyView : [self threadsListTable]];
    
    [[self threadsListTable] setNextKeyView : [self textView]];
    [[self textView] setNextKeyView : [[self indexingStepper] textField]];
    [[[self indexingStepper] textField] setNextKeyView : [self searchTextField]];
    
    [[self window] setInitialFirstResponder : [self threadsListTable]];
    [[self window] makeFirstResponder : [self threadsListTable]];
}
- (void) setWindowFrameUsingCache
{
    return;
}

- (void) setUpBoardListToolButtons
{
	CMRPullDownIconBtn	*cell_;
	
	cell_ = [[CMRPullDownIconBtn alloc] initTextCell : @"" pullsDown:YES];
    [cell_ setAttributesFromCell : [[self brdListActMenuBtn] cell]];
    [[self brdListActMenuBtn] setCell : cell_];
    [cell_ release];

	[[[self brdListActMenuBtn] cell] setArrowPosition:NSPopUpNoArrow];
}
@end

#pragma mark -

@implementation CMRBrowser(NibOwner)
- (void) setupUIComponents
{
    [super setupUIComponents];

    [self setupThreadsListTable];
    [self setupThreadsFilterPopUp];
    [self setupThreadsListScrollView];
    [self setUpBoardListToolButtons];
    [self setupFrameAutosaveName];
    [self setupKeyLoops];
    
    [self setupBoardListTable];
}
@end
