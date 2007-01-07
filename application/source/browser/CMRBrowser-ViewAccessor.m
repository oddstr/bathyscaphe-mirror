/**
  * $Id: CMRBrowser-ViewAccessor.m,v 1.44 2007/01/07 17:04:23 masakih Exp $
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

- (EditBoardSheetController *) editBoardSheetController
{
    if (nil == m_editBoardSheetController) {
		m_editBoardSheetController = [[EditBoardSheetController alloc] init];
	}
	return m_editBoardSheetController;
}
/*
- (NSString *) currentSearchString
{
	return [[self document] searchString];
}

- (void) setCurrentSearchString: (NSString *) newString
{
	[[self document] setSearchString: newString];
}*/
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
/*
- (id)sortDescriptorKeyForIdentifier:(id)identifier
{
	if( [identifier isEqual:CMRThreadTitleKey] ) {
		return [ThreadNameColumn lowercaseString];
	} else if( [identifier isEqual:CMRThreadNumberOfMessagesKey] ) {
		return [NumberOfAllColumn lowercaseString];
	} else if( [identifier isEqual:CMRThreadLastLoadedNumberKey] ) {
		return [NumberOfReadColumn lowercaseString];
	} else if( [identifier isEqual:CMRThreadSubjectIndexKey] ) {
		return [TempThreadThreadNumberColumn lowercaseString];
	} else if( [identifier isEqual:CMRThreadModifiedDateKey] ) {
		return [ModifiedDateColumn lowercaseString];
	} 
	return nil;
}
- (SEL)sortDescriptorSelectorForIdentifier:(id)identifier
{
	if( [identifier isEqual:CMRThreadTitleKey] ) {
		return @selector(compareForBS:);
	} else if( [identifier isEqual:CMRThreadNumberOfMessagesKey] ) {
		return @selector(compareForBS:);
	} else if( [identifier isEqual:CMRThreadLastLoadedNumberKey] ) {
		return @selector(compareForBS:);
	} else if( [identifier isEqual:CMRThreadSubjectIndexKey] ) {
		return @selector(compareForBS:);
	} else if( [identifier isEqual:CMRThreadModifiedDateKey] ) {
		return @selector(compareForBS:);
	} 
	return Nil;
}
*/
- (void) setupTableColumn : (NSTableColumn *) column
{
/*	
	NSSortDescriptor *desc;
	id key = nil;
	SEL sel = Nil;
	
	key = [self sortDescriptorKeyForIdentifier:[column identifier]];
	sel = [self sortDescriptorSelectorForIdentifier:[column identifier]];
	
	if( key && sel ) {
		desc = [[[NSSortDescriptor alloc] initWithKey:key
											ascending:YES
											 selector:sel] autorelease];
		[column setSortDescriptorPrototype:desc];
	}
 */
    
    if ([CMRThreadStatusKey isEqualToString : [column identifier]]) {
        [self setupStatusColumnWithTableColumn : column];
        return;
    }

	id dataCell = [column dataCell];
	[dataCell setWraps: YES];
	[dataCell setDrawsBackground: NO];

	if ([dataCell alignment] == NSRightTextAlignment) {
		CMRTextColumnCell	*cell_ = [[CMRTextColumnCell alloc] initTextCell: @""];
		[cell_ setAttributesFromCell: dataCell];
		[column setDataCell: cell_];
		[cell_ release];
	}
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
+ (BOOL) shouldShowTitleRulerView
{
	return YES;
}

+ (BSTitleRulerModeType) rulerModeForInformDatOchi
{
	return BSTitleRulerShowTitleAndInfoMode;
}

- (void) cleanUpTitleRuler: (NSTimer *) aTimer
{
	[super cleanUpTitleRuler: aTimer];
	[[[self scrollView] horizontalRulerView] setNeedsDisplay: YES];
}

/*+ (float) navBarSubviewsAdjustValue
{
	return 1.0;
}*/

- (void) setupSplitView
{
	BOOL			isGoingToVertical = [CMRPref isSplitViewVertical];
	BSKFSplitView	*splitView_ = [self splitView];
	NSArray			*subviewsAry_ = [splitView_ subviews];

    [splitView_ setVertical : isGoingToVertical];
	[[[self threadsListTable] enclosingScrollView] setBorderType: NSNoBorder];
	[[[self threadsListTable] enclosingScrollView] setHasHorizontalScroller : isGoingToVertical];

    topSubview = [subviewsAry_ objectAtIndex : 0];
    bottomSubview = [subviewsAry_ objectAtIndex : 1];
	
	[RBSplitView setCursor: RBSVDragCursor toCursor: [NSCursor resizeLeftRightCursor]];
}

- (void) updateDefaultsWithTableView : (NSTableView *) tbview
{
	id	tmp;
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
}

- (void) setupThreadsListTable
{
    ThreadsListTable    *tbView_ = [self threadsListTable];
	id tmp2;
    
    [self createDefaultTableColumnsWithTableView : tbView_];
    [self updateDefaultsWithTableView : tbView_];

	tmp2 = [CMRPref threadsListTableColumnState];
	if(tmp2)
		[tbView_ restoreColumnState : tmp2];

    [tbView_ setTarget : self];
    [tbView_ setDelegate : self];

    // dispatch in listViewAction:
    [tbView_ setAction : @selector(listViewAction:)];
    [tbView_ setDoubleAction : @selector(listViewDoubleAction:)];
	
	// Favorites Item's Drag & Drop operation support:
	[tbView_ registerForDraggedTypes : [NSArray arrayWithObjects : BSFavoritesIndexSetPboardType, nil]];
    
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
	[[[self boardListTable] enclosingScrollView] setBorderType: NSNoBorder];
    
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
	RBSplitView *mainSplitView_ = [[self boardListSubView] outermostSplitView];

    [[self window] setFrameAutosaveName : APP_BROWSER_WINDOW_AUTOSAVE_NAME];
	[[self window] setFrameUsingName : APP_BROWSER_WINDOW_AUTOSAVE_NAME];

	[mainSplitView_ setAutosaveName : APP_BROWSER_BL_SPLITVUEW_AUTOSAVE_NAME recursively : NO];
	[mainSplitView_ restoreState : NO];
	[mainSplitView_ adjustSubviews];

	[self setupSplitView];

	[[self splitView] setPositionAutosaveName : APP_BROWSER_SPVIEW_AUTOSAVE_NAME];
	[[self splitView] setPositionUsingName : APP_BROWSER_SPVIEW_AUTOSAVE_NAME];
}

- (void) setupKeyLoops
{
	[[self searchField] setNextKeyView : [self boardListTable]];
	[[self boardListTable] setNextKeyView : [self threadsListTable]];
	if([self shouldShowContents]) {
		[[self threadsListTable] setNextKeyView : [self textView]];
		[[self textView] setNextKeyView : [[self indexingStepper] textField]];
		[[[self indexingStepper] textField] setNextKeyView : [self searchField]];
	} else {
		[[self threadsListTable] setNextKeyView : [self searchField]];
	}
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
