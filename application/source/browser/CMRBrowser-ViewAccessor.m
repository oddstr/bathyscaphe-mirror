/**
  * $Id: CMRBrowser-ViewAccessor.m,v 1.34 2006/02/12 09:10:23 tsawada2 Exp $
  * 
  * CMRBrowser-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "CMRBBSListTemplateKeys.h"
#import "NSTableColumn+CMXAdditions.h"
#import "CMRMainMenuManager.h"
#import "AddBoardSheetController.h"
#import "BSTitleRulerView.h"
#import "CMRTextColumnCell.h"
#import <SGAppKit/CMRPullDownIconBtn.h>
#import <SGAppKit/BSIconAndTextCell.h>

@implementation CMRBrowser(ViewAccessor)
- (CMRThreadViewer *) threadViewer
{
    return nil;
}
- (BSKFSplitView *) splitView
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

- (NSSearchField *) searchField
{
	return m_searchField;
}

- (NSMenu *) listContextualMenu
{
    return m_listContextualMenu;
}
- (NSMenu *) drawerContextualMenu
{
    return m_drawerContextualMenu;
}

- (CMRAccessorySheetController *) listSorterSheetController
{
    if (nil == m_listSorterSheetController) {
		NSRect                  frame_;
        
		frame_ = [[self searchField] frame];

		// 検索フィールドの幅が 300px より短い場合、一律 300px に固定
		// CMRBrowser-Action.m の showSearchThreadPanel: との合わせ技なので、そちらも参照
		if(frame_.size.width < 300) frame_.size.width = 300;

        m_listSorterSheetController = 
            [[CMRAccessorySheetController alloc] 
                    initWithContentSize : frame_.size
                           resizingMask : NSViewNotSizable];
    }
    return m_listSorterSheetController;
}

- (AddBoardSheetController *) addBoardSheetController
{
    if (nil == m_addBoardSheetController) {
		m_addBoardSheetController = [[AddBoardSheetController alloc] init];
	}
	return m_addBoardSheetController;
}
@end

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
@end

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
    NSString			*identifier_;
    NSTableColumn		*column_;
	ThreadsListTable	*tbView_;
        
    if (NO == [sender respondsToSelector : @selector(representedObject)])
        return;
    
    identifier_ = [sender representedObject];
    UTILAssertKindOfClass(identifier_, NSString);

    tbView_ = [self threadsListTable];
    column_ = [tbView_ tableColumnWithIdentifier : identifier_];

    if (column_ != nil) {
	   [tbView_ setColumnWithIdentifier : identifier_ visible : NO];
    } else {
        column_ = [self defaultTableColumnWithIdentifier : identifier_];
        if (nil == column_) return;
        
	   [tbView_ setColumnWithIdentifier : identifier_ visible : YES];
    }
	
	[sender setState : (NSOffState == [sender state]) ? NSOnState : NSOffState];

	[CMRPref setThreadsListTableColumnState : [tbView_ columnState]];
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
    id                  rep_;
    
    iter_ = [[self defaultColumnsArray] objectEnumerator];

    while (rep_ = [iter_ nextObject]) {
        NSTableColumn        *column_;
        
        column_ = [self tableColumnWithPropertyListRep : rep_];
        if (nil == column_) continue;
        
        [tableView addTableColumn : column_];
    }

	[(ThreadsListTable *)tableView setInitialState];
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
		
	[[column dataCell] setWraps : YES];
}
@end

@implementation CMRBrowser(ViewInitializer)
+ (Class) toolbarDelegateImpClass
{
    return [CMRBrowserTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName
{
    return APP_BROWSER_STATUSLINE_IDENTIFIER;
}
- (void) setupScrollView
{
	CMXScrollView *scView = [self scrollView];
	id ruler;
	[[scView class] setRulerViewClass : [BSTitleRulerView class]];
	ruler = [[BSTitleRulerView alloc] initWithScrollView : scView ofBrowser : self];
	[scView setHorizontalRulerView : ruler];

	[super setupScrollView];
	[scView setHasHorizontalRuler : YES];
	[scView setRulersVisible : YES];
}

- (void) setupSplitView
{
	BOOL isGoingToVertical = [CMRPref isSplitViewVertical];
	// KFSplitView
    [[self splitView] setVertical : isGoingToVertical];
	[[[self threadsListTable] enclosingScrollView] setHasHorizontalScroller : isGoingToVertical];
    topSubview = [[[self splitView] subviews] objectAtIndex:0];
    bottomSubview = [[[self splitView] subviews] objectAtIndex:1];
}

- (void) updateDefaultsWithTableView : (NSTableView *) tbview
{
	id	tmp,tmp2;
    tmp = SGTemplateResource(kThreadsListTableICSKey);
    UTILAssertRespondsTo(tmp, @selector(stringValue));
    [tbview setIntercellSpacing : NSSizeFromString([tmp stringValue])];

    [tbview setRowHeight : [CMRPref threadsListRowHeight]];
    [tbview setFont : [CMRPref threadsListFont]];
    
    [tbview setUsesAlternatingRowBackgroundColors : [CMRPref browserSTableDrawsStriped]];
	
	if([CMRPref browserSTableDrawsBackground]) {
		[tbview setBackgroundColor : [CMRPref browserSTableBackgroundColor]];
	} else {
		// 背景を塗らない設定に変更したら、デフォルトの色に戻ってほしいので、
		// もし、今デフォルトの色になっていないのなら、戻しておく。
		if (!([[tbview backgroundColor] isEqual: [NSColor whiteColor]]))
			[tbview setBackgroundColor : [NSColor whiteColor]];
	}
	[tbview setGridStyleMask : ([CMRPref threadsListDrawsGrid] ? NSTableViewSolidVerticalGridLineMask : NSTableViewGridNone)];
	tmp2 = [CMRPref threadsListTableColumnState];
	if(tmp2)
		[(ThreadsListTable *)tbview restoreColumnState : tmp2];
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
    
    [tbView_ setAutosaveTableColumns : NO];
    [tbView_ setVerticalMotionCanBeginDrag : NO];
        
    // Menu and Contextual Menus
    [self setupColumnsMenuWithTableView : tbView_]; // これは必ず[tbView_ setAutosaveTableColumns : YES] の後に実行しなければならない
    [tbView_ setMenu : [self listContextualMenu]];
}

#pragma mark BoardList

- (void) setupBoardListOutlineView : (NSOutlineView *) outlineView
{
    id        tmp;
	NSColor	*tmp2;
    
    // D & D
    [outlineView registerForDraggedTypes : [NSArray arrayWithObjects : CMRBBSListItemsPboardType, NSFilenamesPboardType, nil]];
    
    [outlineView setDelegate : self];
    [outlineView setDataSource : [[BoardManager defaultManager] userList]];

    {
        NSTableColumn    *column_;
		BSIconAndTextCell	*cell_;
        
        column_ = [outlineView tableColumnWithIdentifier : BoardPlistNameKey];

        cell_ = [[BSIconAndTextCell alloc] init];
        [cell_ setEditable : NO];
        [column_ setDataCell : cell_];
        [cell_ release];

        [column_ setEditable : NO];
    }
    
    [outlineView setRowHeight : [CMRPref boardListRowHeight]];
    
    tmp = SGTemplateResource(kBBSListIndentationPerLevelKey);
    UTILAssertRespondsTo(tmp, @selector(floatValue));
    [outlineView setIndentationPerLevel : [tmp floatValue]];

    tmp2 = [CMRPref boardListBackgroundColor];
    if (tmp2 != nil)
		[outlineView setBackgroundColor : tmp2];
    [outlineView setDoubleAction : @selector(boardListViewDoubleAction:)];
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
    NSString        *boardName;
    
	boardName = [CMRPref browserLastBoard];
    if (nil == boardName) {
        NSLog(@"Last Board Setting not found.");
        return;
    }
    
    [self showThreadsListWithBoardName : boardName];
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
    // launching.
    
    NSNotification *notification = [NSNotification notificationWithName : kSelectLastBBSNotification
																 object : self];
    
    [[NSNotificationCenter defaultCenter] addObserver : self
											 selector : @selector(selectLastBBS:)
												 name : kSelectLastBBSNotification
											   object : self];

    [[NSNotificationQueue defaultQueue] enqueueNotification : notification
											   postingStyle : NSPostWhenIdle];
}

- (void) setUpBoardListToolButtons
{
	CMRPullDownIconBtn	*cell_;
	NSPopUpButtonCell	*btnCell_;
	NSMenu				*menuBase_;
	id<NSMenuItem>		tmp_;
	
	cell_ = [[CMRPullDownIconBtn alloc] initTextCell : @"" pullsDown:YES];
	btnCell_ = [[self brdListActMenuBtn] cell];
    [cell_ setAttributesFromCell : btnCell_];
    [[self brdListActMenuBtn] setCell : cell_];
    [cell_ release];

	btnCell_ = [[self brdListActMenuBtn] cell];
	[btnCell_ setArrowPosition:NSPopUpNoArrow];
	
	menuBase_ = [[self drawerContextualMenu] copy];
	[menuBase_ insertItem : [NSMenuItem separatorItem] atIndex : 0]; // dummy
	tmp_ = [menuBase_ itemWithTag : kBLEditItemViaContMenuItemTag];
	[tmp_ setTag : kBLEditItemViaMenubarItemTag];
	tmp_ = [menuBase_ itemWithTag : kBLDeleteItemViaContMenuItemTag];
	[tmp_ setTag : kBLDeleteItemViaMenubarItemTag];
	[btnCell_ setMenu : menuBase_];
	[menuBase_ release];
}

#pragma mark Window, KeyLoop, and Search Menu

/*- (void) setupStatusLine
{
    [super setupStatusLine];
}*/

- (void) setupFrameAutosaveName
{
    [[self window] setFrameAutosaveName : APP_BROWSER_WINDOW_AUTOSAVE_NAME];
	[[self window] setFrameUsingName : APP_BROWSER_WINDOW_AUTOSAVE_NAME];
    [self setupSplitView];
	[[self splitView] setPositionAutosaveName : APP_BROWSER_SPVIEW_AUTOSAVE_NAME];
	[[self splitView] setPositionUsingName : APP_BROWSER_SPVIEW_AUTOSAVE_NAME];
}
- (void) setupKeyLoops
{
	[[self searchField] setNextKeyView : [self threadsListTable]];
   
	if ([self shouldShowContents]) {
		[[self threadsListTable] setNextKeyView : [self textView]];
		[[self textView] setNextKeyView : [[self indexingStepper] textField]];
		[[[self indexingStepper] textField] setNextKeyView : [self boardListTable]];
	} else {
		[[self threadsListTable] setNextKeyView : [self boardListTable]];
	}
	
	[[self boardListTable] setNextKeyView : [self searchField]];
    
    [[self window] setInitialFirstResponder : [self threadsListTable]];
    [[self window] makeFirstResponder : [self threadsListTable]];
}
- (void) setWindowFrameUsingCache
{
    return;
}

- (void) setupSearchFieldMenu
{
	NSMenuItem		*hItem1, *hItem2, *hItem3, *hItem5;
	id				hItem4;
	
	BOOL	isIncremental;
	int		cnt = -1;
	
	NSMenu	*cellMenu	= [[[NSMenu alloc] initWithTitle : @"Search Menu"] autorelease];
    id		searchCell	= [[self searchField] cell];

	isIncremental = [CMRPref useIncrementalSearch];

	[searchCell setSendsWholeSearchString : (NO == isIncremental)];	
	[searchCell setControlSize : NSSmallControlSize];
	
	if (!isIncremental) {
		int maxValu = [CMRPref maxCountForSearchHistory];
		[searchCell setMaximumRecents : maxValu];

		hItem1 = [[NSMenuItem alloc] initWithTitle : [self localizedString : @"Search PopUp History Title"]
											action : NULL
									 keyEquivalent : @""];
		[hItem1 setTag : NSSearchFieldRecentsTitleMenuItemTag];
		[cellMenu insertItem : hItem1 atIndex : (cnt+1)];
		[hItem1 release];

		hItem2 = [[NSMenuItem alloc] initWithTitle : [self localizedString : @"Search PopUp NoHistory Title"]
											action : NULL
									 keyEquivalent : @""];
		[hItem2 setTag : NSSearchFieldNoRecentsMenuItemTag];
		[cellMenu insertItem : hItem2 atIndex : (cnt+2)];
		[hItem2 release];

		hItem3 = [[NSMenuItem alloc] initWithTitle : [self localizedString : @"Search PopUp History Title"]
											action : NULL
									 keyEquivalent : @""];
		[hItem3 setTag : NSSearchFieldRecentsMenuItemTag];
		[cellMenu insertItem : hItem3 atIndex : (cnt+3)];
		[hItem3 release];

		hItem4 = [NSMenuItem separatorItem];
		[hItem4 setTag : NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem : hItem4 atIndex : (cnt+4)];

		hItem5 = [[NSMenuItem alloc] initWithTitle : [self localizedString : @"Search Popup History Clear"]
											action : NULL
									 keyEquivalent : @""];
		[hItem5 setTag : NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem : hItem5 atIndex : (cnt+5)];
		[hItem5 release];
	
		[searchCell setSearchMenuTemplate : cellMenu];
	}
}
@end

#pragma mark -

@implementation CMRBrowser(NibOwner)
- (void) setupUIComponents
{
    [super setupUIComponents];

    [self setupThreadsListTable];
    [self setUpBoardListToolButtons];
	
	[self setupSearchFieldMenu];

    [self setupFrameAutosaveName];
    [self setupKeyLoops];
    
    [self setupBoardListTable];
}
@end
